import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/riverpod/auth_notifier.dart';
import '../riverpod/profile_notifier.dart';
import '../riverpod/time_slot_notifier.dart';
import '../../handyman/riverpod/location_notifier.dart';
import '../../handyman/riverpod/handyman_commission_notifier.dart';
import 'dart:io';
import '../../../core/api/api_client.dart';
import '../../../core/widgets/image_viewer.dart';
import '../../../core/storage/shared_preference_helper.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  int _selectedTab = 0;
  String _role = 'PROVIDER';

  // Profile tab controllers
  late TextEditingController _firstNameCtrl;
  late TextEditingController _lastNameCtrl;
  late TextEditingController _usernameCtrl;
  late TextEditingController _designationCtrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _mobileCtrl;
  late TextEditingController _addressCtrl;
  late TextEditingController _companyNameCtrl;
  late TextEditingController _gstCtrl;
  late TextEditingController _cityCtrl;
  late TextEditingController _stateCtrl;
  late TextEditingController _countryCtrl;
  late TextEditingController _selectAddressCtrl;
  late TextEditingController _commissionCtrl;
  int? _selectedCountry;
  int? _selectedState;
  int? _selectedCity;
  bool _controllersInitialized = false;

  // Change password controllers
  final _oldPassCtrl = TextEditingController();
  final _newPassCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();
  bool _obscureOldPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  bool _isUpdating = false;
  bool _isDeletingAccount = false;
  bool _isFetchingLocation = false;

  Future<void> _deleteAccount() async {
    setState(() {
      _isDeletingAccount = true;
    });
    try {
      final response = await ApiClient().post(endpoint: '/delete-user-account');
      if (response != null && response['status'] == 1) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Account deleted successfully', style: TextStyle(color: Colors.white)), backgroundColor: Colors.green),
          );
          await ref.read(authProvider.notifier).logout();
          if (mounted) {
            Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response?['message']?.toString() ?? 'Failed to delete account', style: const TextStyle(color: Colors.white)), backgroundColor: Colors.red),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString(), style: const TextStyle(color: Colors.white)), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isDeletingAccount = false;
        });
      }
    }
  }

  void _showDeleteAccountConfirmation() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text('Are you sure you want to delete your account? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _deleteAccount();
            },
            child: const Text('Yes', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _fetchCurrentLocationAddress() async {
    setState(() {
      _isFetchingLocation = true;
    });
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled.');
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are permanently denied, we cannot request permissions.');
      }

      Position position = await Geolocator.getCurrentPosition();
      final url = 'https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=AIzaSyAkfch0HMM9K4rdDiZbj_cHYSHS4lJKhdg';
      
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK' && data['results'].isNotEmpty) {
          final address = data['results'][0]['formatted_address'];
          setState(() {
            _addressCtrl.text = address;
          });
        } else {
          throw Exception('Could not fetch address');
        }
      } else {
        throw Exception('Failed to load address');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isFetchingLocation = false;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _role = SharedPreferenceHelper.getString('role') ?? 'PROVIDER';
    _firstNameCtrl = TextEditingController();
    _lastNameCtrl = TextEditingController();
    _usernameCtrl = TextEditingController();
    _designationCtrl = TextEditingController();
    _emailCtrl = TextEditingController();
    _mobileCtrl = TextEditingController();
    _addressCtrl = TextEditingController();
    _companyNameCtrl = TextEditingController();
    _gstCtrl = TextEditingController();
    _cityCtrl = TextEditingController();
    _stateCtrl = TextEditingController();
    _countryCtrl = TextEditingController();
    _selectAddressCtrl = TextEditingController();
    _commissionCtrl = TextEditingController();
    Future.microtask(() {
      ref.read(profileProvider.notifier).refresh();
      ref.read(timeSlotProvider.notifier).fetchSlots();
    });
  }

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _usernameCtrl.dispose();
    _designationCtrl.dispose();
    _emailCtrl.dispose();
    _mobileCtrl.dispose();
    _addressCtrl.dispose();
    _companyNameCtrl.dispose();
    _gstCtrl.dispose();
    _cityCtrl.dispose();
    _stateCtrl.dispose();
    _countryCtrl.dispose();
    _selectAddressCtrl.dispose();
    _commissionCtrl.dispose();
    super.dispose();
  }

  void _populateControllers(profile) {
    if (!_controllersInitialized && profile != null) {
      _firstNameCtrl.text = profile.firstName ?? '';
      _lastNameCtrl.text = profile.lastName ?? '';
      _usernameCtrl.text = profile.username ?? '';
      _designationCtrl.text = profile.role ?? '';
      _emailCtrl.text = profile.email ?? '';
      _mobileCtrl.text = profile.mobile ?? '';
      _addressCtrl.text = profile.address ?? '';
      _companyNameCtrl.text = profile.companyName ?? '';
      _gstCtrl.text = profile.gstNumber ?? '';
      _cityCtrl.text = profile.city ?? '';
      _stateCtrl.text = profile.state ?? '';
      _countryCtrl.text = profile.country ?? '';
      _selectAddressCtrl.text = profile.selectAddress ?? '';
      _commissionCtrl.text = profile.handymanCommission ?? '';
      _selectedCountry = profile.countryId;
      _selectedState = profile.stateId;
      _selectedCity = profile.cityId;
      if (_selectedCountry != null) {
        Future.microtask(() => ref.read(locationProvider.notifier).fetchStates(_selectedCountry!));
      }
      if (_selectedState != null) {
        Future.microtask(() => ref.read(locationProvider.notifier).fetchCities(_selectedState!));
      }
      if (profile.providerId != null) {
        Future.microtask(() => ref.read(handymanCommissionProvider.notifier).fetchByProviderId(profile.providerId!));
      }
      _controllersInitialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(profileProvider);
    final locationState = ref.watch(locationProvider);
    final profile = state.profile;
    const bool isMobile = true;

    if (profile != null && !_controllersInitialized) {
      _populateControllers(profile);
    }

    Widget leftTabs = Container(
      width: isMobile ? double.infinity : 250,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderLight),
      ),
      padding: const EdgeInsets.all(16),
      child: isMobile 
        ? SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildTab(0, 'PROFILE', isMobile),
                const SizedBox(width: 12),
                _buildTab(1, 'CHANGE PASSWORD', isMobile),
                const SizedBox(width: 12),
                if (_role != 'HANDYMAN') _buildTab(2, 'TIME SLOT', isMobile),
              ],
            ),
          )
        : Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTab(0, 'PROFILE', isMobile),
              const SizedBox(height: 12),
              _buildTab(1, 'CHANGE PASSWORD', isMobile),
              const SizedBox(height: 12),
              if (_role != 'HANDYMAN') _buildTab(2, 'TIME SLOT', isMobile),
            ],
          ),
    );

    Widget rightContent = Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: state.isLoading && profile == null
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : _buildTabContent(profile, state, locationState),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [

        // Content Area
        Expanded(
          child: Padding(
            padding: EdgeInsets.all(isMobile ? 16.0 : 24.0),
            child: isMobile 
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    leftTabs,
                    const SizedBox(height: 16),
                    Expanded(child: rightContent),
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    leftTabs,
                    const SizedBox(width: 24),
                    Expanded(child: rightContent),
                  ],
                ),
          ),
        ),
      ],
    );
  }

  Widget _buildTab(int index, String title, bool isMobile) {
    final isSelected = _selectedTab == index;
    return InkWell(
      onTap: () => setState(() => _selectedTab = index),
      child: Container(
        width: isMobile ? null : double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF635BFF) : const Color(0xFFEAE9F9),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.white : const Color(0xFF635BFF),
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent(profile, ProfileState state, LocationState locationState) {
    switch (_selectedTab) {
      case 0: return _buildProfileTab(profile, locationState);
      case 1: return _buildChangePasswordTab();
      case 2: return _buildTimeSlotTab();
      default: return const SizedBox();
    }
  }

  // ─────────────────────── PROFILE TAB ───────────────────────

  Widget _buildProfileTab(dynamic profile, LocationState locationState) {
    final imageUrl = profile?.profileImage != null
        ? (profile!.profileImage!.startsWith('http')
            ? profile.profileImage!
            : ApiClient.baseUrl.replaceAll('/api', '') + profile.profileImage!)
        : null;

    return LayoutBuilder(builder: (context, constraints) {
      // Wide: avatar panel on left + 2-col form. Compact: avatar row + 1-col form.
      final isWide = constraints.maxWidth >= 700;

      final avatarWidget = GestureDetector(
        onTap: () {
          if (imageUrl != null) ImageViewer.show(context, NetworkImage(imageUrl));
        },
        child: CircleAvatar(
          radius: isWide ? 40 : 30,
          backgroundColor: AppColors.bgLighterPurple,
          backgroundImage: imageUrl != null ? NetworkImage(imageUrl) : null,
          child: (imageUrl == null)
              ? Icon(Icons.storefront_rounded, size: isWide ? 38 : 26, color: AppColors.primary)
              : null,
        ),
      );

      // 2-col on wide, 1-col on compact
      Widget row2(Widget a, Widget b) => isWide
          ? Row(children: [Expanded(child: a), const SizedBox(width: 20), Expanded(child: b)])
          : Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [a, const SizedBox(height: 16), b]);

      final formContent = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          row2(_buildTextField('First Name *', _firstNameCtrl), _buildTextField('Last Name *', _lastNameCtrl)),
          const SizedBox(height: 20),
          row2(_buildTextField('Username *', _usernameCtrl), _buildTextField('Designation *', _designationCtrl)),
          const SizedBox(height: 20),
          if (_role == 'PROVIDER') ...[
            row2(_buildTextField('Company Name', _companyNameCtrl), _buildTextField('GST Number', _gstCtrl)),
            const SizedBox(height: 20),
            row2(_buildTextField('City', _cityCtrl), _buildTextField('State', _stateCtrl)),
            const SizedBox(height: 20),
          ] else if (_role == 'HANDYMAN') ...[
            row2(
              _dropdownLocation(
                'Country', 
                locationState.countries.map((c) => MapEntry<int, String>(c.id, c.name)).toList(),
                _selectedCountry, 
                (v) {
                  setState(() {
                    _selectedCountry = v;
                    _selectedState = null;
                    _selectedCity = null;
                  });
                  if (v != null) ref.read(locationProvider.notifier).fetchStates(v);
                }
              ),
              _selectedCountry != null ? _dropdownLocation(
                'State', 
                locationState.states.map((s) => MapEntry<int, String>(s.id, s.name)).toList(),
                _selectedState, 
                (v) {
                  setState(() {
                    _selectedState = v;
                    _selectedCity = null;
                  });
                  if (v != null) ref.read(locationProvider.notifier).fetchCities(v);
                }
              ) : const SizedBox.shrink(),
            ),
            const SizedBox(height: 20),
            row2(
              _selectedState != null ? _dropdownLocation(
                'City', 
                locationState.cities.map((c) => MapEntry<int, String>(c.id, c.name)).toList(),
                _selectedCity, 
                (v) => setState(() => _selectedCity = v)
              ) : const SizedBox.shrink(),
              _commissionDropdown(),
            ),
            const SizedBox(height: 20),
          ],
          row2(_buildTextField('Email *', _emailCtrl, readOnly: true), _buildPhoneField(_mobileCtrl)),
          const SizedBox(height: 20),
          _buildTextField('Address', _addressCtrl, suffixIcon: IconButton(
            icon: _isFetchingLocation 
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.my_location, color: AppColors.primary),
            onPressed: _isFetchingLocation ? null : _fetchCurrentLocationAddress,
            tooltip: 'Fetch current location',
          )),

          const SizedBox(height: 32),
          Align(
            alignment: Alignment.centerRight,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                OutlinedButton(
                  onPressed: _isDeletingAccount ? null : _showDeleteAccountConfirmation,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  ),
                  child: _isDeletingAccount
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.red, strokeWidth: 2))
                      : const Text('Delete Account'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
              onPressed: _isUpdating ? null : () async {
                if (profile != null) {
                  setState(() => _isUpdating = true);
                  final firstName = _firstNameCtrl.text.trim();
                  final lastName = _lastNameCtrl.text.trim();
                  final username = _usernameCtrl.text.trim();
                  await ref.read(profileProvider.notifier).updateProfile(
                    firstName.isNotEmpty ? firstName : profile.firstName,
                    lastName.isNotEmpty ? lastName : profile.lastName,
                    username.isNotEmpty ? username : profile.username,
                    _mobileCtrl.text.trim().isNotEmpty ? _mobileCtrl.text.trim() : profile.mobile,
                    companyName: _role == 'PROVIDER' ? _companyNameCtrl.text.trim() : null,
                    gstNumber: _role == 'PROVIDER' ? _gstCtrl.text.trim() : null,
                    address: _addressCtrl.text.trim(),
                    city: _cityCtrl.text.trim(),
                    stateStr: _stateCtrl.text.trim(),
                    country: _role == 'HANDYMAN' ? _countryCtrl.text.trim() : null,
                    countryId: _role == 'HANDYMAN' ? _selectedCountry : null,
                    stateId: _role == 'HANDYMAN' ? _selectedState : null,
                    cityId: _role == 'HANDYMAN' ? _selectedCity : null,
                    handymanCommission: _role == 'HANDYMAN' 
                        ? (_getInitialCommissionId(ref.read(handymanCommissionProvider).items, _commissionCtrl.text) ?? _commissionCtrl.text.trim()) 
                        : null,
                  );
                  if (mounted) setState(() => _isUpdating = false);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF635BFF),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
              child: _isUpdating
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('Update'),
            ),
          ]),
          )],
      );

      if (isWide) {
        // ── Wide: left avatar panel + right scrollable form ──
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 200,
              padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 8),
              decoration: const BoxDecoration(
                border: Border(right: BorderSide(color: AppColors.borderLight)),
              ),
              child: Column(
                children: [
                  avatarWidget,
                  const SizedBox(height: 12),
                  Text(
                    profile != null ? '${profile.firstName} ${profile.lastName}' : 'Loading...',
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.textSecondary),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    profile?.role ?? '',
                    style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: formContent,
              ),
            ),
          ],
        );
      }

      // ── Compact (Mac screen): avatar row at top + single-col form below ──
      return SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                avatarWidget,
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        profile != null ? '${profile.firstName} ${profile.lastName}' : 'Loading...',
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.textSecondary),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(profile?.role ?? '', style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Divider(color: AppColors.borderLight),
            const SizedBox(height: 16),
            formContent,
          ],
        ),
      );
    });
  }

  // ─────────────────────── CHANGE PASSWORD TAB ───────────────────────

  Widget _buildChangePasswordTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(40),
      child: Center(
        child: SizedBox(
          width: 500,
          child: Column(
            children: [
              _buildTextField(
                'Old Password *', 
                _oldPassCtrl, 
                obscure: _obscureOldPassword,
                suffixIcon: IconButton(
                  icon: Icon(_obscureOldPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 20, color: AppColors.textMuted),
                  onPressed: () => setState(() => _obscureOldPassword = !_obscureOldPassword),
                ),
              ),
              const SizedBox(height: 24),
              _buildTextField(
                'New Password *', 
                _newPassCtrl, 
                obscure: _obscureNewPassword,
                suffixIcon: IconButton(
                  icon: Icon(_obscureNewPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 20, color: AppColors.textMuted),
                  onPressed: () => setState(() => _obscureNewPassword = !_obscureNewPassword),
                ),
              ),
              const SizedBox(height: 24),
              _buildTextField(
                'Confirm New Password *', 
                _confirmPassCtrl, 
                obscure: _obscureConfirmPassword,
                suffixIcon: IconButton(
                  icon: Icon(_obscureConfirmPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 20, color: AppColors.textMuted),
                  onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                ),
              ),
              const SizedBox(height: 32),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: () async {
                    if (_oldPassCtrl.text.isEmpty || _newPassCtrl.text.isEmpty || _confirmPassCtrl.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill all fields', style: TextStyle(color: Colors.white)), backgroundColor: Colors.red));
                      return;
                    }
                    if (_newPassCtrl.text != _confirmPassCtrl.text) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('New passwords do not match', style: TextStyle(color: Colors.white)), backgroundColor: Colors.red));
                      return;
                    }
                    try {
                      final response = await ApiClient().post(
                        endpoint: '/change-password',
                        body: {
                          'old_password': _oldPassCtrl.text,
                          'new_password': _newPassCtrl.text,
                        }
                      );
                      if (context.mounted) {
                        bool isSuccess = false;
                        String msg = 'Failed to change password';

                        if (response != null && response['status'] == 1) {
                          final data = response['data'];
                          if (data is Map) {
                            msg = data['message']?.toString() ?? 'Password changed successfully';
                            if (data.containsKey('status')) {
                              isSuccess = data['status'] == true || data['status'] == 1;
                            } else {
                              isSuccess = !msg.toLowerCase().contains('not match') && 
                                          !msg.toLowerCase().contains('incorrect') && 
                                          !msg.toLowerCase().contains('fail') && 
                                          !msg.toLowerCase().contains('error') && 
                                          !msg.toLowerCase().contains('invalid');
                            }
                          } else {
                            isSuccess = true;
                            msg = 'Password changed successfully';
                          }
                        } else {
                          msg = response?['message']?.toString() ?? 'Failed to change password';
                        }

                        if (isSuccess) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg, style: const TextStyle(color: Colors.white)), backgroundColor: Colors.green));
                          _oldPassCtrl.clear();
                          _newPassCtrl.clear();
                          _confirmPassCtrl.clear();
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg, style: const TextStyle(color: Colors.white)), backgroundColor: Colors.red));
                        }
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString(), style: const TextStyle(color: Colors.white)), backgroundColor: Colors.red));
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF635BFF),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  ),
                  child: const Text('Save'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────── FIELD HELPERS ───────────────────────

  Widget _buildTextField(String label, TextEditingController controller, {bool obscure = false, bool readOnly = false, int maxLines = 1, Widget? suffixIcon}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label.replaceAll(' *', ''),
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
            children: [
              if (label.contains('*')) const TextSpan(text: ' *', style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: obscure,
          readOnly: readOnly,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: label.replaceAll(' *', ''),
            hintStyle: const TextStyle(fontSize: 13, color: AppColors.textMuted),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            filled: readOnly,
            fillColor: readOnly ? AppColors.backgroundScaffold : null,
            suffixIcon: suffixIcon,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: AppColors.borderLight)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: AppColors.borderLight)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: AppColors.primary)),
          ),
        ),
      ],
    );
  }

  Widget _buildPlainField(String label, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
        const SizedBox(height: 8),
        TextField(
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(fontSize: 13, color: AppColors.textMuted),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: AppColors.borderLight)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: AppColors.borderLight)),
          ),
        ),
      ],
    );
  }

  Widget _buildStaticDropdown(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label.replaceAll(' *', ''),
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
            children: [
              if (label.contains('*')) const TextSpan(text: ' *', style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.borderLight),
            borderRadius: BorderRadius.circular(6),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: value,
              items: [DropdownMenuItem(value: value, child: Text(value, style: const TextStyle(fontSize: 13)))],
              onChanged: (v) {},
            ),
          ),
        ),
      ],
    );
  }

  Widget _dropdownLocation(String lbl, List<MapEntry<int, String>> items, int? value, ValueChanged<int?> onChanged) {
    final hasValue = items.any((e) => e.key == value);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      RichText(
        text: TextSpan(
          text: lbl.replaceAll(' *', ''),
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
          children: lbl.contains('*') ? [const TextSpan(text: ' *', style: TextStyle(color: Colors.red))] : [],
        ),
      ),
      const SizedBox(height: 8),
      DropdownButtonFormField<int>(
        value: hasValue ? value : null,
        hint: Text(lbl.replaceAll(' *', ''), style: const TextStyle(color: AppColors.textMuted, fontSize: 13)),
        items: items.map((e) => DropdownMenuItem(value: e.key, child: Text(e.value, style: const TextStyle(fontSize: 13)))).toList(),
        onChanged: onChanged,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: AppColors.borderLight)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: AppColors.borderLight)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: AppColors.primary)),
        ),
        isExpanded: true,
        icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.textMuted),
      ),
    ]);
  }

  String? _getInitialCommissionId(List<dynamic> items, String currentVal) {
    if (currentVal.isEmpty) return null;
    if (items.any((c) => c.id.toString() == currentVal)) return currentVal;
    if (items.any((c) => c.name == currentVal)) return items.firstWhere((c) => c.name == currentVal).id.toString();
    for (var c in items) {
      if (currentVal == '₹${c.commission.toStringAsFixed(2)}' || currentVal == '${c.commission}%' || currentVal.replaceAll(RegExp(r'[^0-9.]'), '') == c.commission.toString()) {
        return c.id.toString();
      }
    }
    return null;
  }

  Widget _commissionDropdown() {
    final commissionState = ref.watch(handymanCommissionProvider);
    final items = commissionState.items;
    final initialValue = _getInitialCommissionId(items, _commissionCtrl.text);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: const TextSpan(
            text: 'Handyman Commission',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
          ),
        ),
        const SizedBox(height: 8),
        commissionState.isLoading
            ? const SizedBox(
                height: 48,
                child: Center(child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary)),
              )
            : DropdownButtonFormField<String>(
                value: initialValue,
                hint: const Text('Select Commission', style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
                items: items.map((c) {
                  final label = c.type == 'Percent'
                      ? '${c.name} (${c.commission}%)'
                      : '${c.name} (₹${c.commission.toStringAsFixed(2)})';
                  return DropdownMenuItem<String>(
                    value: c.id.toString(),
                    child: Text(label, style: const TextStyle(fontSize: 13)),
                  );
                }).toList(),
                onChanged: (v) => setState(() => _commissionCtrl.text = v ?? ''),
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: AppColors.borderLight)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: AppColors.borderLight)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: AppColors.primary)),
                ),
                isExpanded: true,
                icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.textMuted),
              ),
      ],
    );
  }

  Widget _buildPhoneField(TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: const TextSpan(
            text: 'Contact Number',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
            children: [TextSpan(text: ' *', style: TextStyle(color: Colors.red))],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.borderLight),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                decoration: const BoxDecoration(
                  border: Border(right: BorderSide(color: AppColors.borderLight)),
                  color: Color(0xFFF8F9FA),
                ),
                child: const Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text('🇮🇳 +91', style: TextStyle(fontSize: 13)),
                    SizedBox(width: 4),
                    Icon(Icons.arrow_drop_down, size: 16),
                  ],
                ),
              ),
              Expanded(
                child: TextField(
                  controller: controller,
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFileBrowseField(String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.borderLight),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            children: [
              const Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Text('Choose file...', style: TextStyle(fontSize: 13, color: AppColors.textMuted)),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: const BoxDecoration(
                  border: Border(left: BorderSide(color: AppColors.borderLight)),
                  color: Color(0xFFF8F9FA),
                ),
                child: const Text('Browse', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ),
      ],
    );
  }
  Widget _buildTimeSlotTab() {
    final timeSlotState = ref.watch(timeSlotProvider);
    
    if (timeSlotState.isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }

    if (timeSlotState.savedSlots.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Text('No time slots added yet.', style: TextStyle(color: AppColors.textSecondary)),
        ),
      );
    }

    final days = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
    final activeDays = days.where((d) => 
      timeSlotState.savedSlots.any((s) => s.day.toLowerCase() == d.toLowerCase() && s.times.isNotEmpty)
    ).toList();
    
    if (activeDays.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Text('No active time slots.', style: TextStyle(color: AppColors.textSecondary)),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: activeDays.length,
      itemBuilder: (context, index) {
        final day = activeDays[index];
        final slots = timeSlotState.savedSlots.firstWhere((s) => s.day.toLowerCase() == day.toLowerCase()).times;

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF8F9FA),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 60,
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF635BFF),
                  borderRadius: BorderRadius.circular(4),
                ),
                alignment: Alignment.center,
                child: Text(
                  day,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      slots.join(', '),
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                    )
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

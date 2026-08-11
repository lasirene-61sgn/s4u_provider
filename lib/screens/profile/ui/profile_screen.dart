import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/riverpod/auth_notifier.dart';
import '../riverpod/profile_notifier.dart';
import '../riverpod/time_slot_notifier.dart';
import 'dart:io';
import '../../../core/api/api_client.dart';
import '../../../core/widgets/image_viewer.dart';
import '../../../core/storage/shared_preference_helper.dart';


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
  bool _controllersInitialized = false;

  // Change password controllers
  final _oldPassCtrl = TextEditingController();
  final _newPassCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();

  bool _isUpdating = false;

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
      _controllersInitialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(profileProvider);
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
          : _buildTabContent(profile, state),
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

  Widget _buildTabContent(profile, ProfileState state) {
    switch (_selectedTab) {
      case 0: return _buildProfileTab(profile);
      case 1: return _buildChangePasswordTab();
      case 2: return _buildTimeSlotTab();
      default: return const SizedBox();
    }
  }

  // ─────────────────────── PROFILE TAB ───────────────────────

  Widget _buildProfileTab(dynamic profile) {
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
          ] else if (_role == 'HANDYMAN') ...[
            row2(_buildTextField('Country', _countryCtrl), _buildTextField('Select Address', _selectAddressCtrl)),
            const SizedBox(height: 20),
            _buildTextField('Handyman Commission', _commissionCtrl),
            const SizedBox(height: 20),
          ],
          row2(_buildTextField('City', _cityCtrl), _buildTextField('State', _stateCtrl)),
          const SizedBox(height: 20),
          row2(_buildTextField('Email *', _emailCtrl, readOnly: true), _buildPhoneField(_mobileCtrl)),
          const SizedBox(height: 20),
          _buildTextField('Address', _addressCtrl),

          const SizedBox(height: 32),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
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
                    selectAddress: _role == 'HANDYMAN' ? _selectAddressCtrl.text.trim() : null,
                    handymanCommission: _role == 'HANDYMAN' ? _commissionCtrl.text.trim() : null,
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
          ),
        ],
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
              _buildTextField('Old Password *', _oldPassCtrl, obscure: true),
              const SizedBox(height: 24),
              _buildTextField('New Password *', _newPassCtrl, obscure: true),
              const SizedBox(height: 24),
              _buildTextField('Confirm New Password *', _confirmPassCtrl, obscure: true),
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
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(response['message'] ?? 'Password changed successfully', style: const TextStyle(color: Colors.white)), backgroundColor: Colors.green));
                        _oldPassCtrl.clear();
                        _newPassCtrl.clear();
                        _confirmPassCtrl.clear();
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

  Widget _buildTextField(String label, TextEditingController controller, {bool obscure = false, bool readOnly = false, int maxLines = 1}) {
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

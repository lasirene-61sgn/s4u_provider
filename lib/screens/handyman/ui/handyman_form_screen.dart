import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../riverpod/handyman_notifier.dart';
import '../riverpod/handyman_commission_notifier.dart';
import '../riverpod/location_notifier.dart';
import '../../provider_info/riverpod/address_notifier.dart';
import '../../provider_info/model/address_model.dart';
import '../model/handyman_model.dart';
import '../../../core/api/api_client.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HandymanFormScreen extends ConsumerStatefulWidget {
  final Handyman? handyman;
  const HandymanFormScreen({super.key, this.handyman});

  @override
  ConsumerState<HandymanFormScreen> createState() => _HandymanFormScreenState();
}

class _HandymanFormScreenState extends ConsumerState<HandymanFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _firstNameCtrl;
  late TextEditingController _lastNameCtrl;
  late TextEditingController _usernameCtrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _passwordCtrl;
  late TextEditingController _mobileCtrl;
  late TextEditingController _addressCtrl;
  String? _selectedCommission;

  String? _selectedAddress;
  int? _selectedCountry;
  int? _selectedState;
  int? _selectedCity;
  int? _serviceAddressId;
  String _selectedStatus = 'Active';
  bool _isEditMode = false;
  bool _isFetchingLocation = false;

  final List<String> _addressTypes = ['Home', 'Office', 'Other'];
  final List<String> _statuses = ['Active', 'Inactive'];

  @override
  void initState() {
    super.initState();
    _isEditMode = widget.handyman != null;
    final h = widget.handyman;
    _firstNameCtrl = TextEditingController(text: h != null ? h.name.split(' ').first : '');
    _lastNameCtrl = TextEditingController(
      text: h != null && h.name.split(' ').length > 1 ? h.name.split(' ').sublist(1).join(' ') : '',
    );
    _usernameCtrl = TextEditingController(text: h?.name.replaceAll(' ', '').toLowerCase() ?? '');
    _emailCtrl = TextEditingController(text: h?.email ?? '');
    _passwordCtrl = TextEditingController();
    _mobileCtrl = TextEditingController(text: h?.mobile ?? '');
    _addressCtrl = TextEditingController(text: h?.address ?? '');
    _selectedCommission = h?.handymanCommission;

    if (h != null) {
      _selectedAddress = h.selectAddress;
      _selectedStatus = (h.status == 'ACTIVE' || h.status == 'Active') ? 'Active' : 'Inactive';
    }

    if (_isEditMode && h != null) {
      final detail = ref.read(handymenProvider).selectedDetail;
      if (detail != null) {
        _firstNameCtrl.text = detail.firstName;
        _lastNameCtrl.text = detail.lastName;
        _usernameCtrl.text = detail.username;
        _emailCtrl.text = detail.email;
        _mobileCtrl.text = detail.contactNumber;
        _addressCtrl.text = detail.address ?? '';
        _selectedCountry = detail.countryId;
        _selectedState = detail.stateId;
        _selectedCity = detail.cityId;
        if (detail.handymanCommission != null && detail.handymanCommission!.toString().isNotEmpty) {
           _selectedCommission = detail.handymanCommission!.toString();
        }
        
        _selectedStatus = detail.status == 1 ? 'Active' : 'Inactive';

        // Prepopulate selected address from ID if we have it
        if (detail.serviceAddressId != null) {
          final matchedAddr = ref.read(addressProvider).addresses.firstWhere(
            (a) => a.id == detail.serviceAddressId,
            orElse: () => AddressModel(
              id: -1, 
              providerId: 0, 
              address: '',
              latitude: '',
              longitude: '',
              status: 0,
            ),
          );
          if (matchedAddr.id != -1) {
            _selectedAddress = matchedAddr.address;
          }
        }
      }
    }
    
    // Fetch initial states if country is already selected (edit mode)
    if (_selectedCountry != null) {
      Future.microtask(() => ref.read(locationProvider.notifier).fetchStates(_selectedCountry!));
    }
    if (_selectedState != null) {
      Future.microtask(() => ref.read(locationProvider.notifier).fetchCities(_selectedState!));
    }
    
    // Fetch commissions for the dropdown
    Future.microtask(() => ref.read(handymanCommissionProvider.notifier).refresh());
  }

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _usernameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _mobileCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    try {
      int? addressId;
      if (_selectedAddress != null) {
        final match = ref.read(addressProvider).addresses.firstWhere(
          (a) => a.address == _selectedAddress,
          orElse: () => AddressModel(id: -1, providerId: 0, address: '', latitude: '', longitude: '', status: 0),
        );
        if (match.id != -1) addressId = match.id;
      }

      if (_isEditMode && widget.handyman != null) {
        await ref.read(handymenProvider.notifier).updateHandyman(
          context,
          widget.handyman!.id,
          _firstNameCtrl.text.trim(),
          _lastNameCtrl.text.trim(),
          _usernameCtrl.text.trim(),
          _emailCtrl.text.trim(),
          _mobileCtrl.text.trim(),
          _selectedCountry,
          _selectedState,
          _selectedCity,
          _addressCtrl.text.trim(),
          addressId,
          _selectedCommission ?? '',
          imageUrl: null,
        );
      } else {
        await ref.read(handymenProvider.notifier).addHandyman(
          context,
          _firstNameCtrl.text.trim(),
          _lastNameCtrl.text.trim(),
          _usernameCtrl.text.trim(),
          _emailCtrl.text.trim(),
          _mobileCtrl.text.trim(),
          _passwordCtrl.text.trim(),
          _selectedCountry,
          _selectedState,
          _selectedCity,
          _addressCtrl.text.trim(),
          addressId,
          _selectedCommission ?? '',
          imageUrl: null,
        );
      }
      
      // Clear the detail state on success
      if (mounted) ref.read(handymenProvider.notifier).clearSelectedDetail();
      
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
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
  Widget build(BuildContext context) {
    final addressState = ref.watch(addressProvider);
    final locationState = ref.watch(locationProvider);
    final handymanState = ref.watch(handymenProvider);

    ref.listen<HandymanState>(handymenProvider, (previous, next) {
      if (previous?.isLoadingDetail == true && next.isLoadingDetail == false && next.selectedDetail != null) {
        final detail = next.selectedDetail!;
        _firstNameCtrl.text = detail.firstName;
        _lastNameCtrl.text = detail.lastName;
        _usernameCtrl.text = detail.username;
        _emailCtrl.text = detail.email;
        _mobileCtrl.text = detail.contactNumber;
        _addressCtrl.text = detail.address ?? '';
        setState(() {
          _selectedCountry = detail.countryId;
          _selectedState = detail.stateId;
          _selectedCity = detail.cityId;
          if (detail.handymanCommission != null && detail.handymanCommission!.toString().isNotEmpty) {
             _selectedCommission = detail.handymanCommission!.toString();
          }
          _selectedStatus = detail.status == 1 ? 'Active' : 'Inactive';
        });
        
        if (detail.countryId != null) {
          ref.read(locationProvider.notifier).fetchStates(detail.countryId!);
        }
        if (detail.stateId != null) {
          ref.read(locationProvider.notifier).fetchCities(detail.stateId!);
        }
        if (detail.serviceAddressId != null) {
          _serviceAddressId = detail.serviceAddressId;
        }
      }
    });

    final List<String> providerAddresses = addressState.addresses
        .map((a) => a.address)
        .where((s) => s.isNotEmpty)
        .toList();
    final List<String> addressList = providerAddresses.isNotEmpty ? providerAddresses : _addressTypes;

    if (_selectedAddress == null && _serviceAddressId != null && addressState.addresses.isNotEmpty) {
      final matchedAddr = addressState.addresses.firstWhere(
        (a) => a.id == _serviceAddressId,
        orElse: () => AddressModel(id: -1, providerId: 0, address: '', latitude: '', longitude: '', status: 0),
      );
      if (matchedAddr.id != -1) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) setState(() => _selectedAddress = matchedAddr.address);
        });
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: Text(
          _isEditMode ? 'Edit' : 'Add New',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryDark),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.primaryDark),
      ),
      body: handymanState.isLoadingDetail 
        ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
        : Column(
        children: [
          // Form body
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.borderLight),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Row 1: First Name | Last Name | Username
                      _row3(
                        _textField('First Name *', _firstNameCtrl, required: true),
                        _textField('Last Name *', _lastNameCtrl, required: true),
                        _textField('Username *', _usernameCtrl, required: true),
                      ),
                      const SizedBox(height: 20),

                      // Row 2: Email | Password | Commission
                      _row3(
                        _textField('Email *', _emailCtrl, required: true, keyboard: TextInputType.emailAddress),
                        _isEditMode 
                            ? const SizedBox.shrink()
                            : _textField(
                                'Password *',
                                _passwordCtrl,
                                required: true,
                                obscure: true,
                                validator: (v) {
                                  if (v == null || v.isEmpty) return 'Required';
                                  if (v.length < 8) return 'Must be at least 8 characters';
                                  if (!RegExp(r'[A-Z]').hasMatch(v)) return 'Must contain uppercase letter';
                                  if (!RegExp(r'[a-z]').hasMatch(v)) return 'Must contain lowercase letter';
                                  if (!RegExp(r'[0-9]').hasMatch(v)) return 'Must contain number';
                                  if (!RegExp(r'''[!@#\$%\^&\*\(\)_\+\-\=\[\]\{\};:\'",<>\.\?\/\\|`~]''').hasMatch(v)) return 'Must contain special character';
                                  return null;
                                },
                              ),
                        _commissionDropdown(),
                      ),
                      const SizedBox(height: 20),

                      // Row 3: Contact Number | Status | Select Address
                      _row3(
                        _phoneField(),
                        _dropdown('Status *', _statuses, _selectedStatus,
                            (v) => setState(() => _selectedStatus = v ?? 'Active')),
                        _dropdown('Select Address', addressList, _selectedAddress,
                            (v) => setState(() => _selectedAddress = v)),
                      ),
                      const SizedBox(height: 20),

                      // Row 4: Country | State | City
                      _row3(
                        _dropdownLocation(
                          'Select Country *', 
                          locationState.countries.map((c) => MapEntry(c.id, c.name)).toList(),
                          _selectedCountry, 
                          (v) {
                            setState(() {
                              _selectedCountry = v;
                              _selectedState = null;
                              _selectedCity = null;
                            });
                            if (v != null) {
                              ref.read(locationProvider.notifier).fetchStates(v);
                            }
                          }
                        ),
                        _selectedCountry != null ? _dropdownLocation(
                          'Select State *', 
                          locationState.states.map((s) => MapEntry(s.id, s.name)).toList(),
                          _selectedState, 
                          (v) {
                            setState(() {
                              _selectedState = v;
                              _selectedCity = null;
                            });
                            if (v != null) {
                              ref.read(locationProvider.notifier).fetchCities(v);
                            }
                          }
                        ) : const SizedBox.shrink(),
                        _selectedState != null ? _dropdownLocation(
                          'Select City *', 
                          locationState.cities.map((c) => MapEntry(c.id, c.name)).toList(),
                          _selectedCity, 
                          (v) => setState(() => _selectedCity = v)
                        ) : const SizedBox.shrink(),
                      ),
                      const SizedBox(height: 20),

                      // Address
                      _label('Address'),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _addressCtrl,
                        maxLines: 3,
                        decoration: _deco('Address').copyWith(
                          suffixIcon: IconButton(
                            icon: _isFetchingLocation 
                                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                                : const Icon(Icons.my_location, color: AppColors.primary),
                            onPressed: _isFetchingLocation ? null : _fetchCurrentLocationAddress,
                            tooltip: 'Fetch current location',
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      const SizedBox(height: 16),
                      if (handymanState.savingError != null)
                        Container(
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            border: Border.all(color: Colors.red.shade200),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.error_outline, color: Colors.red, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  handymanState.savingError!,
                                  style: const TextStyle(color: Colors.red, fontSize: 13, fontWeight: FontWeight.w500),
                                ),
                              ),
                            ],
                          ),
                        ),

                      // Save button
                      Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton(
                          onPressed: handymanState.isSaving ? null : _save,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            elevation: 0,
                          ),
                          child: handymanState.isSaving
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                              : const Text('Save',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _row3(Widget a, Widget b, Widget c) {
    return LayoutBuilder(builder: (ctx, cons) {
      if (cons.maxWidth > 700) {
        return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(child: a),
          const SizedBox(width: 20),
          Expanded(child: b),
          const SizedBox(width: 20),
          Expanded(child: c),
        ]);
      }
      return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        a, const SizedBox(height: 16), b, const SizedBox(height: 16), c,
      ]);
    });
  }

  Widget _textField(String lbl, TextEditingController ctrl,
      {bool required = false, bool obscure = false, String? hint, TextInputType keyboard = TextInputType.text, String? Function(String?)? validator}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _label(lbl),
      const SizedBox(height: 8),
      TextFormField(
        controller: ctrl,
        obscureText: obscure,
        keyboardType: keyboard,
        decoration: _deco(hint ?? lbl.replaceAll(' *', '')),
        validator: validator ?? (required ? (v) => (v == null || v.trim().isEmpty) ? 'Required' : null : null),
      ),
    ]);
  }

  Widget _dropdown(String lbl, List<String> items, String? value, ValueChanged<String?> onChanged) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _label(lbl),
      const SizedBox(height: 8),
      DropdownButtonFormField<String>(
        value: items.contains(value) ? value : null,
        hint: Text(lbl.replaceAll(' *', ''), style: const TextStyle(color: AppColors.textMuted, fontSize: 14)),
        items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 14)))).toList(),
        onChanged: onChanged,
        decoration: _deco(''),
        isExpanded: true,
        icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.textMuted),
      ),
    ]);
  }

  Widget _dropdownLocation(String lbl, List<MapEntry<int, String>> items, int? value, ValueChanged<int?> onChanged) {
    final hasValue = items.any((e) => e.key == value);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _label(lbl),
      const SizedBox(height: 8),
      DropdownButtonFormField<int>(
        value: hasValue ? value : null,
        hint: Text(lbl.replaceAll(' *', ''), style: const TextStyle(color: AppColors.textMuted, fontSize: 14)),
        items: items.map((e) => DropdownMenuItem(value: e.key, child: Text(e.value, style: const TextStyle(fontSize: 14)))).toList(),
        onChanged: onChanged,
        decoration: _deco(''),
        isExpanded: true,
        icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.textMuted),
      ),
    ]);
  }

  Widget _phoneField() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _label('Contact Number *'),
      const SizedBox(height: 8),
      TextFormField(
        controller: _mobileCtrl,
        keyboardType: TextInputType.phone,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: _deco('Contact Number').copyWith(
          prefixIcon: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              const Text('🇮🇳', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 4),
              const Text('+91', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
              const SizedBox(width: 6),
              Container(width: 1, height: 20, color: AppColors.borderLight),
            ]),
          ),
        ),
        validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
      ),
    ]);
  }

  Widget _label(String text) {
    final req = text.contains('*');
    return RichText(
      text: TextSpan(
        text: text.replaceAll(' *', ''),
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
        children: req ? [const TextSpan(text: ' *', style: TextStyle(color: Colors.red))] : [],
      ),
    );
  }

  InputDecoration _deco(String hint) => InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 14),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        filled: true,
        fillColor: const Color(0xFFF9FAFB),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.borderLight)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.borderLight)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Colors.red)),
        focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Colors.red, width: 1.5)),
      );

  Widget _commissionDropdown() {
    final commissionState = ref.watch(handymanCommissionProvider);
    final items = commissionState.items;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label('Handyman Commission'),
        const SizedBox(height: 8),
        commissionState.isLoading
            ? const SizedBox(
                height: 48,
                child: Center(child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary)),
              )
            : DropdownButtonFormField<String>(
                value: items.any((c) => c.id.toString() == _selectedCommission) ? _selectedCommission : null,
                hint: const Text('Select Commission', style: TextStyle(color: AppColors.textMuted, fontSize: 14)),
                items: items.map((c) {
                  final label = c.type == 'Percent'
                      ? '${c.name} (${c.commission}%)'
                      : '${c.name} (₹${c.commission.toStringAsFixed(2)})';
                  return DropdownMenuItem<String>(
                    value: c.id.toString(),
                    child: Text(label, style: const TextStyle(fontSize: 14)),
                  );
                }).toList(),
                onChanged: (v) => setState(() => _selectedCommission = v),
                decoration: _deco(''),
                isExpanded: true,
                icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.textMuted),
              ),
      ],
    );
  }
}


import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/image_viewer.dart';
import '../riverpod/service_notifier.dart';
import '../model/service_model.dart';
import '../riverpod/category_notifier.dart';
import '../riverpod/subcategory_notifier.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import '../../provider_info/riverpod/address_notifier.dart';
import '../../provider_info/model/address_model.dart';
import '../../profile/riverpod/profile_notifier.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class ServiceFormScreen extends ConsumerStatefulWidget {
  final ServiceModel? service;
  const ServiceFormScreen({super.key, this.service});

  @override
  ConsumerState<ServiceFormScreen> createState() => _ServiceFormScreenState();
}

class _ServiceFormScreenState extends ConsumerState<ServiceFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameCtrl;
  late TextEditingController _descCtrl;
  late TextEditingController _priceCtrl;
  late TextEditingController _discountCtrl;
  late TextEditingController _durationCtrl;
  late TextEditingController _advPaymentCtrl;

  String? _selectedCategory;
  String? _selectedSubcategory;
  String? _selectedAddress;
  String _selectedPriceType = 'Fixed';
  String _selectedStatus = 'Active';
  String _selectedVisitType = 'Online';

  bool _timeslot = false;
  bool _isFeatured = false;
  bool _advancedPayment = false;
  bool _isSaving = false;
  bool get _isEdit => widget.service != null;

  final TextEditingController _newAddressCtrl = TextEditingController();
  bool _isFetchingLocation = false;
  String? _newAddressLat;
  String? _newAddressLng;

  final List<String> _priceTypes = ['Fixed', 'Hourly'];
  final List<String> _statuses = ['Active', 'Inactive'];
  final List<String> _visitTypes = ['Online', 'Offline', 'Both'];

  PlatformFile? _serviceAttachment;

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.pickFiles(type: FileType.image);
    if (result != null) {
      setState(() {
        _serviceAttachment = result.files.first;
      });
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: source);

    if (image != null) {
      final bytes = await image.readAsBytes();
      setState(() {
        _serviceAttachment = PlatformFile(
          name: image.name,
          size: bytes.length,
          bytes: bytes,
          path: image.path,
        );
      });
    }
  }

  void _showImageSourceActionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Photo Library'),
              onTap: () {
                Navigator.of(context).pop();
                _pickFile();
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('Camera'),
              onTap: () {
                Navigator.of(context).pop();
                _pickImage(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    final s = widget.service;
    _nameCtrl = TextEditingController(text: s?.name ?? '');
    _descCtrl = TextEditingController(text: s?.description ?? '');
    _priceCtrl = TextEditingController(text: s?.price?.toString() ?? '');
    _discountCtrl = TextEditingController(text: s?.discount?.toString() ?? '');
    _durationCtrl = TextEditingController(text: s?.duration ?? '');
    _advPaymentCtrl = TextEditingController(text: s?.advancedPaymentAmount?.toString() ?? '');
    if (s != null) {
      _selectedCategory = s.categoryId;
      _selectedSubcategory = s.subcategoryId;
      _selectedPriceType = s.priceType;
      _selectedStatus = (s.status.toUpperCase() == 'INACTIVE') ? 'Inactive' : 'Active';
      _selectedVisitType = s.visitType ?? 'Online';
      _selectedAddress = s.selectAddress;
      _timeslot = s.timeslot;
      _isFeatured = s.isFeatured;
      _advancedPayment = s.advancedPayment;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(categoryProvider.notifier).loadCategories();
      ref.read(addressProvider.notifier).fetchAddresses();
      if (_selectedCategory != null) {
        ref.read(subCategoryProvider.notifier).loadSubCategoriesByCategory(_selectedCategory!);
      } else {
        ref.read(subCategoryProvider.notifier).clear();
      }

      if (_isEdit) {
        _fetchServiceDetail(s!.id);
      }
    });
  }

  Future<void> _fetchServiceDetail(int id) async {
    setState(() => _isSaving = true); // Using _isSaving just to show loading spinner for now
    try {
      final detail = await ref.read(serviceProvider.notifier).getServiceDetail(id);
      if (detail != null && mounted) {
        final Map<String, dynamic> detailMap = detail['service_detail'] ?? detail['data']?['service_detail'] ?? detail;
        final detailedService = ServiceModel.fromJson(detailMap);

        setState(() {
          _nameCtrl.text = detailedService.name;
          _descCtrl.text = detailedService.description;
          _priceCtrl.text = detailedService.price?.toString() ?? '';
          _discountCtrl.text = detailedService.discount?.toString() ?? '';
          _durationCtrl.text = detailedService.duration ?? '';
          _advPaymentCtrl.text = detailedService.advancedPaymentAmount?.toString() ?? '';
          
          _selectedCategory = detailedService.categoryId;
          _selectedSubcategory = detailedService.subcategoryId;
          _selectedPriceType = detailedService.priceType;
          _selectedStatus = (detailedService.status.toUpperCase() == 'INACTIVE') ? 'Inactive' : 'Active';
          _selectedVisitType = detailedService.visitType ?? 'Online';
          _selectedAddress = detailedService.selectAddress;
          _timeslot = detailedService.timeslot;
          _isFeatured = detailedService.isFeatured;
          _advancedPayment = detailedService.advancedPayment;
        });

        if (_selectedCategory != null) {
          ref.read(subCategoryProvider.notifier).loadSubCategoriesByCategory(_selectedCategory!);
        }
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose(); _descCtrl.dispose(); _priceCtrl.dispose();
    _discountCtrl.dispose(); _durationCtrl.dispose(); _advPaymentCtrl.dispose();
    _newAddressCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetchLocation() async {
    setState(() => _isFetchingLocation = true);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) throw Exception('Location services disabled.');

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) throw Exception('Permission denied.');
      }
      if (permission == LocationPermission.deniedForever) throw Exception('Permission denied forever.');

      final position = await Geolocator.getCurrentPosition();
      List<Placemark> placemarks = await Geocoding().placemarkFromCoordinates(position.latitude, position.longitude);
      
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        String address = '${place.street ?? ''}, ${place.subLocality ?? ''}, ${place.locality ?? ''}, ${place.postalCode ?? ''}, ${place.country ?? ''}'.replaceAll(RegExp(r',\s*,'), ',').replaceAll(RegExp(r'^,\s*'), '').replaceAll(RegExp(r',\s*$'), '');
        _newAddressLat = position.latitude.toString();
        _newAddressLng = position.longitude.toString();
        setState(() => _newAddressCtrl.text = address);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not fetch location: $e'), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() => _isFetchingLocation = false);
    }
  }

  Future<void> _saveNewAddress() async {
    final text = _newAddressCtrl.text.trim();
    if (text.isEmpty) return;
    
    final req = {
      'address': text,
      'status': 1,
      'latitude': _newAddressLat ?? '0.0',
      'longitude': _newAddressLng ?? '0.0',
    };
    
    setState(() => _isSaving = true);
    await ref.read(addressProvider.notifier).addAddress(req);
    setState(() => _isSaving = false);
    
    if (ref.read(addressProvider).error == null) {
      setState(() {
         _selectedAddress = text;
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    try {
      if (_isEdit) {
        await ref.read(serviceProvider.notifier).updateService(
          widget.service!.id,
          name: _nameCtrl.text.trim(),
          description: _descCtrl.text.trim(),
          categoryId: _selectedCategory ?? '1',
          subcategoryId: _selectedSubcategory,
          price: double.tryParse(_priceCtrl.text) ?? 0,
          discount: double.tryParse(_discountCtrl.text),
          priceType: _selectedPriceType,
          duration: _durationCtrl.text.trim(),
          status: _selectedStatus == 'Active' ? 'ACTIVE' : 'INACTIVE',
          visitType: _selectedVisitType,
          selectAddress: _selectedAddress == 'Add Address' ? _newAddressCtrl.text.trim() : _selectedAddress,
          providerAddressId: (_selectedAddress != null && _selectedAddress != 'Add Address') ? ref.read(addressProvider).addresses.firstWhere((a) => a.address == _selectedAddress, orElse: () => AddressModel(id: 0, providerId: 0, address: '', latitude: '', longitude: '', status: 1)).id.toString() : null,
          isFeatured: _isFeatured,
          timeslot: _timeslot,
          advancedPayment: _advancedPayment,
          advancedPaymentAmount: double.tryParse(_advPaymentCtrl.text),
          serviceAttachment: _serviceAttachment,
        );
      } else {
        await ref.read(serviceProvider.notifier).addService(
          name: _nameCtrl.text.trim(),
          description: _descCtrl.text.trim(),
          categoryId: _selectedCategory ?? '1',
          subcategoryId: _selectedSubcategory,
          price: double.tryParse(_priceCtrl.text) ?? 0,
          priceType: _selectedPriceType,
          duration: _durationCtrl.text.trim(),
          discount: double.tryParse(_discountCtrl.text),
          status: _selectedStatus == 'Active' ? 'ACTIVE' : 'INACTIVE',
          visitType: _selectedVisitType,
          selectAddress: _selectedAddress == 'Add Address' ? _newAddressCtrl.text.trim() : _selectedAddress,
          providerAddressId: (_selectedAddress != null && _selectedAddress != 'Add Address') ? ref.read(addressProvider).addresses.firstWhere((a) => a.address == _selectedAddress, orElse: () => AddressModel(id: 0, providerId: 0, address: '', latitude: '', longitude: '', status: 1)).id.toString() : null,
          isFeatured: _isFeatured,
          timeslot: _timeslot,
          advancedPayment: _advancedPayment,
          advancedPaymentAmount: double.tryParse(_advPaymentCtrl.text),
          providerId: ref.read(profileProvider).profile?.id,
          providerName: ref.read(profileProvider).profile != null 
              ? '${ref.read(profileProvider).profile!.firstName} ${ref.read(profileProvider).profile!.lastName}'.trim() 
              : null,
          providerEmail: ref.read(profileProvider).profile?.email,
          serviceAttachment: _serviceAttachment,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          _isEdit ? 'Edit' : 'Add New',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primaryDark),
        ),
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: AppColors.borderLight, height: 1),
        ),
        iconTheme: const IconThemeData(color: AppColors.primaryDark),
      ),
      body: Column(
        children: [
          // Form
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.borderLight),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name
                      _label('Name *'),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _nameCtrl,
                        enabled: !_isEdit,
                        decoration: _deco('Name'),
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                      ),
                      const SizedBox(height: 20),

                      // Description
                      _label('Description'),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _descCtrl,
                        maxLines: 3,
                        enabled: !_isEdit,
                        decoration: _deco('Description'),
                      ),
                      const SizedBox(height: 20),

                      // Category | Sub Category
                      _row2(
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _label('Select Category *'),
                            const SizedBox(height: 8),
                            DropdownButtonFormField<String>(
                              value: ref.watch(categoryProvider).categories.any((c) => c.id.toString() == _selectedCategory) ? _selectedCategory : null,
                              hint: ref.watch(categoryProvider).isLoading 
                                  ? const Text('Loading...', style: TextStyle(color: AppColors.textMuted, fontSize: 14))
                                  : const Text('Select Category', style: TextStyle(color: AppColors.textMuted, fontSize: 14)),
                              items: ref.watch(categoryProvider).categories.map((c) => DropdownMenuItem<String>(
                                value: c.id.toString(),
                                child: Text(c.name, style: const TextStyle(fontSize: 14)),
                              )).toList(),
                              onChanged: (v) {
                                setState(() {
                                  _selectedCategory = v;
                                  _selectedSubcategory = null; // Reset subcategory
                                });
                                if (v != null) {
                                  ref.read(subCategoryProvider.notifier).loadSubCategoriesByCategory(v);
                                }
                              },
                              decoration: _deco(''),
                              isExpanded: true,
                              icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.textMuted),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _label('Select Sub Category'),
                            const SizedBox(height: 8),
                            DropdownButtonFormField<String>(
                              value: ref.watch(subCategoryProvider).subcategories.any((s) => s.id.toString() == _selectedSubcategory) ? _selectedSubcategory : null,
                              hint: ref.watch(subCategoryProvider).isLoading
                                  ? const Text('Loading...', style: TextStyle(color: AppColors.textMuted, fontSize: 14))
                                  : const Text('Select Sub Category', style: TextStyle(color: AppColors.textMuted, fontSize: 14)),
                              items: ref.watch(subCategoryProvider).subcategories.map((s) => DropdownMenuItem<String>(
                                value: s.id.toString(),
                                child: Text(s.name, style: const TextStyle(fontSize: 14)),
                              )).toList(),
                              onChanged: (v) => setState(() => _selectedSubcategory = v),
                              decoration: _deco(''),
                              isExpanded: true,
                              icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.textMuted),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Select Address | Price Type | Price
                      _row3(
                        _selectedAddress == 'Add Address' 
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _label('Enter Address *'),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _newAddressCtrl,
                                maxLines: 3,
                                minLines: 3,
                                decoration: _deco('Enter new address').copyWith(
                                  prefixIcon: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      _isFetchingLocation 
                                        ? const Padding(padding: EdgeInsets.all(12), child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))) 
                                        : IconButton(icon: const Icon(Icons.my_location, color: AppColors.primary), onPressed: _fetchLocation),
                                    ],
                                  ),
                                ),
                                validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                              ),
                              const SizedBox(height: 8),
                              ValueListenableBuilder<TextEditingValue>(
                                valueListenable: _newAddressCtrl,
                                builder: (context, value, child) {
                                  return Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      TextButton(
                                        onPressed: () => setState(() => _selectedAddress = null),
                                        child: const Text('Cancel', style: TextStyle(color: AppColors.textMuted)),
                                      ),
                                      if (value.text.trim().isNotEmpty) ...[
                                        const SizedBox(width: 8),
                                        ElevatedButton(
                                          onPressed: _saveNewAddress,
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: AppColors.primary,
                                            foregroundColor: Colors.white,
                                            elevation: 0,
                                          ),
                                          child: const Text('Add'),
                                        ),
                                      ],
                                    ],
                                  );
                                },
                              ),
                            ],
                          )
                        : _buildDropdown('Select Address', ['Add Address', ...ref.watch(addressProvider).addresses.map((a) => a.address).where((a) => a.isNotEmpty).toSet().toList()..addAll(_selectedAddress != null && _selectedAddress != 'Add Address' && !ref.watch(addressProvider).addresses.any((a) => a.address == _selectedAddress) ? [_selectedAddress!] : [])], _selectedAddress, (v) {
                          setState(() {
                            _selectedAddress = v;
                            if (v == 'Add Address') {
                              _newAddressCtrl.clear();
                              _newAddressLat = null;
                              _newAddressLng = null;
                            }
                          });
                        }),
                        _buildDropdown('Price type *', _priceTypes, _selectedPriceType, (v) => setState(() => _selectedPriceType = v ?? 'Fixed')),
                        _textField('Price *', _priceCtrl, keyboard: TextInputType.number, required: true),
                      ),
                      const SizedBox(height: 20),

                      // Discount | Duration | Status
                      _row3(
                        _textField('Discount %', _discountCtrl, keyboard: TextInputType.number),
                        _textField('Duration (hours)', _durationCtrl, keyboard: TextInputType.number),
                        _buildDropdown('Status *', _statuses, _selectedStatus, (v) => setState(() => _selectedStatus = v ?? 'Active')),
                      ),
                      const SizedBox(height: 20),

                      // Visit Type
                      _buildDropdown('Visit Type', _visitTypes, _selectedVisitType, (v) => setState(() => _selectedVisitType = v ?? 'Online')),
                      const SizedBox(height: 20),

                      // Image Pick
                      const Text.rich(
                        TextSpan(
                          text: 'Image ',
                          style: TextStyle(fontWeight: FontWeight.w500, color: AppColors.textSecondary),
                          children: [TextSpan(text: '*', style: TextStyle(color: Colors.red))],
                        ),
                      ),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () => _showImageSourceActionSheet(context),
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.borderLight),
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.white,
                          ),
                          child: Row(
                            children: [
                              if (_serviceAttachment != null && _serviceAttachment!.path != null)
                                Padding(padding: const EdgeInsets.only(left: 8), child: ClipRRect(borderRadius: BorderRadius.circular(4), child: Image.file(File(_serviceAttachment!.path!), height: 32, width: 32, fit: BoxFit.cover)))
                                else if (_serviceAttachment == null && widget.service?.image != null)
                                  Padding(padding: const EdgeInsets.only(left: 8), child: GestureDetector(
                                    onTap: () {
                                      ImageViewer.show(context, NetworkImage(widget.service!.image!.startsWith('http') ? widget.service!.image! : 'https://s4u.lasireneexim.com${widget.service!.image!}'));
                                    },
                                    child: ClipRRect(borderRadius: BorderRadius.circular(4), child: Image.network(widget.service!.image!.startsWith('http') ? widget.service!.image! : 'https://s4u.lasireneexim.com${widget.service!.image!}', height: 32, width: 32, fit: BoxFit.cover, errorBuilder: (c, e, s) => const Icon(Icons.image, size: 24, color: AppColors.textMuted))),
                                  )),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                  child: Text(_serviceAttachment != null ? _serviceAttachment!.name : (widget.service?.image?.split('/').last ?? 'Choose Attachments'), style: TextStyle(color: _serviceAttachment != null || widget.service?.image != null ? Colors.black87 : AppColors.textMuted), maxLines: 1, overflow: TextOverflow.ellipsis),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                alignment: Alignment.center,
                                decoration: const BoxDecoration(
                                  border: Border(left: BorderSide(color: AppColors.borderLight)),
                                  color: AppColors.backgroundPanel,
                                  borderRadius: BorderRadius.horizontal(right: Radius.circular(8)),
                                ),
                                child: const Text('Browse', style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Toggles row
                      Wrap(
                        spacing: 16,
                        runSpacing: 12,
                        children: [
                          _toggleRow('Time Slot', _timeslot, (v) => setState(() => _timeslot = v)),
                          _toggleRow('Set as featured', _isFeatured, (v) => setState(() => _isFeatured = v)),
                          _toggleRow('Advanced Payment for Services', _advancedPayment, (v) => setState(() => _advancedPayment = v)),
                        ],
                      ),

                      if (_advancedPayment) ...[
                        const SizedBox(height: 20),
                        _label('Advance payment amount (%)'),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _advPaymentCtrl,
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          decoration: _deco('Amount'),
                        ),
                      ],

                      const SizedBox(height: 32),

                      // Save button
                      Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton(
                          onPressed: _isSaving ? null : _save,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            elevation: 0,
                          ),
                          child: _isSaving
                              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                              : const Text('Save', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
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

  Widget _row2(Widget a, Widget b) => LayoutBuilder(builder: (ctx, cons) {
    if (cons.maxWidth > 600) {
      return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(child: a), const SizedBox(width: 20), Expanded(child: b),
      ]);
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [a, const SizedBox(height: 16), b]);
  });

  Widget _row3(Widget a, Widget b, Widget c) => LayoutBuilder(builder: (ctx, cons) {
    if (cons.maxWidth > 700) {
      return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(child: a), const SizedBox(width: 20), Expanded(child: b), const SizedBox(width: 20), Expanded(child: c),
      ]);
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [a, const SizedBox(height: 16), b, const SizedBox(height: 16), c]);
  });

  Widget _textField(String lbl, TextEditingController ctrl, {bool required = false, TextInputType keyboard = TextInputType.text}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _label(lbl),
      const SizedBox(height: 8),
      TextFormField(
        controller: ctrl,
        keyboardType: keyboard,
        decoration: _deco(lbl.replaceAll(' *', '')),
        validator: required ? (v) => (v == null || v.trim().isEmpty) ? 'Required' : null : null,
      ),
    ]);
  }

  Widget _buildDropdown(String lbl, List<String> items, String? value, ValueChanged<String?> onChanged) {
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


  Widget _toggleRow(String label, bool value, ValueChanged<bool> onChanged) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Switch(
        value: value, onChanged: onChanged,
        activeColor: Colors.white, activeTrackColor: AppColors.primary,
      ),
      const SizedBox(width: 8),
      Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
    ]);
  }

  Widget _label(String text) {
    final req = text.contains('*');
    return RichText(text: TextSpan(
      text: text.replaceAll(' *', ''),
      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
      children: req ? [const TextSpan(text: ' *', style: TextStyle(color: Colors.red))] : [],
    ));
  }

  InputDecoration _deco(String hint) => InputDecoration(
    hintText: hint, hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 14),
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    filled: true, fillColor: const Color(0xFFF9FAFB),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.borderLight)),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.borderLight)),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
    errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Colors.red)),
  );
}

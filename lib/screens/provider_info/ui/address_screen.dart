import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/api/api_client.dart';
import '../../../core/widgets/image_viewer.dart';
import '../../profile/riverpod/profile_notifier.dart';
import '../riverpod/address_notifier.dart';

class AddressScreen extends ConsumerStatefulWidget {
  const AddressScreen({super.key});

  @override
  ConsumerState<AddressScreen> createState() => _AddressScreenState();
}

class _AddressScreenState extends ConsumerState<AddressScreen> {
  bool get _isMobile => MediaQuery.of(context).size.width < 800;
  bool _showAddAddressForm = false;

  final _latitudeCtrl = TextEditingController();
  final _longitudeCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  String _addressStatus = 'Active';
  int? _editingAddressId;

  @override
  void dispose() {
    _latitudeCtrl.dispose();
    _longitudeCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileProvider);
    final addressState = ref.watch(addressProvider);
    final profile = profileState.profile;

    return _showAddAddressForm ? _buildAddAddressForm(addressState) : _buildAddressList(profile, addressState);
  }

  Widget _buildAddressList(dynamic profile, AddressState addressState) {
    return Padding(
      padding: EdgeInsets.only(bottom: _isMobile ? 16.0 : 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              decoration: _isMobile ? null : BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: Column(
                children: [
                  // Toolbar row
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: _isMobile ? [
                        Expanded(child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Wrap(
                                spacing: 8, runSpacing: 8,
                                alignment: WrapAlignment.end,
                                children: [
                                  ElevatedButton.icon(
                                    onPressed: () {
                                      _latitudeCtrl.clear();
                                      _longitudeCtrl.clear();
                                      _addressCtrl.clear();
                                      _addressStatus = 'Active';
                                      _editingAddressId = null;
                                      setState(() => _showAddAddressForm = true);
                                    },
                                    icon: const Icon(Icons.add, size: 18),
                                    label: const Text('Add Address'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primary,
                                      foregroundColor: Colors.white,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    ),
                                  ),
                                ]
                              ),
                            ],
                          ),
                        ),
                      ] : [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ElevatedButton.icon(
                              onPressed: () {
                                _latitudeCtrl.clear();
                                _longitudeCtrl.clear();
                                _addressCtrl.clear();
                                _addressStatus = 'Active';
                                _editingAddressId = null;
                                setState(() => _showAddAddressForm = true);
                              },
                              icon: const Icon(Icons.add, size: 18),
                              label: const Text('Add Address'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Table header
                  if (!_isMobile) Container(
                    color: AppColors.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: const Row(children: [
                      SizedBox(width: 40, child: Icon(Icons.check_box_outline_blank, color: Colors.white, size: 18)),
                      Expanded(child: Text('Provider', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13))),
                      Expanded(flex: 2, child: Text('Address', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13))),
                      Expanded(child: Text('Status', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13))),
                      SizedBox(width: 90, child: Text('Action', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13))),
                    ]),
                  ),

                  // Table body
                  Expanded(child: Builder(builder: (context) {
                    if (addressState.isLoading && addressState.addresses.isEmpty) {
                      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                    }
                    if (addressState.error != null && addressState.addresses.isEmpty) {
                      return Center(child: Text('Error: ${addressState.error}', style: const TextStyle(color: Colors.red)));
                    }
                    if (addressState.addresses.isEmpty) {
                      return const Center(child: Text('No addresses added yet.', style: TextStyle(color: AppColors.textSecondary)));
                    }
                    return ListView.separated(
                      itemCount: addressState.addresses.length,
                      separatorBuilder: (_, __) => _isMobile ? const SizedBox(height: 8) : const Divider(height: 1, color: AppColors.borderLight),
                      itemBuilder: (context, index) {
                        final item = addressState.addresses[index];
                        return _buildRow(item, profile);
                      },
                    );
                  })),

                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(dynamic item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Address'),
        content: const Text('Are you sure you want to delete this address?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              ref.read(addressProvider.notifier).deleteAddress(item.id);
              Navigator.pop(ctx);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _editAddress(dynamic item) {
    _latitudeCtrl.text = item.latitude ?? '';
    _longitudeCtrl.text = item.longitude ?? '';
    _addressCtrl.text = item.address ?? '';
    _addressStatus = item.status == 1 ? 'Active' : 'Inactive';
    _editingAddressId = item.id;
    setState(() => _showAddAddressForm = true);
  }

  Widget _buildRow(dynamic item, dynamic profile) {
    final isActive = item.status == 1;

    if (_isMobile) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderLight),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          if (profile?.profileImage != null) {
                            ImageViewer.show(context, NetworkImage(profile!.profileImage!.startsWith('http') ? profile!.profileImage! : ApiClient.baseUrl.replaceAll('/api', '') + profile!.profileImage!));
                          }
                        },
                        child: CircleAvatar(
                          radius: 16,
                          backgroundColor: Colors.grey[200],
                          backgroundImage: profile?.profileImage != null ? NetworkImage(profile!.profileImage!.startsWith('http') ? profile!.profileImage! : ApiClient.baseUrl.replaceAll('/api', '') + profile!.profileImage!) : null,
                          child: profile?.profileImage == null ? const Icon(Icons.person, size: 20, color: Colors.grey) : null,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${profile?.firstName ?? ''} ${profile?.lastName ?? ''}'.trim(), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primaryDark)),
                            Text(profile?.email ?? '', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isActive ? Colors.green.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(isActive ? 'Active' : 'Inactive', style: TextStyle(color: isActive ? Colors.green : Colors.red, fontSize: 11, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text('Address', style: TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w500)),
            const SizedBox(height: 4),
            Text(item.address, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w500)),
            const SizedBox(height: 16),
            const Divider(height: 1, color: AppColors.borderLight),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _editAddress(item),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.bgLighterPurple, foregroundColor: AppColors.primary, elevation: 0, padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                  icon: const Icon(Icons.edit_outlined, size: 16), label: const Text('Edit'),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () => _showDeleteDialog(item),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red.withOpacity(0.1), foregroundColor: Colors.red, elevation: 0, padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                  icon: const Icon(Icons.delete_outline, size: 16), label: const Text('Delete'),
                ),
              ],
            ),
          ],
        ),
      );
    }
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(children: [
        const SizedBox(width: 40, child: Icon(Icons.check_box_outline_blank, color: AppColors.borderLight, size: 18)),
        Expanded(
          child: Row(
            children: [
              GestureDetector(
                onTap: () {
                  if (profile?.profileImage != null) {
                    ImageViewer.show(context, NetworkImage(profile!.profileImage!.startsWith('http') ? profile!.profileImage! : ApiClient.baseUrl.replaceAll('/api', '') + profile!.profileImage!));
                  }
                },
                child: CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.grey[200],
                  backgroundImage: profile?.profileImage != null ? NetworkImage(profile!.profileImage!.startsWith('http') ? profile!.profileImage! : ApiClient.baseUrl.replaceAll('/api', '') + profile!.profileImage!) : null,
                  child: profile?.profileImage == null ? const Icon(Icons.person, size: 20, color: Colors.grey) : null,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${profile?.firstName ?? ''} ${profile?.lastName ?? ''}'.trim(), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                    Text(profile?.email ?? '', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ),
            ],
          ),
        ),
        Expanded(flex: 2, child: Text(item.address, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13))),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: isActive ? Colors.green.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              isActive ? 'Active' : 'Inactive',
              style: TextStyle(color: isActive ? Colors.green : Colors.red, fontSize: 12, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        SizedBox(
          width: 90,
          child: Row(children: [
            Tooltip(
              message: 'Edit',
              child: InkWell(
                onTap: () => _editAddress(item),
                borderRadius: BorderRadius.circular(6),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  child: const Icon(Icons.edit, size: 16, color: AppColors.textSecondary),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Tooltip(
              message: 'Delete',
              child: InkWell(
                onTap: () => _showDeleteDialog(item),
                borderRadius: BorderRadius.circular(6),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(Icons.delete_outline, size: 16, color: Colors.red),
                ),
              ),
            ),
          ]),
        ),
      ]),
    );
  }

  Widget _buildAddAddressForm(AddressState addressState) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(_editingAddressId != null ? 'Edit Address' : 'Add New', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primaryDark)),
                  ElevatedButton.icon(
                    onPressed: () => setState(() => _showAddAddressForm = false),
                    icon: const Icon(Icons.arrow_back, size: 16),
                    label: const Text('Back'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: AppColors.borderLight),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  _isMobile 
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Expanded(child: _buildField('Latitude', '00.0000', _latitudeCtrl)),
                                const SizedBox(width: 8),
                                _buildLocationButton(),
                              ],
                            ),
                            const SizedBox(height: 16),
                            _buildField('Longitude', '00.0000', _longitudeCtrl),
                            const SizedBox(height: 16),
                            _buildStatusDropdown(),
                            const SizedBox(height: 16),
                            _buildField('Address *', 'Address', _addressCtrl, 4),
                          ],
                        )
                      : Column(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Expanded(child: _buildField('Latitude', '00.0000', _latitudeCtrl)),
                                      const SizedBox(width: 8),
                                      _buildLocationButton(),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 24),
                                Expanded(child: _buildField('Longitude', '00.0000', _longitudeCtrl)),
                                const SizedBox(width: 24),
                                Expanded(child: _buildStatusDropdown()),
                              ],
                            ),
                            const SizedBox(height: 24),
                            _buildField('Address *', 'Address', _addressCtrl, 4),
                          ],
                        ),
                  const SizedBox(height: 32),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      onPressed: addressState.isLoading ? null : () async {
                        if (_addressCtrl.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill all required fields', style: TextStyle(color: Colors.white)), backgroundColor: Colors.red));
                          return;
                        }
                        
                        final req = {
                          'latitude': _latitudeCtrl.text,
                          'longitude': _longitudeCtrl.text,
                          'address': _addressCtrl.text,
                          'status': _addressStatus == 'Active' ? 1 : 0,
                        };
                        
                        try {
                          if (_editingAddressId != null) {
                            req['id'] = _editingAddressId!;
                            // Assume notifier has updateAddress or similar. If not, maybe just addAddress handles both, or we need to add updateAddress to notifier.
                            // I'll call addAddress for now, the backend might handle upsert.
                            await ref.read(addressProvider.notifier).addAddress(req);
                          } else {
                            await ref.read(addressProvider.notifier).addAddress(req);
                          }
                          if (ref.read(addressProvider).error == null) {
                            setState(() {
                              _showAddAddressForm = false;
                              _latitudeCtrl.clear();
                              _longitudeCtrl.clear();
                              _addressCtrl.clear();
                              _addressStatus = 'Active';
                            });
                          }
                        } catch (e) {
                          // error handled in notifier
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                      ),
                      child: addressState.isLoading 
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Text('Save', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(String label, String hint, TextEditingController controller, [int maxLines = 1]) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label.replaceAll(' *', ''),
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
            children: label.contains('*') ? const [TextSpan(text: ' *', style: TextStyle(color: Colors.red))] : [],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.borderLight),
            borderRadius: BorderRadius.circular(6),
            color: const Color(0xFFF8F9FA),
          ),
          child: TextField(
            controller: controller,
            maxLines: maxLines,
            style: const TextStyle(fontSize: 14),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 14),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLocationButton() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      height: 48, // matching text field height
      width: 48,
      child: Tooltip(
        message: 'Get Current Location',
        child: IconButton(
          icon: const Icon(Icons.my_location, color: AppColors.primary),
          onPressed: () async {
            bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
            if (!serviceEnabled) {
              if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Location services are disabled.'), backgroundColor: Colors.red));
              return;
            }
            LocationPermission permission = await Geolocator.checkPermission();
            if (permission == LocationPermission.denied) {
              permission = await Geolocator.requestPermission();
              if (permission == LocationPermission.denied) {
                if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Location permissions are denied.'), backgroundColor: Colors.red));
                return;
              }
            }
            if (permission == LocationPermission.deniedForever) {
              if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Location permissions are permanently denied.'), backgroundColor: Colors.red));
              return;
            }
            final position = await Geolocator.getCurrentPosition();
            setState(() {
              _latitudeCtrl.text = position.latitude.toString();
              _longitudeCtrl.text = position.longitude.toString();
            });

            try {
              List<Placemark> placemarks = await Geocoding().placemarkFromCoordinates(position.latitude, position.longitude);
              if (placemarks.isNotEmpty) {
                Placemark place = placemarks.first;
                String formattedAddress = '';
                bool isFullAddress = place.street != null && 
                    ((place.locality != null && place.street!.contains(place.locality!)) || 
                     (place.administrativeArea != null && place.street!.contains(place.administrativeArea!)));
                     
                if (isFullAddress) {
                  formattedAddress = place.street!;
                } else {
                  formattedAddress = [
                    place.street,
                    place.subLocality,
                    place.locality,
                    place.postalCode,
                    place.administrativeArea,
                    place.country,
                  ].where((s) => s != null && s.isNotEmpty).toSet().join(', ');
                }
                
                setState(() {
                  _addressCtrl.text = formattedAddress;
                });
              }
            } catch (e) {
              debugPrint("Failed to geocode location: $e");
            }
          },
        ),
      ),
    );
  }

  Widget _buildStatusDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Status *', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.borderLight),
            borderRadius: BorderRadius.circular(6),
            color: const Color(0xFFF8F9FA),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _addressStatus,
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
              items: ['Active', 'Inactive'].map((String value) {
                return DropdownMenuItem<String>(value: value, child: Text(value, style: const TextStyle(fontSize: 14)));
              }).toList(),
              onChanged: (newValue) {
                if (newValue != null) setState(() => _addressStatus = newValue);
              },
            ),
          ),
        ),
      ],
    );
  }
}

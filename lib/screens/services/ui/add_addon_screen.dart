import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../riverpod/service_notifier.dart';
import '../riverpod/addon_notifier.dart';
import '../../../core/api/api_client.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../model/addon_model.dart';

class AddAddonScreen extends ConsumerStatefulWidget {
  final AddonModel? addon;
  const AddAddonScreen({super.key, this.addon});

  @override
  ConsumerState<AddAddonScreen> createState() => _AddAddonScreenState();
}

class _AddAddonScreenState extends ConsumerState<AddAddonScreen> {

  String? _selectedService;
  
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  String _selectedStatus = 'Active';

  @override
  void initState() {
    super.initState();
    if (widget.addon != null) {
      _nameController.text = widget.addon!.name;
      _priceController.text = widget.addon!.price.toString();
      _selectedService = widget.addon!.serviceId?.toString();
      _selectedStatus = widget.addon!.status.toUpperCase() == 'INACTIVE' ? 'Inactive' : 'Active';
    }
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(serviceProvider.notifier).fetchAllServices();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Widget build(BuildContext context) {
    const bool isMobile = true;
    return Scaffold(
      backgroundColor: AppColors.backgroundScaffold,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(widget.addon != null ? 'Edit Addon' : 'Add New', style: const TextStyle(color: AppColors.primaryDark, fontSize: 18, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textSecondary),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.keyboard_double_arrow_left, size: 16),
              label: const Text('Back'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF635BFF),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.borderLight),
          ),
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              isMobile ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTextField('Name', 'Name', controller: _nameController, required: true),
                  const SizedBox(height: 24),
                  _buildDynamicServiceDropdown(),
                ],
              ) : Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _buildTextField('Name', 'Name', controller: _nameController, required: true),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: _buildDynamicServiceDropdown(),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              isMobile ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTextField('Price', 'Price', controller: _priceController, required: true, isNumber: true),
                  const SizedBox(height: 24),
                  _buildDropdownField('Status', _selectedStatus, ['Active', 'Inactive'], (v) {
                    setState(() => _selectedStatus = v!);
                  }, required: true),
                ],
              ) : Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _buildTextField('Price', 'Price', controller: _priceController, required: true, isNumber: true),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: _buildDropdownField('Status', _selectedStatus, ['Active', 'Inactive'], (v) {
                      setState(() => _selectedStatus = v!);
                    }, required: true),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: _saveAddon,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF908BE8),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: ref.watch(addonProvider).isSaving 
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Save'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveAddon() async {
    if (_nameController.text.isEmpty || _priceController.text.isEmpty || _selectedService == null) {
      Fluttertoast.showToast(
        msg: 'Please fill all required fields.',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      return;
    }

    await ref.read(addonProvider.notifier).createAddon(
      id: widget.addon?.id,
      name: _nameController.text,
      price: double.tryParse(_priceController.text) ?? 0.0,
      status: _selectedStatus.toUpperCase(),
      serviceId: int.parse(_selectedService!),
      imageUrl: null, 
    );
  }


  Widget _buildTextField(String label, String hint, {TextEditingController? controller, bool required = false, bool isNumber = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(
          TextSpan(
            text: label,
            style: const TextStyle(fontWeight: FontWeight.w500, color: AppColors.textSecondary),
            children: [
              if (required) const TextSpan(text: ' *', style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 14),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.borderLight),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.borderLight),
            ),
            fillColor: Colors.white,
            filled: true,
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField(String label, String value, List<String> items, Function(String?) onChanged, {bool required = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(
          TextSpan(
            text: label,
            style: const TextStyle(fontWeight: FontWeight.w500, color: AppColors.textSecondary),
            children: [
              if (required) const TextSpan(text: ' *', style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.borderLight),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.borderLight),
            ),
            fillColor: Colors.white,
            filled: true,
          ),
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildDynamicServiceDropdown() {
    final serviceState = ref.watch(serviceProvider);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text.rich(
          TextSpan(
            text: 'Select Service',
            style: TextStyle(fontWeight: FontWeight.w500, color: AppColors.textSecondary),
            children: [TextSpan(text: ' *', style: TextStyle(color: Colors.red))],
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: serviceState.allServices.any((s) => s.id.toString() == _selectedService) ? _selectedService : null,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.borderLight)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.borderLight)),
            fillColor: Colors.white,
            filled: true,
          ),
          hint: serviceState.isLoading 
              ? const Text('Loading...', style: TextStyle(color: AppColors.textMuted, fontSize: 14))
              : const Text('Select Service', style: TextStyle(color: AppColors.textMuted, fontSize: 14)),
          items: serviceState.allServices.map((service) {
            return DropdownMenuItem<String>(
              value: service.id.toString(),
              child: Text(service.name),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedService = value;
            });
          },
        ),
      ],
    );
  }
}

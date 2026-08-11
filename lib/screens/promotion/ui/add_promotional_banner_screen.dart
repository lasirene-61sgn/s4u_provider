import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/foundation.dart';
import '../../../core/constants/app_colors.dart';
import '../model/promotional_banner_model.dart';
import '../riverpod/promotional_banner_notifier.dart';
import '../../services/riverpod/service_notifier.dart';

class AddPromotionalBannerScreen extends ConsumerStatefulWidget {
  final PromotionalBannerModel? banner;
  const AddPromotionalBannerScreen({super.key, this.banner});

  @override
  ConsumerState<AddPromotionalBannerScreen> createState() => _AddPromotionalBannerScreenState();
}

class _AddPromotionalBannerScreenState extends ConsumerState<AddPromotionalBannerScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();
  final TextEditingController _serviceIdController = TextEditingController();

  String? _selectedType = 'service';
  String? _selectedServiceId;
  PlatformFile? _bannerAttachment;

  @override
  void initState() {
    super.initState();
    if (widget.banner != null) {
      _titleController.text = widget.banner!.title;
      _descController.text = widget.banner!.description ?? '';
      _startDateController.text = widget.banner!.startDate ?? '';
      _endDateController.text = widget.banner!.endDate ?? '';
      _serviceIdController.text = widget.banner!.serviceId ?? '';
      _selectedType = widget.banner!.bannerType ?? 'service';
      _selectedServiceId = widget.banner!.serviceId;
    }
    Future.microtask(() => ref.read(serviceProvider.notifier).fetchAllServices());
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    _serviceIdController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        controller.text = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  Future<void> _pickFile() async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take a photo'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: source);
    if (image != null) {
      final bytes = await image.readAsBytes();
      setState(() {
        _bannerAttachment = PlatformFile(
          name: image.name,
          size: bytes.length,
          path: image.path,
          bytes: bytes,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundScaffold,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(widget.banner != null ? 'Edit Promotional Banner' : 'Create Promotional Banner', style: const TextStyle(color: AppColors.primaryDark, fontSize: 18, fontWeight: FontWeight.bold)),
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
              _buildTextField('Title', 'eg. "Special 20% Off Weekend"', required: true, controller: _titleController),
              const SizedBox(height: 24),
              _buildTextField('Description', 'eg. "Full home cleaning promotional offer."', maxLines: 4, controller: _descController),
              const SizedBox(height: 24),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _buildDatePickerField('Start Date', 'YYYY-MM-DD', required: true, controller: _startDateController),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: _buildDatePickerField('End Date', 'YYYY-MM-DD', required: true, controller: _endDateController),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _buildTextField('Banner Type', 'service', 
                      controller: TextEditingController(text: 'service'), 
                      readOnly: true,
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: _buildServiceDropdown(),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildFilePickerField(),
              const SizedBox(height: 32),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: _saveBanner,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF908BE8),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: ref.watch(promotionalBannerProvider).isSaving 
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Submit'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, String hint, {bool required = false, int maxLines = 1, TextEditingController? controller, bool readOnly = false}) {
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
          maxLines: maxLines,
          readOnly: readOnly,
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

  Widget _buildDatePickerField(String label, String hint, {bool required = false, TextEditingController? controller}) {
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
          readOnly: true,
          onTap: () => _selectDate(controller!),
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
            suffixIcon: const Icon(Icons.calendar_today, size: 18, color: AppColors.textSecondary),
          ),
        ),
      ],
    );
  }

  Widget _buildServiceDropdown() {
    final state = ref.watch(serviceProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text.rich(TextSpan(
          text: 'Service',
          style: TextStyle(fontWeight: FontWeight.w500, color: AppColors.textSecondary),
        )),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.borderLight),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              hint: const Text('Select Service', style: TextStyle(color: AppColors.textMuted, fontSize: 14)),
              value: _selectedServiceId != null && state.allServices.any((s) => s.id.toString() == _selectedServiceId) 
                  ? _selectedServiceId 
                  : null,
              items: state.allServices.map((service) {
                return DropdownMenuItem<String>(
                  value: service.id.toString(),
                  child: Text(service.name),
                );
              }).toList(),
              onChanged: (val) {
                setState(() => _selectedServiceId = val);
                if (val != null) _serviceIdController.text = val;
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField(String label, String hint, {bool required = false, String? value, List<String> items = const [], void Function(String?)? onChanged}) {
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
          hint: Text(hint, style: const TextStyle(color: AppColors.textMuted, fontSize: 14)),
          value: value,
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildFilePickerField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text.rich(
          TextSpan(
            text: 'Banner Image',
            style: TextStyle(fontWeight: FontWeight.w500, color: AppColors.textSecondary),
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: _pickFile,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.borderLight),
              color: Colors.white,
            ),
            child: Row(
              children: [
                const Icon(Icons.cloud_upload_outlined, color: AppColors.textSecondary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _bannerAttachment != null 
                        ? _bannerAttachment!.name 
                        : (widget.banner?.bannerAttachment != null && widget.banner!.bannerAttachment!.isNotEmpty) 
                            ? 'Existing Image Loaded' 
                            : 'Click to select image',
                    style: TextStyle(
                        color: (_bannerAttachment != null || (widget.banner?.bannerAttachment != null && widget.banner!.bannerAttachment!.isNotEmpty)) 
                            ? AppColors.textSecondary 
                            : AppColors.textMuted, 
                        fontSize: 14),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (_bannerAttachment != null)
                  IconButton(
                    icon: const Icon(Icons.close, size: 18, color: Colors.red),
                    onPressed: () {
                      setState(() {
                        _bannerAttachment = null;
                      });
                    },
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _saveBanner() async {
    if (_titleController.text.trim().isEmpty || _startDateController.text.trim().isEmpty || _endDateController.text.trim().isEmpty || _selectedType == null) {
      Fluttertoast.showToast(
        msg: 'Please fill required fields',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      return;
    }

    if (widget.banner == null && _bannerAttachment == null) {
      Fluttertoast.showToast(
        msg: 'Please select a banner image',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      return;
    }

    final banner = PromotionalBannerModel(
      id: widget.banner?.id,
      title: _titleController.text.trim(),
      description: _descController.text.trim(),
      startDate: _startDateController.text.trim(),
      endDate: _endDateController.text.trim(),
      bannerType: _selectedType,
      serviceId: _serviceIdController.text.trim(),
      status: 'ACTIVE',
    );

    await ref.read(promotionalBannerProvider.notifier).createBanner(banner, _bannerAttachment);

    if (mounted) {
      final error = ref.read(promotionalBannerProvider).error;
      if (error == null) {
        Fluttertoast.showToast(
          msg: 'Banner created successfully!',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );
        Navigator.pop(context);
      } else {
        Fluttertoast.showToast(
          msg: error,
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }
    }
  }
}

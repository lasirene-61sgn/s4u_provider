import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/widgets/image_viewer.dart';
import '../riverpod/category_notifier.dart';
import '../riverpod/subcategory_notifier.dart';
import '../riverpod/service_notifier.dart';
import '../riverpod/package_notifier.dart';
import '../model/package_model.dart';

class AddPackageScreen extends ConsumerStatefulWidget {
  final PackageModel? package;
  const AddPackageScreen({super.key, this.package});

  @override
  ConsumerState<AddPackageScreen> createState() => _AddPackageScreenState();
}

class _AddPackageScreenState extends ConsumerState<AddPackageScreen> {

  bool _isFeatured = false;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  String? _selectedCategory;
  String? _selectedSubCategory;
  String? _selectedService;
  String _status = 'ACTIVE';
  
  PlatformFile? _packageAttachment;

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.pickFiles(type: FileType.image);
    if (result != null) {
      setState(() {
        _packageAttachment = result.files.first;
      });
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: source);

    if (image != null) {
      final bytes = await image.readAsBytes();
      setState(() {
        _packageAttachment = PlatformFile(
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
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Photo Library'),
                onTap: () {
                  _pickImage(ImageSource.gallery);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Camera'),
                onTap: () {
                  _pickImage(ImageSource.camera);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    if (widget.package != null) {
      _nameController.text = widget.package!.name;
      _descController.text = widget.package!.description ?? '';
      _priceController.text = widget.package!.price?.toString() ?? '';
      _selectedCategory = widget.package!.categoryId?.toString();
      _selectedSubCategory = widget.package!.subCategoryId?.toString();
      _selectedService = widget.package!.serviceId?.toString();
      _status = widget.package!.status == 'INACTIVE' ? 'INACTIVE' : 'ACTIVE';
      _isFeatured = widget.package!.isFeatured;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(categoryProvider.notifier).loadCategories();
      ref.read(subCategoryProvider.notifier).clear();
      ref.read(serviceProvider.notifier).fetchAllServices();
      if (_selectedCategory != null) {
        ref.read(subCategoryProvider.notifier).loadSubCategoriesByCategory(_selectedCategory!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    const bool isMobile = true;
    return Scaffold(
      backgroundColor: AppColors.backgroundScaffold,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(widget.package != null ? 'Edit Package' : 'Add New', style: const TextStyle(color: AppColors.primaryDark, fontSize: 18, fontWeight: FontWeight.bold)),
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
                  _buildTextField('Description', 'Description', controller: _descController),
                  const SizedBox(height: 24),
                  _buildTextField('Price', 'Price', controller: _priceController, required: true, isNumber: true),
                ],
              ) : Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _buildTextField('Name', 'Name', controller: _nameController, required: true)),
                  const SizedBox(width: 24),
                  Expanded(child: _buildTextField('Description', 'Description', controller: _descController)),
                  const SizedBox(width: 24),
                  Expanded(child: _buildTextField('Price', 'Price', controller: _priceController, required: true, isNumber: true)),
                ],
              ),
              const SizedBox(height: 24),
              isMobile ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDynamicCategoryDropdown(),
                  const SizedBox(height: 24),
                  _buildDynamicSubCategoryDropdown(),
                  const SizedBox(height: 24),
                  _buildDynamicServiceDropdown(),
                ],
              ) : Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _buildDynamicCategoryDropdown()),
                  const SizedBox(width: 24),
                  Expanded(child: _buildDynamicSubCategoryDropdown()),
                  const SizedBox(width: 24),
                  Expanded(child: _buildDynamicServiceDropdown()),
                ],
              ),
              const SizedBox(height: 24),
              isMobile ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Switch(
                        value: _isFeatured,
                        onChanged: (val) {
                          setState(() {
                            _isFeatured = val;
                          });
                        },
                        activeColor: const Color(0xFF635BFF),
                      ),
                      const SizedBox(width: 8),
                      const Text('Set as featured', style: TextStyle(fontWeight: FontWeight.w500)),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildStatusDropdown(),
                  const SizedBox(height: 24),
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
                          if (_packageAttachment != null && _packageAttachment!.path != null)
                            Padding(padding: const EdgeInsets.only(left: 8), child: ClipRRect(borderRadius: BorderRadius.circular(4), child: Image.file(File(_packageAttachment!.path!), height: 32, width: 32, fit: BoxFit.cover)))
                          else if (_packageAttachment == null && widget.package?.imageUrl != null)
                            Padding(padding: const EdgeInsets.only(left: 8), child: GestureDetector(
                              onTap: () {
                                ImageViewer.show(context, NetworkImage(widget.package!.imageUrl!));
                              },
                              child: ClipRRect(borderRadius: BorderRadius.circular(4), child: Image.network(widget.package!.imageUrl!, height: 32, width: 32, fit: BoxFit.cover, errorBuilder: (c, e, s) => const Icon(Icons.image, size: 24, color: AppColors.textMuted))),
                            )),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0),
                              child: Text(_packageAttachment != null ? _packageAttachment!.name : (widget.package?.imageUrl?.split('/').last ?? 'Choose Attachments'), style: TextStyle(color: _packageAttachment != null || widget.package?.imageUrl != null ? Colors.black87 : AppColors.textMuted), maxLines: 1, overflow: TextOverflow.ellipsis),
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
                ],
              ) : Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Switch(
                              value: _isFeatured,
                              onChanged: (val) {
                                setState(() {
                                  _isFeatured = val;
                                });
                              },
                              activeColor: const Color(0xFF635BFF),
                            ),
                            const SizedBox(width: 8),
                            const Text('Set as featured', style: TextStyle(fontWeight: FontWeight.w500)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(child: _buildStatusDropdown()),
                  const SizedBox(width: 24),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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
                                if (_packageAttachment != null && _packageAttachment!.path != null)
                                  Padding(padding: const EdgeInsets.only(left: 8), child: ClipRRect(borderRadius: BorderRadius.circular(4), child: Image.file(File(_packageAttachment!.path!), height: 32, width: 32, fit: BoxFit.cover)))
                                else if (_packageAttachment == null && widget.package?.imageUrl != null)
                                  Padding(padding: const EdgeInsets.only(left: 8), child: GestureDetector(
                                    onTap: () {
                                      ImageViewer.show(context, NetworkImage(widget.package!.imageUrl!));
                                    },
                                    child: ClipRRect(borderRadius: BorderRadius.circular(4), child: Image.network(widget.package!.imageUrl!, height: 32, width: 32, fit: BoxFit.cover, errorBuilder: (c, e, s) => const Icon(Icons.image, size: 24, color: AppColors.textMuted))),
                                  )),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                    child: Text(_packageAttachment != null ? _packageAttachment!.name : (widget.package?.imageUrl?.split('/').last ?? 'Choose Attachments'), style: TextStyle(color: _packageAttachment != null || widget.package?.imageUrl != null ? Colors.black87 : AppColors.textMuted), maxLines: 1, overflow: TextOverflow.ellipsis),
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
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: _savePackage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF908BE8),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: ref.watch(packageProvider).isSaving 
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Save'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, String hint, {bool required = false, bool readOnly = false, bool isNumber = false, TextEditingController? controller}) {
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
          readOnly: readOnly,
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
            fillColor: readOnly ? AppColors.backgroundPanel : Colors.white,
            filled: true,
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField(String label, String hint, {bool required = false}) {
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
          items: const [],
          onChanged: (value) {},
        ),
      ],
    );
  }

  Widget _buildDynamicCategoryDropdown() {
    final categoryState = ref.watch(categoryProvider);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text.rich(
          TextSpan(
            text: 'Select Category',
            style: TextStyle(fontWeight: FontWeight.w500, color: AppColors.textSecondary),
            children: [TextSpan(text: ' *', style: TextStyle(color: Colors.red))],
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: categoryState.categories.any((c) => c.id.toString() == _selectedCategory) ? _selectedCategory : null,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.borderLight)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.borderLight)),
            fillColor: Colors.white,
            filled: true,
          ),
          hint: categoryState.isLoading 
              ? const Text('Loading...', style: TextStyle(color: AppColors.textMuted, fontSize: 14))
              : const Text('Select Category', style: TextStyle(color: AppColors.textMuted, fontSize: 14)),
          items: categoryState.categories.map((c) {
            return DropdownMenuItem<String>(
              value: c.id.toString(),
              child: Text(c.name),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedCategory = value;
              _selectedSubCategory = null;
            });
            if (value != null) {
              ref.read(subCategoryProvider.notifier).loadSubCategoriesByCategory(value);
            }
          },
        ),
      ],
    );
  }

  Widget _buildDynamicSubCategoryDropdown() {
    final subCategoryState = ref.watch(subCategoryProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text.rich(
          TextSpan(
            text: 'Select Sub Category',
            style: TextStyle(fontWeight: FontWeight.w500, color: AppColors.textSecondary),
            children: [TextSpan(text: ' *', style: TextStyle(color: Colors.red))],
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: subCategoryState.subcategories.any((s) => s.id.toString() == _selectedSubCategory) ? _selectedSubCategory : null,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.borderLight)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.borderLight)),
            fillColor: Colors.white,
            filled: true,
          ),
          hint: subCategoryState.isLoading
              ? const Text('Loading...', style: TextStyle(color: AppColors.textMuted, fontSize: 14))
              : const Text('Select Sub Category', style: TextStyle(color: AppColors.textMuted, fontSize: 14)),
          items: subCategoryState.subcategories.map((s) {
            return DropdownMenuItem<String>(
              value: s.id.toString(),
              child: Text(s.name),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedSubCategory = value;
            });
          },
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

  Widget _buildStatusDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text.rich(
          TextSpan(
            text: 'Status',
            style: TextStyle(fontWeight: FontWeight.w500, color: AppColors.textSecondary),
            children: [TextSpan(text: ' *', style: TextStyle(color: Colors.red))],
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _status,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.borderLight)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.borderLight)),
            fillColor: Colors.white,
            filled: true,
          ),
          items: const [
            DropdownMenuItem(value: 'ACTIVE', child: Text('Active')),
            DropdownMenuItem(value: 'INACTIVE', child: Text('Inactive')),
          ],
          onChanged: (value) {
            setState(() {
              _status = value!;
            });
          },
        ),
      ],
    );
  }

  Future<void> _savePackage() async {
    if (_nameController.text.trim().isEmpty || _priceController.text.trim().isEmpty) {
      Fluttertoast.showToast(
        msg: 'Please fill required fields',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      return;
    }

    final pkg = PackageModel(
      id: widget.package?.id,
      name: _nameController.text.trim(),
      description: _descController.text.trim(),
      packageType: 'Single Category',
      categoryId: _selectedCategory != null ? int.tryParse(_selectedCategory!) : null,
      subCategoryId: _selectedSubCategory != null ? int.tryParse(_selectedSubCategory!) : null,
      serviceId: _selectedService != null ? int.tryParse(_selectedService!) : null,
      price: double.tryParse(_priceController.text.trim()),
      isFeatured: _isFeatured,
      status: _status,
    );

    await ref.read(packageProvider.notifier).createPackage(pkg, _packageAttachment);
  }
}

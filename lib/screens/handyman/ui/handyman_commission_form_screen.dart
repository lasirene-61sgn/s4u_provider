import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../model/handyman_commission_model.dart';
import '../riverpod/handyman_commission_notifier.dart';

class HandymanCommissionFormScreen extends ConsumerStatefulWidget {
  final HandymanCommissionModel? commission;
  const HandymanCommissionFormScreen({super.key, this.commission});

  @override
  ConsumerState<HandymanCommissionFormScreen> createState() =>
      _HandymanCommissionFormScreenState();
}

class _HandymanCommissionFormScreenState
    extends ConsumerState<HandymanCommissionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _commissionCtrl;
  String _selectedType = 'Percent';
  String _selectedStatus = 'Active';
  bool _isSaving = false;

  bool get _isEdit => widget.commission != null;
  final List<String> _types = ['Percent', 'Fixed'];
  final List<String> _statuses = ['Active', 'Inactive'];

  @override
  void initState() {
    super.initState();
    final c = widget.commission;
    _nameCtrl = TextEditingController(text: c?.name ?? '');
    _commissionCtrl = TextEditingController(
        text: c?.commission != null ? c!.commission.toString() : '');
    if (c != null) {
      _selectedType = c.type;
      _selectedStatus =
          (c.status == 'ACTIVE' || c.status == 'Active') ? 'Active' : 'Inactive';
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _commissionCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    try {
      final name = _nameCtrl.text.trim();
      final commission = double.tryParse(_commissionCtrl.text) ?? 0;
      final status = _selectedStatus == 'Active' ? 'ACTIVE' : 'INACTIVE';

      if (_isEdit) {
        await ref.read(handymanCommissionProvider.notifier).update(
              widget.commission!.id,
              name: name,
              commission: commission,
              type: _selectedType,
              status: status,
            );
      } else {
        await ref.read(handymanCommissionProvider.notifier).add(
              name: name,
              commission: commission,
              type: _selectedType,
              status: status,
            );
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error: $e'), backgroundColor: Colors.red),
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
      body: Column(
        children: [
          // Header
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                  bottom: BorderSide(color: AppColors.borderLight)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _isEdit
                      ? 'Edit'
                      : 'Add New',
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryDark),
                ),
                OutlinedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back, size: 16),
                  label: const Text('Back'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ],
            ),
          ),

          // Form
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32),
              child: Form(
                key: _formKey,
                child: Container(
                  padding: const EdgeInsets.all(28),
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
                        decoration: _deco('Name'),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Required'
                            : null,
                      ),
                      const SizedBox(height: 24),

                      // Commission | Select Type | Status
                      LayoutBuilder(builder: (ctx, cons) {
                        final fields = [
                          _commissionField(),
                          _buildDropdown('Select Type *', _types,
                              _selectedType,
                              (v) => setState(() => _selectedType = v ?? 'Percent')),
                          _buildDropdown('Status *', _statuses,
                              _selectedStatus,
                              (v) => setState(
                                  () => _selectedStatus = v ?? 'Active')),
                        ];
                        if (cons.maxWidth > 700) {
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(child: fields[0]),
                              const SizedBox(width: 20),
                              Expanded(child: fields[1]),
                              const SizedBox(width: 20),
                              Expanded(child: fields[2]),
                            ],
                          );
                        }
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            fields[0],
                            const SizedBox(height: 16),
                            fields[1],
                            const SizedBox(height: 16),
                            fields[2],
                          ],
                        );
                      }),

                      const SizedBox(height: 32),

                      // Save button
                      Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton(
                          onPressed: _isSaving ? null : _save,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 48, vertical: 16),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                            elevation: 0,
                          ),
                          child: _isSaving
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                      color: Colors.white, strokeWidth: 2))
                              : const Text('Save',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15)),
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

  Widget _commissionField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label('Commission *'),
        const SizedBox(height: 8),
        TextFormField(
          controller: _commissionCtrl,
          keyboardType:
              const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))
          ],
          decoration: _deco('Commission'),
          validator: (v) =>
              (v == null || v.trim().isEmpty) ? 'Required' : null,
        ),
      ],
    );
  }

  Widget _buildDropdown(
      String lbl, List<String> items, String? value, ValueChanged<String?> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(lbl),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: items.contains(value) ? value : null,
          hint: Text(lbl.replaceAll(' *', ''),
              style: const TextStyle(
                  color: AppColors.textMuted, fontSize: 14)),
          items: items
              .map((e) => DropdownMenuItem(
                  value: e,
                  child: Text(e,
                      style: const TextStyle(fontSize: 14))))
              .toList(),
          onChanged: onChanged,
          decoration: _deco(''),
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down,
              color: AppColors.textMuted),
        ),
      ],
    );
  }

  Widget _label(String text) {
    final req = text.contains('*');
    return RichText(
        text: TextSpan(
      text: text.replaceAll(' *', ''),
      style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary),
      children: req
          ? [
              const TextSpan(
                  text: ' *', style: TextStyle(color: Colors.red))
            ]
          : [],
    ));
  }

  InputDecoration _deco(String hint) => InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
            color: AppColors.textMuted, fontSize: 14),
        contentPadding: const EdgeInsets.symmetric(
            horizontal: 14, vertical: 14),
        filled: true,
        fillColor: const Color(0xFFF9FAFB),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide:
                const BorderSide(color: AppColors.borderLight)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide:
                const BorderSide(color: AppColors.borderLight)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide:
                const BorderSide(color: AppColors.primary, width: 1.5)),
        errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide:
                const BorderSide(color: Colors.red)),
      );
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../model/handyman_commission_model.dart';
import '../riverpod/handyman_commission_notifier.dart';

class HandymanCommissionScreen extends ConsumerStatefulWidget {
  const HandymanCommissionScreen({super.key});

  @override
  ConsumerState<HandymanCommissionScreen> createState() => _HandymanCommissionScreenState();
}

class _HandymanCommissionScreenState extends ConsumerState<HandymanCommissionScreen> {
  bool _showForm = false;
  HandymanCommissionModel? _editingItem;
  final _nameCtrl = TextEditingController();
  final _commissionCtrl = TextEditingController();
  String _selectedType = 'Percent';
  String _selectedStatus = 'Active';

  @override
  void dispose() {
    _nameCtrl.dispose();
    _commissionCtrl.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(handymanCommissionProvider.notifier).refresh());
  }

  @override
  Widget build(BuildContext context) {
    const bool isMobile = true;
    final state = ref.watch(handymanCommissionProvider);

    return _showForm ? _buildForm(state) : Padding(
      padding: EdgeInsets.only(bottom: isMobile ? 16.0 : 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              decoration: isMobile ? null : BoxDecoration(
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
                      children: isMobile ? [
                        Expanded(child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Wrap(
                                spacing: 8, runSpacing: 8,
                                alignment: WrapAlignment.end,
                                children: [
                                  ElevatedButton.icon(
                                      onPressed: () {
                                        setState(() {
                                          _editingItem = null;
                                          _nameCtrl.clear();
                                          _commissionCtrl.clear();
                                          _selectedType = 'Percent';
                                          _selectedStatus = 'Active';
                                          _showForm = true;
                                        });
                                      },
                                    icon: const Icon(Icons.add, size: 18),
                                    label: const Text('Add Handyman Commission'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF635BFF),
                                      foregroundColor: Colors.white,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8)),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 8),
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
                                setState(() {
                                  _editingItem = null;
                                  _nameCtrl.clear();
                                  _commissionCtrl.clear();
                                  _selectedType = 'Percent';
                                  _selectedStatus = 'Active';
                                  _showForm = true;
                                });
                              },
                              icon: const Icon(Icons.add, size: 18),
                              label: const Text('Add Handyman Commission'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF635BFF),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8)),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Table header
                  if (!isMobile) Container(
                    color: const Color(0xFF635BFF),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    child: const Row(children: [
                      SizedBox(
                          width: 40,
                          child: Icon(
                              Icons.check_box_outline_blank,
                              color: Colors.white,
                              size: 18)),
                      Expanded(
                          child: Text('Name',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13))),
                      Expanded(
                          child: Text('Commission',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13))),
                      Expanded(
                          child: Text('Type',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13))),
                      Expanded(
                          child: Text('Status',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13))),
                      SizedBox(
                          width: 90,
                          child: Text('Action',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13))),
                    ]),
                  ),

                  // Table body
                  Expanded(child: Builder(builder: (context) {
                    if (state.isLoading && state.items.isEmpty) {
                      return const Center(
                          child: CircularProgressIndicator(
                              color: Color(0xFF635BFF)));
                    }
                    if (state.error != null && state.items.isEmpty) {
                      return Center(
                          child: Text('Error: ${state.error}',
                              style:
                                  const TextStyle(color: Colors.red)));
                    }
                    if (state.items.isEmpty) {
                      return const Center(
                          child: Text('No data available in table',
                              style: TextStyle(
                                  color: AppColors.textSecondary)));
                    }
                    return ListView.separated(
                      itemCount: state.items.length,
                      separatorBuilder: (_, __) => MediaQuery.of(context).size.width < 800 ? const SizedBox(height: 8) : const Divider(
                          height: 1, color: AppColors.borderLight),
                      itemBuilder: (context, index) {
                        final item = state.items[index];
                        return _buildRow(item);
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

  void _showDeleteDialog(HandymanCommissionModel item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Commission'),
        content: Text('Delete "${item.name}"?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              ref
                  .read(handymanCommissionProvider.notifier)
                  .delete(item.id);
              Navigator.pop(ctx);
            },
            child: const Text('Delete',
                style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(HandymanCommissionModel item) {
    final isActive = item.status == 1;
    final displayCommission = item.type.toLowerCase() == 'percent'
        ? '${item.commission}%'
        : '₹${item.commission.toStringAsFixed(2)}';

    const bool isMobile = true;
    if (isMobile) {
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
                Expanded(child: Text(item.name, style: const TextStyle(color: Color(0xFF635BFF), fontSize: 16, fontWeight: FontWeight.bold))),
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
            Text('Commission', style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w500)),
            const SizedBox(height: 4),
            Text(displayCommission, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w500)),
            const SizedBox(height: 16),
            const Divider(height: 1, color: AppColors.borderLight),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _editingItem = item;
                      _nameCtrl.text = item.name;
                      _commissionCtrl.text = item.commission.toString();
                      _selectedType = item.type.toLowerCase() == 'fixed' ? 'Fixed' : 'Percent';
                      _selectedStatus = item.status == 1 ? 'Active' : 'Inactive';
                      _showForm = true;
                    });
                  },
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
        const SizedBox(
            width: 40,
            child: Icon(Icons.check_box_outline_blank,
                color: AppColors.borderLight, size: 18)),
        Expanded(
            child: Text(item.name,
                style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                    fontSize: 13))),
        Expanded(
            child: Text(displayCommission,
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 13))),
        Expanded(
            child: Text(item.type,
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 13))),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: isActive
                  ? Colors.green.withValues(alpha: 0.1)
                  : Colors.red.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              isActive ? 'Active' : 'Inactive',
              style: TextStyle(
                  color: isActive ? Colors.green : Colors.red,
                  fontSize: 12,
                  fontWeight: FontWeight.w600),
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
                onTap: () {
                  setState(() {
                    _editingItem = item;
                    _nameCtrl.text = item.name;
                    _commissionCtrl.text = item.commission.toString();
                    _selectedType = item.type.toLowerCase() == 'fixed' ? 'Fixed' : 'Percent';
                    _selectedStatus = item.status == 1 ? 'Active' : 'Inactive';
                    _showForm = true;
                  });
                },
                borderRadius: BorderRadius.circular(6),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.bgLighterPurple,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(Icons.edit_outlined,
                      size: 16, color: AppColors.primary),
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
                  child: const Icon(Icons.delete_outline,
                      size: 16, color: Colors.red),
                ),
              ),
            ),
          ]),
        ),
      ]),
    );
  }

  Widget _buildForm(HandymanCommissionState state) {
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
                  Text(_editingItem != null ? 'Edit Commission' : 'Add New', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primaryDark)),
                  ElevatedButton.icon(
                    onPressed: () => setState(() => _showForm = false),
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Row 1
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isMobile = constraints.maxWidth < 600;
                      if (isMobile) {
                        return Column(
                          children: [
                            _buildField('Name *', 'Name', _nameCtrl),
                            const SizedBox(height: 16),
                            _buildField('Commission *', '0.0', _commissionCtrl),
                          ],
                        );
                      }
                      return Row(
                        children: [
                          Expanded(child: _buildField('Name *', 'Name', _nameCtrl)),
                          const SizedBox(width: 24),
                          Expanded(child: _buildField('Commission *', '0.0', _commissionCtrl)),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  // Row 2
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isMobile = constraints.maxWidth < 600;
                      if (isMobile) {
                        return Column(
                          children: [
                            _buildDropdown('Type *', _selectedType, ['Percent', 'Fixed'], (v) {
                              if (v != null) setState(() => _selectedType = v);
                            }),
                            const SizedBox(height: 16),
                            _buildDropdown('Status *', _selectedStatus, ['Active', 'Inactive'], (v) {
                              if (v != null) setState(() => _selectedStatus = v);
                            }),
                          ],
                        );
                      }
                      return Row(
                        children: [
                          Expanded(child: _buildDropdown('Type *', _selectedType, ['Percent', 'Fixed'], (v) {
                            if (v != null) setState(() => _selectedType = v);
                          })),
                          const SizedBox(width: 24),
                          Expanded(child: _buildDropdown('Status *', _selectedStatus, ['Active', 'Inactive'], (v) {
                            if (v != null) setState(() => _selectedStatus = v);
                          })),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 32),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      onPressed: state.isLoading ? null : () async {
                        if (_nameCtrl.text.isEmpty || _commissionCtrl.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill all required fields', style: TextStyle(color: Colors.white)), backgroundColor: Colors.red));
                          return;
                        }
                        
                        try {
                          if (_editingItem != null) {
                            await ref.read(handymanCommissionProvider.notifier).update(
                              _editingItem!.id,
                              name: _nameCtrl.text.trim(),
                              commission: double.tryParse(_commissionCtrl.text) ?? 0,
                              type: _selectedType,
                              status: _selectedStatus,
                            );
                          } else {
                            await ref.read(handymanCommissionProvider.notifier).add(
                              name: _nameCtrl.text.trim(),
                              commission: double.tryParse(_commissionCtrl.text) ?? 0,
                              type: _selectedType,
                              status: _selectedStatus,
                            );
                          }
                          
                          if (ref.read(handymanCommissionProvider).error == null) {
                            setState(() => _showForm = false);
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
                      child: state.isLoading 
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

  Widget _buildField(String label, String hint, TextEditingController controller) {
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
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(fontSize: 13, color: AppColors.textMuted),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: AppColors.borderLight)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: AppColors.borderLight)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: AppColors.primary)),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown(String label, String value, List<String> items, ValueChanged<String?> onChanged) {
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
              items: items.map((v) => DropdownMenuItem(value: v, child: Text(v, style: const TextStyle(fontSize: 13)))).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}

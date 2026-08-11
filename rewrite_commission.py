import re

with open('lib/screens/handyman/ui/handyman_commission_screen.dart', 'r') as f:
    content = f.read()

# 1. Remove the import for the form screen
content = content.replace("import 'handyman_commission_form_screen.dart';\n", "")

# 2. Add state variables and dispose
state_vars = """
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
"""
content = re.sub(r'(class _HandymanCommissionScreenState extends ConsumerState<HandymanCommissionScreen> \{)', r'\1' + state_vars, content)

# 3. In the toolbar, change the "Add" button to just set _showForm = true
old_add_btn_regex = r'ElevatedButton\.icon\(\s*onPressed: \(\) => Navigator\.of\(context\)\.push\([\s\S]*?padding: const EdgeInsets\.symmetric\([\s\S]*?\),\s*\),'
new_add_btn_mobile = """ElevatedButton.icon(
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
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    ),
                                  ),"""
new_add_btn_desktop = """ElevatedButton.icon(
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
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              ),
                            ),"""

# We have two occurrences of the old add button (one mobile, one desktop). We replace them one by one.
occurrences = re.finditer(old_add_btn_regex, content)
occ_list = list(occurrences)
if len(occ_list) == 2:
    content = content[:occ_list[0].start()] + new_add_btn_mobile + content[occ_list[0].end():occ_list[1].start()] + new_add_btn_desktop + content[occ_list[1].end():]

# 4. Modify the build method to show _buildForm if _showForm is true.
# Instead of Column with children [ Expanded(...) ], we do _showForm ? _buildForm() : Column(...)
build_start = content.find('return Padding(')
build_end_match = re.search(r'\);\n  }\n\n  void _showDeleteDialog', content)
build_end = build_end_match.start() + 2

original_return = content[build_start:build_end]
new_return = f"return _showForm ? _buildForm(state) : {original_return[7:]}"
content = content[:build_start] + new_return + content[build_end:]

# 5. In _buildRow, update the Edit button logic to populate form and show it.
edit_regex = r'InkWell\(\s*onTap: \(\) => Navigator\.of\(context\)\.push\([\s\S]*?child: const Icon\(Icons\.edit_outlined, size: 16, color: Colors\.blue\),'
new_edit = """InkWell(
                onTap: () {
                  setState(() {
                    _editingItem = item;
                    _nameCtrl.text = item.name;
                    _commissionCtrl.text = item.commission.toString();
                    _selectedType = item.type;
                    _selectedStatus = item.status == 1 ? 'Active' : 'Inactive';
                    _showForm = true;
                  });
                },
                borderRadius: BorderRadius.circular(6),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(Icons.edit_outlined, size: 16, color: Colors.blue),"""

content = re.sub(edit_regex, new_edit, content)

# 6. Add _buildForm method at the end of the class.
form_method = """
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
"""
content = content[:content.rfind('}')] + form_method + '}\n'

with open('lib/screens/handyman/ui/handyman_commission_screen.dart', 'w') as f:
    f.write(content)

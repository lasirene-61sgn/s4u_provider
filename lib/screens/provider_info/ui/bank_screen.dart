import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/image_viewer.dart';
import '../../../core/api/api_client.dart';
import '../riverpod/bank_notifier.dart';

class BankScreen extends ConsumerStatefulWidget {
  final dynamic profile;
  const BankScreen({super.key, required this.profile});

  @override
  ConsumerState<BankScreen> createState() => _BankScreenState();
}

class _BankScreenState extends ConsumerState<BankScreen> {
  bool get _isMobile => MediaQuery.of(context).size.width < 800;
  bool _showAddBankForm = false;

  final _bankNameCtrl = TextEditingController();
  final _branchNameCtrl = TextEditingController();
  final _accountNumberCtrl = TextEditingController();
  final _ifscCodeCtrl = TextEditingController();
  String _bankStatus = 'Active';
  int? _editingBankId;

  @override
  void dispose() {
    _bankNameCtrl.dispose();
    _branchNameCtrl.dispose();
    _accountNumberCtrl.dispose();
    _ifscCodeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bankState = ref.watch(bankProvider);

    return _showAddBankForm ? _buildAddBankForm(bankState) : _buildBankList(bankState);
  }

  Widget _buildBankList(BankState bankState) {
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
                                      _bankNameCtrl.clear();
                                      _branchNameCtrl.clear();
                                      _accountNumberCtrl.clear();
                                      _ifscCodeCtrl.clear();
                                      _bankStatus = 'Active';
                                      _editingBankId = null;
                                      setState(() => _showAddBankForm = true);
                                    },
                                    icon: const Icon(Icons.add, size: 18),
                                    label: const Text('Add Bank'),
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
                                _bankNameCtrl.clear();
                                _branchNameCtrl.clear();
                                _accountNumberCtrl.clear();
                                _ifscCodeCtrl.clear();
                                _bankStatus = 'Active';
                                _editingBankId = null;
                                setState(() => _showAddBankForm = true);
                              },
                              icon: const Icon(Icons.add, size: 18),
                              label: const Text('Add Bank'),
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
                      Expanded(flex: 2, child: Text('Bank Details', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13))),
                      Expanded(child: Text('Status', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13))),
                      SizedBox(width: 90, child: Text('Action', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13))),
                    ]),
                  ),

                  // Table body
                  Expanded(child: Builder(builder: (context) {
                    if (bankState.isLoading && bankState.banks.isEmpty && bankState.deletingBankId == null) {
                      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                    }
                    if (bankState.error != null && bankState.banks.isEmpty) {
                      return Center(child: Text('Error: ${bankState.error}', style: const TextStyle(color: Colors.red)));
                    }
                    if (bankState.banks.isEmpty) {
                      return const Center(child: Text('No banks added yet.', style: TextStyle(color: AppColors.textSecondary)));
                    }
                    return ListView.separated(
                      itemCount: bankState.banks.length,
                      separatorBuilder: (_, __) => _isMobile ? const SizedBox(height: 8) : const Divider(height: 1, color: AppColors.borderLight),
                      itemBuilder: (context, index) {
                        final item = bankState.banks[index];
                        return _buildRow(item, bankState);
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
        title: const Text('Delete Bank'),
        content: const Text('Are you sure you want to delete this bank?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              ref.read(bankProvider.notifier).deleteBank(item.id);
              Navigator.pop(ctx);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _editBank(dynamic item) {
    _bankNameCtrl.text = item.bankName ?? '';
    _branchNameCtrl.text = item.branchName ?? '';
    _accountNumberCtrl.text = item.accountNo ?? '';
    _ifscCodeCtrl.text = item.ifscNo ?? '';
    _bankStatus = item.status == 1 ? 'Active' : 'Inactive';
    _editingBankId = item.id;
    setState(() => _showAddBankForm = true);
  }

  Widget _buildRow(dynamic item, BankState bankState) {
    final isActive = item.status == 1;
    final profile = widget.profile;
    
    final bankDetailsWidget = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(item.bankName, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.bold)),
        Text('Branch: ${item.branchName}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
        Text('A/c: ${item.accountNo}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
        if (item.ifscNo != null && item.ifscNo!.isNotEmpty)
          Text('IFSC: ${item.ifscNo}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
      ],
    );

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
            const Text('Bank Details', style: TextStyle(color: AppColors.primaryDark, fontSize: 13, fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            bankDetailsWidget,
            const SizedBox(height: 16),
            const Divider(height: 1, color: AppColors.borderLight),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _editBank(item),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.bgLighterPurple, foregroundColor: AppColors.primary, elevation: 0, padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                  icon: const Icon(Icons.edit_outlined, size: 16), label: const Text('Edit'),
                ),
                const SizedBox(width: 8),
                bankState.deletingBankId == item.id
                    ? const Padding(padding: EdgeInsets.all(8), child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.red)))
                    : ElevatedButton.icon(
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
        Expanded(flex: 2, child: bankDetailsWidget),
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
                onTap: () => _editBank(item),
                borderRadius: BorderRadius.circular(6),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  child: const Icon(Icons.edit, size: 16, color: AppColors.textSecondary),
                ),
              ),
            ),
            const SizedBox(width: 8),
            bankState.deletingBankId == item.id
                ? const Padding(padding: EdgeInsets.all(6), child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.red)))
                : Tooltip(
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

  Widget _buildAddBankForm(BankState bankState) {
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
                  Text(_editingBankId != null ? 'Edit Bank' : 'Add New Bank', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primaryDark)),
                  ElevatedButton.icon(
                    onPressed: () => setState(() => _showAddBankForm = false),
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
                            _buildField('Bank Name *', 'Bank Name', _bankNameCtrl),
                            const SizedBox(height: 16),
                            _buildField('Branch Name *', 'Branch Name', _branchNameCtrl),
                            const SizedBox(height: 16),
                            _buildField('Account Number *', 'Account Number', _accountNumberCtrl),
                            const SizedBox(height: 16),
                            _buildField('IFSC Code', 'IFSC Code', _ifscCodeCtrl),
                            const SizedBox(height: 16),
                            _buildStatusDropdown(),
                          ],
                        )
                      : Column(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(child: _buildField('Bank Name *', 'Bank Name', _bankNameCtrl)),
                                const SizedBox(width: 24),
                                Expanded(child: _buildField('Branch Name *', 'Branch Name', _branchNameCtrl)),
                              ],
                            ),
                            const SizedBox(height: 24),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(child: _buildField('Account Number *', 'Account Number', _accountNumberCtrl)),
                                const SizedBox(width: 24),
                                Expanded(child: _buildField('IFSC Code', 'IFSC Code', _ifscCodeCtrl)),
                              ],
                            ),
                            const SizedBox(height: 24),
                            Row(
                              children: [
                                Expanded(child: _buildStatusDropdown()),
                                const Expanded(child: SizedBox()), // spacer to keep it aligned
                              ],
                            ),
                          ],
                        ),
                  const SizedBox(height: 32),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      onPressed: bankState.isLoading ? null : () async {
                        if (_bankNameCtrl.text.isEmpty || _branchNameCtrl.text.isEmpty || _accountNumberCtrl.text.isEmpty || _ifscCodeCtrl.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill all required fields', style: TextStyle(color: Colors.white)), backgroundColor: Colors.red));
                          return;
                        }
                        
                        final req = {
                          'bank_name': _bankNameCtrl.text,
                          'branch_name': _branchNameCtrl.text,
                          'account_no': _accountNumberCtrl.text,
                          'ifsc_no': _ifscCodeCtrl.text,
                          'status': _bankStatus == 'Active' ? 1 : 0,
                        };
                        
                        try {
                          if (_editingBankId != null) {
                            req['id'] = _editingBankId!;
                          }
                          await ref.read(bankProvider.notifier).addBank(req);
                          if (ref.read(bankProvider).error == null) {
                            setState(() {
                              _showAddBankForm = false;
                              _bankNameCtrl.clear();
                              _branchNameCtrl.clear();
                              _accountNumberCtrl.clear();
                              _ifscCodeCtrl.clear();
                              _bankStatus = 'Active';
                            });
                          }
                        } catch (e) {
                          // error is handled in notifier with toast
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                      ),
                      child: bankState.isLoading 
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

  Widget _buildStatusDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Status *', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.primaryDark)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.borderLight),
            borderRadius: BorderRadius.circular(8),
            color: const Color(0xFFF8F9FA),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _bankStatus,
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
              items: ['Active', 'Inactive'].map((String value) {
                return DropdownMenuItem<String>(value: value, child: Text(value, style: const TextStyle(fontSize: 14)));
              }).toList(),
              onChanged: (newValue) {
                if (newValue != null) setState(() => _bankStatus = newValue);
              },
            ),
          ),
        ),
      ],
    );
  }
}

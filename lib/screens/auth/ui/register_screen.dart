import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../riverpod/register_notifier.dart';
import '../../handyman/riverpod/handyman_commission_notifier.dart';
import '../../commission/riverpod/provider_commission_notifier.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _usernameCtrl = TextEditingController();
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _mobileCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();
  final _designationCtrl = TextEditingController();
  
  String _userType = 'Provider';
  int? _selectedProviderId;
  String? _selectedCommission;
  bool _agreedToTerms = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(registerProvider.notifier).loadProviders();
      ref.read(providerCommissionProvider.notifier).loadData();
    });
  }

  void _submit() {
    if (_passCtrl.text != _confirmPassCtrl.text) {
      Get.snackbar('Error', 'Passwords do not match');
      return;
    }
    if (!_agreedToTerms) {
      Get.snackbar('Error', 'You must agree to the Terms of Service & Privacy Policy');
      return;
    }
    
    ref.read(registerProvider.notifier).register(
      username: _usernameCtrl.text,
      firstName: _firstNameCtrl.text,
      lastName: _lastNameCtrl.text,
      email: _emailCtrl.text,
      password: _passCtrl.text,
      contactNumber: _mobileCtrl.text,
      role: _userType.toLowerCase(),
      userCommission: _selectedCommission ?? '',
      designation: _designationCtrl.text,
      providerId: _selectedProviderId,
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {bool obscure = false, String? hint}) {
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
        const SizedBox(height: 6),
        SizedBox(
          height: 40,
          child: TextField(
            controller: controller,
            obscureText: obscure,
            style: const TextStyle(fontSize: 13),
            decoration: InputDecoration(
              hintText: hint ?? 'Enter ${label.replaceAll(' *', '')}',
              hintStyle: const TextStyle(fontSize: 12, color: AppColors.textMuted),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: const BorderSide(color: AppColors.borderLight)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: const BorderSide(color: AppColors.borderLight)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: const BorderSide(color: AppColors.primary)),
            ),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(registerProvider);
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primaryDark),
          onPressed: () => Get.back(),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Logo & Header
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        child: Image.asset('assets/s4u_logo.jpeg', fit: BoxFit.contain),
                      ),
                      const SizedBox(height: 16),
                      const Text('Get started', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryDark)),
                    ],
                  ),
                ),
                const SizedBox(height: 24),



                _buildTextField('Username *', _usernameCtrl),
                _buildTextField('First Name *', _firstNameCtrl),
                _buildTextField('Last Name *', _lastNameCtrl),
                _buildTextField('Email *', _emailCtrl),
                _buildTextField('Contact Number *', _mobileCtrl),
                _buildTextField('Password *', _passCtrl, obscure: true),
                _buildTextField('Confirm Password *', _confirmPassCtrl, obscure: true),

                // User Type Dropdown
                const Text('User Type *', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                const SizedBox(height: 6),
                Container(
                  height: 40,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(border: Border.all(color: AppColors.primary), borderRadius: BorderRadius.circular(4)),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: _userType,
                      icon: const Icon(Icons.arrow_drop_down, color: AppColors.primary),
                      items: ['Provider', 'Handyman'].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value, style: const TextStyle(fontSize: 13, color: AppColors.primaryDark)),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setState(() {
                          _userType = val!;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Provider Dropdown (if Handyman)
                if (_userType == 'Handyman') ...[
                  const Text('Provider', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                  const SizedBox(height: 6),
                  state.providers.isEmpty
                      ? Container(
                          height: 40,
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3F4F6),
                            border: Border.all(color: AppColors.borderLight),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Row(
                            children: [
                              SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary)),
                              SizedBox(width: 8),
                              Text('Loading providers...', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                            ],
                          ),
                        )
                      : Container(
                          height: 40,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.borderLight),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<int>(
                              isExpanded: true,
                              value: _selectedProviderId,
                              hint: const Text('Select Provider', style: TextStyle(fontSize: 13, color: AppColors.textMuted)),
                              items: state.providers.map((p) {
                                final displayName = (p['display_name'] ?? '').toString();
                                final owner = ((p['first_name'] ?? '').toString() + ' ' + (p['last_name'] ?? '').toString()).trim();
                                return DropdownMenuItem<int>(
                                  value: (p['id'] as num).toInt(),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(displayName, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primaryDark)),
                                      if (owner.isNotEmpty && owner != displayName)
                                        Text(owner, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                                    ],
                                  ),
                                );
                              }).toList(),
                              onChanged: (val) {
                                setState(() {
                                  _selectedProviderId = val;
                                  _selectedCommission = null; // reset commission
                                });
                                if (val != null) {
                                  ref.read(handymanCommissionProvider.notifier).fetchByProviderId(val);
                                }
                              },
                            ),
                          ),
                        ),
                  const SizedBox(height: 12),
                ],

                // User Commission Dropdown - only for Handyman
                if (_userType == 'Handyman') ...[
                  const Text('User Commission *', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                  const SizedBox(height: 6),
                  Builder(builder: (context) {
                    final commState = ref.watch(handymanCommissionProvider);
                    if (commState.isLoading) {
                      return Container(
                        height: 40,
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F4F6),
                          border: Border.all(color: AppColors.borderLight),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Row(
                          children: [
                            SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary)),
                            SizedBox(width: 8),
                            Text('Loading commissions...', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                          ],
                        ),
                      );
                    }
                    final items = commState.items;
                    return Container(
                      height: 40,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.borderLight),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          isExpanded: true,
                          value: items.any((c) => c.name == _selectedCommission) ? _selectedCommission : null,
                          hint: const Text('Select Commission', style: TextStyle(fontSize: 13, color: AppColors.textMuted)),
                          items: items.map((c) {
                            final label = c.type.toLowerCase() == 'percent'
                                ? '${c.name} (${c.commission}%)'
                                : '${c.name} (₹${c.commission.toStringAsFixed(2)})';
                            return DropdownMenuItem<String>(
                              value: c.name,
                              child: Text(label, style: const TextStyle(fontSize: 13)),
                            );
                          }).toList(),
                          onChanged: (val) => setState(() => _selectedCommission = val),
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 12),
                ],

                // Provider Commission Dropdown - only for Provider
                if (_userType == 'Provider') ...[
                  const Text('Commission *', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                  const SizedBox(height: 6),
                  Builder(builder: (context) {
                    final commState = ref.watch(providerCommissionProvider);
                    if (commState.isLoading) {
                      return Container(
                        height: 40,
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F4F6),
                          border: Border.all(color: AppColors.borderLight),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Row(
                          children: [
                            SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary)),
                            SizedBox(width: 8),
                            Text('Loading commissions...', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                          ],
                        ),
                      );
                    }
                    final items = commState.commissions;
                    return Container(
                      height: 40,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.borderLight),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          isExpanded: true,
                          value: items.any((c) => c.name == _selectedCommission) ? _selectedCommission : null,
                          hint: const Text('Select Commission', style: TextStyle(fontSize: 13, color: AppColors.textMuted)),
                          items: items.map((c) {
                            final label = c.type.toLowerCase() == 'percent'
                                ? '${c.name} (${c.commission}%)'
                                : '${c.name} (₹${c.commission.toStringAsFixed(2)})';
                            return DropdownMenuItem<String>(
                              value: c.name,
                              child: Text(label, style: const TextStyle(fontSize: 13)),
                            );
                          }).toList(),
                          onChanged: (val) => setState(() => _selectedCommission = val),
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 12),
                ],

                _buildTextField('Designation', _designationCtrl, hint: 'e.g. Manager'),

                // Terms checkbox
                Row(
                  children: [
                    SizedBox(
                      height: 24,
                      width: 24,
                      child: Checkbox(
                        value: _agreedToTerms,
                        onChanged: (v) => setState(() => _agreedToTerms = v ?? false),
                        activeColor: const Color(0xFF635BFF),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text('I agree to the ', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                    const Text('Terms Of Service', style: TextStyle(fontSize: 11, color: Color(0xFF635BFF))),
                    const Text(' & ', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                    const Text('Privacy Policy', style: TextStyle(fontSize: 11, color: Color(0xFF635BFF))),
                  ],
                ),
                const SizedBox(height: 24),

                if (state.isLoading) 
                  const Center(child: CircularProgressIndicator(color: Color(0xFF635BFF)))
                else
                  ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF635BFF),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 44),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                    ),
                    child: const Text('Create Account', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                  ),
                
                const SizedBox(height: 16),
                Center(
                  child: InkWell(
                    onTap: () => Get.back(),
                    child: const Text(
                      'Already Have Account? Sign In',
                      style: TextStyle(fontSize: 12, color: Color(0xFF635BFF), fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

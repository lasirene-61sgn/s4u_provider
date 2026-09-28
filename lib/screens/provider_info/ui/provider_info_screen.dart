import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/image_viewer.dart';
import '../../../core/api/api_client.dart';
import '../../handyman/riverpod/handyman_ratings_notifier.dart';
import '../../profile/riverpod/profile_notifier.dart';
import '../../../core/storage/shared_preference_helper.dart';
import '../../profile/riverpod/time_slot_notifier.dart';
import '../riverpod/bank_notifier.dart';
import 'bank_screen.dart';
import '../riverpod/address_notifier.dart';
import '../riverpod/document_notifier.dart';
import '../riverpod/review_notifier.dart';
import 'address_screen.dart';
import 'document_screen.dart';
import '../../handyman/riverpod/handyman_notifier.dart';
import '../../handyman/riverpod/handyman_commission_notifier.dart';
import '../../handyman/ui/handyman_commission_screen.dart';
import '../../bookings/ui/bookings_screen.dart';
import '../../earnings/ui/payments_screen.dart';
import '../../handyman/riverpod/handyman_earning_notifier.dart';

class ProviderInfoScreen extends ConsumerStatefulWidget {
  final Function(int)? onNavigate;
  const ProviderInfoScreen({super.key, this.onNavigate});

  @override
  ConsumerState<ProviderInfoScreen> createState() => _ProviderInfoScreenState();
}

class _ProviderInfoScreenState extends ConsumerState<ProviderInfoScreen> {
  bool get _isMobile => MediaQuery.of(context).size.width < 800;

  int _selectedTab = 0;
  String _role = 'PROVIDER';
  bool _showAddBankForm = false;
  bool _showAddAddressForm = false;
  bool _showAddDocumentForm = false;
  bool _showAddCommissionForm = false;

  // Commission form state
  final _commissionNameCtrl = TextEditingController();
  final _commissionValueCtrl = TextEditingController();
  String _commissionType = 'Percent';
  String _commissionStatus = 'ACTIVE';

  // Address form state
  final _latitudeCtrl = TextEditingController();
  final _longitudeCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  String _addressStatus = 'Active';

  // Document form state
  String? _selectedDocumentType;
  String _documentPath = '';
  
  // Profile form state
  late TextEditingController _firstNameCtrl;
  late TextEditingController _lastNameCtrl;
  late TextEditingController _usernameCtrl;
  late TextEditingController _designationCtrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _mobileCtrl;
  late TextEditingController _companyNameCtrl;
  late TextEditingController _gstCtrl;
  late TextEditingController _cityCtrl;
  late TextEditingController _stateCtrl;
  late TextEditingController _countryCtrl;
  late TextEditingController _selectAddressCtrl;
  late TextEditingController _commissionCtrl;
  bool _controllersInitialized = false;

  // Change password form state
  final _oldPassCtrl = TextEditingController();
  final _newPassCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();
  bool _obscureOldPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  bool _isUpdating = false;

  // Time Slot state
  String _selectedDay = 'MON';
  List<String> _selectedTimes = [];
  bool _timesLoadedForDay = false;

  List<String> get _tabs => _role == 'HANDYMAN' 
      ? ['OVERVIEW', 'PAYOUT LIST'] 
      : [
    'OVERVIEW',
    'BOOKINGS',
    'HANDYMAN',
    'COMMISSION',
    'REVIEWS',
    'DOCUMENT LIST',
    'PAYOUT LIST',
    'ADDRESS LIST',
    'BANK LIST',
    'SLOT LIST',
  ];

  @override
  void initState() {
    super.initState();
    _role = SharedPreferenceHelper.getString('role') ?? 'PROVIDER';
    _firstNameCtrl = TextEditingController();
    _lastNameCtrl = TextEditingController();
    _usernameCtrl = TextEditingController();
    _designationCtrl = TextEditingController();
    _emailCtrl = TextEditingController();
    _mobileCtrl = TextEditingController();
    _companyNameCtrl = TextEditingController();
    _gstCtrl = TextEditingController();
    _cityCtrl = TextEditingController();
    _stateCtrl = TextEditingController();
    _countryCtrl = TextEditingController();
    _selectAddressCtrl = TextEditingController();
    _commissionCtrl = TextEditingController();

    Future.microtask(() {
      ref.read(profileProvider.notifier).refresh();
      if (_role == 'HANDYMAN') {
        ref.read(handymanEarningListProvider.notifier).refresh();
      }
    });
  }

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _usernameCtrl.dispose();
    _designationCtrl.dispose();
    _emailCtrl.dispose();
    _mobileCtrl.dispose();
    _addressCtrl.dispose();
    _companyNameCtrl.dispose();
    _gstCtrl.dispose();
    _cityCtrl.dispose();
    _stateCtrl.dispose();
    _countryCtrl.dispose();
    _selectAddressCtrl.dispose();
    _commissionCtrl.dispose();
    _oldPassCtrl.dispose();
    _newPassCtrl.dispose();
    _confirmPassCtrl.dispose();
    super.dispose();
  }

  void _populateControllers(profile) {
    if (!_controllersInitialized && profile != null) {
      _firstNameCtrl.text = profile.firstName ?? '';
      _lastNameCtrl.text = profile.lastName ?? '';
      _usernameCtrl.text = profile.username ?? '';
      _designationCtrl.text = profile.role ?? '';
      _emailCtrl.text = profile.email ?? '';
      _mobileCtrl.text = profile.mobile ?? '';
      _addressCtrl.text = profile.address ?? '';
      _companyNameCtrl.text = profile.companyName ?? '';
      _gstCtrl.text = profile.gstNumber ?? '';
      _cityCtrl.text = profile.city ?? '';
      _stateCtrl.text = profile.state ?? '';
      _countryCtrl.text = profile.country ?? '';
      _selectAddressCtrl.text = profile.selectAddress ?? '';
      _commissionCtrl.text = profile.handymanCommission ?? '';
      _controllersInitialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileProvider);
    final bankState = ref.watch(bankProvider);
    final addressState = ref.watch(addressProvider);
    final reviewState = ref.watch(handymanRatingsProvider);
    final earningState = _role == 'HANDYMAN' ? ref.watch(handymanEarningListProvider) : null;
    final profile = profileState.profile;

    if (profile != null && !_controllersInitialized) {
      _populateControllers(profile);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [


        // Tab Bar
        Container(
          color: AppColors.backgroundScaffold,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(_tabs.length, (i) {
                final isSelected = _selectedTab == i;
                return GestureDetector(
                  onTap: () {
                    final tabName = _tabs[i];
                    setState(() {
                      _selectedTab = i;
                    });
                    
                    if (tabName == 'ADDRESS LIST') {
                      ref.read(addressProvider.notifier).fetchAddresses();
                    } else if (tabName == 'SLOT LIST') {
                      setState(() {
                        _timesLoadedForDay = false;
                      });
                      ref.read(timeSlotProvider.notifier).fetchSlots();
                    } else if (tabName == 'DOCUMENT LIST') {
                      ref.read(documentProvider.notifier).fetchDocuments();
                      ref.read(documentProvider.notifier).fetchDocumentTypes();
                    } else if (tabName == 'HANDYMAN') {
                      ref.read(handymenProvider.notifier).refresh();
                    } else if (tabName == 'COMMISSION') {
                      ref.read(handymanCommissionProvider.notifier).refresh();
                    } else if (tabName == 'BANK LIST') {
                      ref.read(bankProvider.notifier).fetchBanks();
                    } else if (tabName == 'REVIEWS') {
                      ref.read(handymanRatingsProvider.notifier).loadRatings();
                    }
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : const Color(0xFFEAE9F9),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      _tabs[i],
                      style: TextStyle(
                        color: isSelected ? Colors.white : AppColors.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),

        // Content
        Expanded(
          child: profileState.isLoading && profile == null
              ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
              : _buildTabContent(profile, bankState, addressState, reviewState, ref.watch(handymenProvider), ref.watch(handymanCommissionProvider), earningState),
        ),
      ],
    );
  }

  Widget _buildTabContent(dynamic profile, BankState bankState, AddressState addressState, HandymanRatingsState reviewState, HandymanState handymanState, HandymanCommissionState commissionState, dynamic earningState) {
    final safeIndex = _selectedTab >= _tabs.length ? 0 : _selectedTab;
    final tabName = _tabs[safeIndex];
    switch (tabName) {
      case 'OVERVIEW': return _buildOverviewTab(profile, earningState);
      case 'BOOKINGS': return const BookingsScreen();
      case 'BANK LIST': return BankScreen(profile: profile);
      case 'SLOT LIST': return _buildTimeSlotTab(profile);
      case 'ADDRESS LIST': return const AddressScreen();
      case 'DOCUMENT LIST': return DocumentScreen(profile: profile);
      case 'PAYOUT LIST': return const PaymentsScreen();
      case 'REVIEWS': return _buildReviewTab(profile, reviewState);
      case 'HANDYMAN': return _buildHandymanTab(profile, handymanState);
      case 'COMMISSION': return const HandymanCommissionScreen();
      default: return _buildComingSoon(tabName);
    }
  }

  // ─────────────────────── OVERVIEW TAB ───────────────────────

  Widget _buildOverviewTab(dynamic profile, dynamic earningState) {
    final imageUrl = profile?.profileImage != null
        ? (profile!.profileImage!.startsWith('http')
            ? profile.profileImage!
            : ApiClient.baseUrl.replaceAll('/api', '') + profile.profileImage!)
        : null;

    final earning = (earningState != null && earningState.earnings.isNotEmpty) ? earningState.earnings.first : null;
    final String withdrawlPending = earning != null ? '₹${earning.payDue}' : '₹0.00';
    final String alreadyWithdrawn = earning != null ? '₹${earning.paidAmount}' : '₹0.00';
    final String totalBooking = earning != null ? earning.bookingCount : '0';
    final String walletBalance = earning != null ? '₹${earning.totalEarning}' : '₹0.00';

    return LayoutBuilder(builder: (context, constraints) {
      
      return SingleChildScrollView(
        padding: EdgeInsets.all(_isMobile ? 16 : 24),
        child: Column(
          children: [
          // Stats Grid
          if (_isMobile)
            Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        label: 'Withdrawl Pending',
                        value: withdrawlPending,
                        valueColor: AppColors.primary,
                        bgColor: const Color(0xFFF3F0FF),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildStatCard(
                        label: 'Already Withdrawn',
                        value: alreadyWithdrawn,
                        valueColor: AppColors.success,
                        bgColor: const Color(0xFFF0FFF4),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        label: 'Total Booking',
                        value: totalBooking,
                        valueColor: AppColors.orange,
                        bgColor: const Color(0xFFFFFBF0),
                        onTap: () {
                          if (widget.onNavigate != null) {
                            widget.onNavigate!(1);
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildStatCard(
                        label: 'Wallet Balance',
                        value: walletBalance,
                        valueColor: Colors.red,
                        bgColor: const Color(0xFFFFF0F0),
                      ),
                    ),
                  ],
                ),
                Container(
                  height: 250,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.borderLight),
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Booking Overview',
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.primaryDark),
                      ),
                      const Spacer(),
                      Center(
                        child: Text(
                          'No data available',
                          style: TextStyle(color: Colors.green.shade400, fontSize: 13, fontStyle: FontStyle.italic),
                        ),
                      ),
                      const Spacer(),
                    ],
                  ),
                ),
              ],
            )
          else
            IntrinsicHeight(
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _buildStatCard(
                                label: 'Withdrawl Pending',
                                value: withdrawlPending,
                                valueColor: AppColors.primary,
                                bgColor: const Color(0xFFF3F0FF),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildStatCard(
                                label: 'Already Withdrawn',
                                value: alreadyWithdrawn,
                                valueColor: AppColors.success,
                                bgColor: const Color(0xFFF0FFF4),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _buildStatCard(
                                label: 'Total Booking',
                                value: totalBooking,
                                valueColor: AppColors.orange,
                                bgColor: const Color(0xFFFFFBF0),
                                onTap: () {
                                  if (widget.onNavigate != null) {
                                    widget.onNavigate!(1);
                                  }
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildStatCard(
                                label: 'Wallet Balance',
                                value: walletBalance,
                                valueColor: Colors.red,
                                bgColor: const Color(0xFFFFF0F0),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Booking Overview Chart Panel
                  Expanded(
                    flex: 2,
                    child: Container(
                      height: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.borderLight),
                      ),
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Booking Overview',
                            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.primaryDark),
                          ),
                          const Spacer(),
                          Center(
                            child: Text(
                              'No data available',
                              style: TextStyle(color: Colors.green.shade400, fontSize: 13, fontStyle: FontStyle.italic),
                            ),
                          ),
                          const Spacer(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 24),

          // Provider Info Card
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(_isMobile ? 16 : 24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 24,
              runSpacing: 16,
              children: [
                // Avatar
                GestureDetector(
                  onTap: () {
                    if (imageUrl != null) ImageViewer.show(context, NetworkImage(imageUrl));
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: imageUrl != null
                        ? Image.network(
                            imageUrl,
                            width: 90,
                            height: 90,
                            fit: BoxFit.cover,
                            errorBuilder: (ctx, e, s) => _avatarFallback(),
                          )
                        : _avatarFallback(),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profile != null ? '${profile.firstName} ${profile.lastName}'.trim() : 'Provider',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryDark),
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow(Icons.phone_outlined, profile?.mobile ?? '—'),
                    const SizedBox(height: 8),
                    _buildInfoRow(Icons.email_outlined, profile?.email ?? '—'),
                    const SizedBox(height: 8),
                    _buildInfoRow(Icons.location_on_outlined, profile?.address ?? '—'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  });
  }

  Widget _avatarFallback() {
    return Container(
      width: 90,
      height: 90,
      decoration: const BoxDecoration(color: AppColors.bgLighterPurple),
      child: const Icon(Icons.storefront_rounded, color: AppColors.primary, size: 40),
    );
  }

  Widget _buildStatCard({
    required String label,
    required String value,
    required Color valueColor,
    required Color bgColor,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 100,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: valueColor)),
            ),
            const Spacer(),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textMuted),
        const SizedBox(width: 8),
        Text(text, style: const TextStyle(fontSize: 13, color: AppColors.textMuted)),
      ],
    );
  }



  // ─────────────────────── TIME SLOT TAB ───────────────────────

  // ─────────────────────── REVIEW TAB ───────────────────────

  Widget _buildReviewTab(dynamic profile, HandymanRatingsState reviewState) {
    final reviews = reviewState.ratings;
    return Padding(
      padding: EdgeInsets.only(bottom: _isMobile ? 16.0 : 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              decoration: _isMobile ? null : BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.borderLight)),
              child: Column(
                children: [
                  if (!_isMobile) Container(
                    color: const Color(0xFF635BFF),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: const Row(
                      children: [
                        Expanded(child: Text('Customer', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13))),
                        Expanded(child: Text('Rating', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13))),
                        Expanded(flex: 2, child: Text('Review', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13))),
                        Expanded(child: Text('Date', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13))),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Builder(
                      builder: (context) {
                        if (reviewState.isLoading && reviews.isEmpty) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        if (reviews.isEmpty) {
                          return const Center(child: Text('No reviews found', style: TextStyle(color: AppColors.textSecondary)));
                        }
                        
                        return ListView.separated(
                          itemCount: reviews.length,
                          separatorBuilder: (_, __) => _isMobile ? const SizedBox(height: 8) : const Divider(height: 1, color: AppColors.borderLight),
                          itemBuilder: (context, index) {
                            final review = reviews[index];
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
                                        Text(review.customerName, style: const TextStyle(color: Color(0xFF635BFF), fontSize: 16, fontWeight: FontWeight.bold)),
                                        Row(
                                          children: List.generate(5, (index) {
                                            return Icon(
                                              index < review.rating ? Icons.star : Icons.star_border,
                                              color: Colors.amber,
                                              size: 16,
                                            );
                                          }),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Text(review.review, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        const Icon(Icons.calendar_today_outlined, size: 16, color: AppColors.textSecondary),
                                        const SizedBox(width: 8),
                                        Text(review.createdAt.split(' ').first, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            }
                            
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              child: Row(
                                children: [
                                  Expanded(child: Text(review.customerName, style: const TextStyle(fontSize: 13))),
                                  Expanded(child: Row(
                                    children: List.generate(5, (index) {
                                      return Icon(
                                        index < review.rating ? Icons.star : Icons.star_border,
                                        color: Colors.amber,
                                        size: 16,
                                      );
                                    }),
                                  )),
                                  Expanded(flex: 2, child: Text(review.review, style: const TextStyle(fontSize: 13))),
                                  Expanded(child: Text(review.createdAt.split(' ').first, style: const TextStyle(fontSize: 13, color: AppColors.textMuted))),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────── COMMISSION TAB ───────────────────────

  // ─────────────────────── HANDYMAN TAB ───────────────────────

  Widget _buildHandymanTab(dynamic profile, HandymanState handymanState) {
    final handymen = handymanState.handymen;
    
    if (handymanState.isLoading && handymen.isEmpty) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }
    
    if (handymen.isEmpty) {
      return const Center(child: Text('No handymen added yet.', style: TextStyle(color: Colors.grey)));
    }
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Wrap(
        spacing: 24,
        runSpacing: 24,
        children: handymen.map((handyman) {
          final name = handyman.name;
          final mobile = handyman.mobile;
          final email = handyman.email;
          final profileImg = handyman.profileImage;
          
          return Container(
            width: 250,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 2))],
            ),
            child: Column(
              children: [
                GestureDetector(
                  onTap: () {
                    if (profileImg != null) ImageViewer.show(context, NetworkImage(profileImg.startsWith('http') ? profileImg : ApiClient.baseUrl.replaceAll('/api', '') + profileImg));
                  },
                  child: CircleAvatar(
                    radius: 32,
                    backgroundColor: Colors.grey[200],
                    backgroundImage: profileImg != null ? NetworkImage(profileImg.startsWith('http') ? profileImg : ApiClient.baseUrl.replaceAll('/api', '') + profileImg) : null,
                    child: profileImg == null ? const Icon(Icons.person, size: 32, color: Colors.grey) : null,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  name.isEmpty ? 'Unknown' : name,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primaryDark),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  mobile,
                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  email,
                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                const Text(
                  '-',
                  style: TextStyle(fontSize: 13, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTimeSlotTab(dynamic profile) {
    final days = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
    final times = List.generate(24, (i) => '${i.toString().padLeft(2, '0')}:00');

    final timeSlotState = ref.watch(timeSlotProvider);
    
    if (!_timesLoadedForDay && !timeSlotState.isLoading) {
      final match = timeSlotState.savedSlots.where((s) => s.day.toLowerCase() == _selectedDay.toLowerCase()).firstOrNull;
      if (match != null) {
        _selectedTimes = List.from(match.times);
      } else {
        _selectedTimes = [];
      }
      _timesLoadedForDay = true;
    }

    final providerName = profile != null ? '${profile.firstName} ${profile.lastName}' : 'Provider';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header with Back button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('$providerName Time Slot', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primaryDark)),
                  ElevatedButton.icon(
                    onPressed: () => setState(() => _selectedTab = 0),
                    icon: const Icon(Icons.arrow_back, size: 16),
                    label: const Text('Back'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF635BFF),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: AppColors.borderLight),
            
            // Content
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: const TextSpan(
                      text: 'Day',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                      children: [TextSpan(text: ' *', style: TextStyle(color: Colors.red))],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: days.map((day) {
                      final isSelected = day == _selectedDay;
                      return Expanded(
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              _selectedDay = day;
                              _timesLoadedForDay = false;
                            });
                          },
                          child: Container(
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: isSelected ? const Color(0xFF635BFF) : const Color(0xFFEAE9F9),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              day,
                              style: TextStyle(
                                color: isSelected ? Colors.white : const Color(0xFF635BFF),
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 32),
                  RichText(
                    text: const TextSpan(
                      text: 'Time',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                      children: [TextSpan(text: ' *', style: TextStyle(color: Colors.red))],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: times.map((time) {
                      final isSelected = _selectedTimes.contains(time);
                      return InkWell(
                        onTap: () {
                          setState(() {
                            if (isSelected) {
                              _selectedTimes.remove(time);
                            } else {
                              _selectedTimes.add(time);
                            }
                          });
                        },
                        child: Container(
                          width: 70,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFF635BFF) : const Color(0xFFEAE9F9),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            time,
                            style: TextStyle(
                              color: isSelected ? Colors.white : const Color(0xFF635BFF),
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 40),
                  ElevatedButton(
                    onPressed: timeSlotState.isSaving ? null : () async {
                      final pId = ref.read(profileProvider).profile?.id ?? 0;
                      await ref.read(timeSlotProvider.notifier).saveSlots(pId, _selectedDay, _selectedTimes);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF635BFF),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    ),
                    child: timeSlotState.isLoading 
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
                        : const Text('Submit', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────── COMING SOON ───────────────────────

  Widget _buildComingSoon(String tab) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(color: AppColors.bgLighterPurple, shape: BoxShape.circle),
            child: const Icon(Icons.construction_outlined, size: 36, color: AppColors.primary),
          ),
          const SizedBox(height: 16),
          Text(tab, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primaryDark)),
          const SizedBox(height: 8),
          const Text('This section is coming soon', style: TextStyle(fontSize: 13, color: AppColors.textMuted)),
        ],
      ),
    );
  }

  // ─────────────────────── PROFILE TAB ───────────────────────

  Widget _buildProfileTab(dynamic profile) {
    final imageUrl = profile?.profileImage != null
        ? (profile!.profileImage!.startsWith('http')
            ? profile.profileImage!
            : ApiClient.baseUrl.replaceAll('/api', '') + profile.profileImage!)
        : null;

    return LayoutBuilder(builder: (context, constraints) {
      // Wide: avatar panel on left + 2-col form. Compact: avatar row + 1-col form.
      final isWide = constraints.maxWidth >= 700;

      final avatarWidget = GestureDetector(
        onTap: () {
          if (imageUrl != null) ImageViewer.show(context, NetworkImage(imageUrl));
        },
        child: CircleAvatar(
          radius: isWide ? 40 : 30,
          backgroundColor: AppColors.bgLighterPurple,
          backgroundImage: imageUrl != null ? NetworkImage(imageUrl) : null,
          child: (imageUrl == null)
              ? Icon(Icons.storefront_rounded, size: isWide ? 38 : 26, color: AppColors.primary)
              : null,
        ),
      );

      // 2-col on wide, 1-col on compact
      Widget row2(Widget a, Widget b) => isWide
          ? Row(children: [Expanded(child: a), const SizedBox(width: 20), Expanded(child: b)])
          : Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [a, const SizedBox(height: 16), b]);

      final formContent = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          row2(_buildTextField('First Name *', _firstNameCtrl), _buildTextField('Last Name *', _lastNameCtrl)),
          const SizedBox(height: 20),
          row2(_buildTextField('Username *', _usernameCtrl), _buildTextField('Designation *', _designationCtrl)),
          const SizedBox(height: 20),
          if (_role == 'PROVIDER') ...[
            row2(_buildTextField('Company Name', _companyNameCtrl), _buildTextField('GST Number', _gstCtrl)),
            const SizedBox(height: 20),
          ] else if (_role == 'HANDYMAN') ...[
            row2(_buildTextField('Country', _countryCtrl), _buildTextField('Select Address', _selectAddressCtrl)),
            const SizedBox(height: 20),
            _buildTextField('Handyman Commission', _commissionCtrl),
            const SizedBox(height: 20),
          ],
          row2(_buildTextField('City', _cityCtrl), _buildTextField('State', _stateCtrl)),
          const SizedBox(height: 20),
          row2(_buildTextField('Email *', _emailCtrl, readOnly: true), _buildPhoneField(_mobileCtrl)),
          const SizedBox(height: 20),
          _buildTextField('Address', _addressCtrl),

          const SizedBox(height: 32),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: _isUpdating ? null : () async {
                if (profile != null) {
                  setState(() => _isUpdating = true);
                  final firstName = _firstNameCtrl.text.trim();
                  final lastName = _lastNameCtrl.text.trim();
                  final username = _usernameCtrl.text.trim();
                  await ref.read(profileProvider.notifier).updateProfile(
                    firstName.isNotEmpty ? firstName : profile.firstName,
                    lastName.isNotEmpty ? lastName : profile.lastName,
                    username.isNotEmpty ? username : profile.username,
                    _mobileCtrl.text.trim().isNotEmpty ? _mobileCtrl.text.trim() : profile.mobile,
                    companyName: _role == 'PROVIDER' ? _companyNameCtrl.text.trim() : null,
                    gstNumber: _role == 'PROVIDER' ? _gstCtrl.text.trim() : null,
                    address: _addressCtrl.text.trim(),
                    city: _cityCtrl.text.trim(),
                    stateStr: _stateCtrl.text.trim(),
                    country: _role == 'HANDYMAN' ? _countryCtrl.text.trim() : null,
                    selectAddress: _role == 'HANDYMAN' ? _selectAddressCtrl.text.trim() : null,
                    handymanCommission: _role == 'HANDYMAN' ? _commissionCtrl.text.trim() : null,
                  );
                  if (mounted) setState(() => _isUpdating = false);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF635BFF),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
              child: _isUpdating
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('Update'),
            ),
          ),
        ],
      );

      if (isWide) {
        // ── Wide: left avatar panel + right scrollable form ──
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 200,
              padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 8),
              decoration: const BoxDecoration(
                border: Border(right: BorderSide(color: AppColors.borderLight)),
              ),
              child: Column(
                children: [
                  avatarWidget,
                  const SizedBox(height: 12),
                  Text(
                    profile != null ? '${profile.firstName} ${profile.lastName}' : 'Loading...',
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.textSecondary),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    profile?.role ?? '',
                    style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: formContent,
              ),
            ),
          ],
        );
      }

      // ── Compact (Mac screen): avatar row at top + single-col form below ──
      return SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                avatarWidget,
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        profile != null ? '${profile.firstName} ${profile.lastName}' : 'Loading...',
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.textSecondary),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(profile?.role ?? '', style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Divider(color: AppColors.borderLight),
            const SizedBox(height: 16),
            formContent,
          ],
        ),
      );
    });
  }

  // ─────────────────────── CHANGE PASSWORD TAB ───────────────────────

  Widget _buildChangePasswordTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(40),
      child: Center(
        child: SizedBox(
          width: 500,
          child: Column(
            children: [
              _buildTextField(
                'Old Password *', 
                _oldPassCtrl, 
                obscure: _obscureOldPassword,
                suffixIcon: IconButton(
                  icon: Icon(_obscureOldPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 20, color: AppColors.textMuted),
                  onPressed: () => setState(() => _obscureOldPassword = !_obscureOldPassword),
                ),
              ),
              const SizedBox(height: 24),
              _buildTextField(
                'New Password *', 
                _newPassCtrl, 
                obscure: _obscureNewPassword,
                suffixIcon: IconButton(
                  icon: Icon(_obscureNewPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 20, color: AppColors.textMuted),
                  onPressed: () => setState(() => _obscureNewPassword = !_obscureNewPassword),
                ),
              ),
              const SizedBox(height: 24),
              _buildTextField(
                'Confirm New Password *', 
                _confirmPassCtrl, 
                obscure: _obscureConfirmPassword,
                suffixIcon: IconButton(
                  icon: Icon(_obscureConfirmPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 20, color: AppColors.textMuted),
                  onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                ),
              ),
              const SizedBox(height: 32),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: () async {
                    if (_oldPassCtrl.text.isEmpty || _newPassCtrl.text.isEmpty || _confirmPassCtrl.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill all fields', style: TextStyle(color: Colors.white)), backgroundColor: Colors.red));
                      return;
                    }
                    if (_newPassCtrl.text != _confirmPassCtrl.text) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('New passwords do not match', style: TextStyle(color: Colors.white)), backgroundColor: Colors.red));
                      return;
                    }
                    try {
                      final response = await ApiClient().post(
                        endpoint: '/change-password',
                        body: {
                          'old_password': _oldPassCtrl.text,
                          'new_password': _newPassCtrl.text,
                        }
                      );
                      if (context.mounted) {
                        bool isSuccess = false;
                        String msg = 'Failed to change password';

                        if (response != null && response['status'] == 1) {
                          final data = response['data'];
                          if (data is Map) {
                            msg = data['message']?.toString() ?? 'Password changed successfully';
                            if (data.containsKey('status')) {
                              isSuccess = data['status'] == true || data['status'] == 1;
                            } else {
                              isSuccess = !msg.toLowerCase().contains('not match') && 
                                          !msg.toLowerCase().contains('incorrect') && 
                                          !msg.toLowerCase().contains('fail') && 
                                          !msg.toLowerCase().contains('error') && 
                                          !msg.toLowerCase().contains('invalid');
                            }
                          } else {
                            isSuccess = true;
                            msg = 'Password changed successfully';
                          }
                        } else {
                          msg = response?['message']?.toString() ?? 'Failed to change password';
                        }

                        if (isSuccess) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg, style: const TextStyle(color: Colors.white)), backgroundColor: Colors.green));
                          _oldPassCtrl.clear();
                          _newPassCtrl.clear();
                          _confirmPassCtrl.clear();
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg, style: const TextStyle(color: Colors.white)), backgroundColor: Colors.red));
                        }
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString(), style: const TextStyle(color: Colors.white)), backgroundColor: Colors.red));
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF635BFF),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  ),
                  child: const Text('Save'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────── FIELD HELPERS ───────────────────────

  Widget _buildTextField(String label, TextEditingController controller, {bool obscure = false, bool readOnly = false, int maxLines = 1, Widget? suffixIcon}) {
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
          obscureText: obscure,
          readOnly: readOnly,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: label.replaceAll(' *', ''),
            hintStyle: const TextStyle(fontSize: 13, color: AppColors.textMuted),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            filled: readOnly,
            fillColor: readOnly ? AppColors.backgroundScaffold : null,
            suffixIcon: suffixIcon,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: AppColors.borderLight)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: AppColors.borderLight)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: AppColors.primary)),
          ),
        ),
      ],
    );
  }

  Widget _buildPlainField(String label, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
        const SizedBox(height: 8),
        TextField(
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(fontSize: 13, color: AppColors.textMuted),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: AppColors.borderLight)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: AppColors.borderLight)),
          ),
        ),
      ],
    );
  }

  Widget _buildStaticDropdown(String label, String value) {
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
              items: [DropdownMenuItem(value: value, child: Text(value, style: const TextStyle(fontSize: 13)))],
              onChanged: (v) {},
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPhoneField(TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: const TextSpan(
            text: 'Contact Number',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
            children: [TextSpan(text: ' *', style: TextStyle(color: Colors.red))],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.borderLight),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                decoration: const BoxDecoration(
                  border: Border(right: BorderSide(color: AppColors.borderLight)),
                  color: Color(0xFFF8F9FA),
                ),
                child: const Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text('🇮🇳 +91', style: TextStyle(fontSize: 13)),
                    SizedBox(width: 4),
                    Icon(Icons.arrow_drop_down, size: 16),
                  ],
                ),
              ),
              Expanded(
                child: TextField(
                  controller: controller,
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFileBrowseField(String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.borderLight),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            children: [
              const Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Text('Choose file...', style: TextStyle(fontSize: 13, color: AppColors.textMuted)),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: const BoxDecoration(
                  border: Border(left: BorderSide(color: AppColors.borderLight)),
                  color: Color(0xFFF8F9FA),
                ),
                child: const Text('Browse', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ),
      ],
    );
  }

}

class _ResponsiveRow extends StatelessWidget {
  final List<Widget> children;
  final bool isMobile;
  const _ResponsiveRow({required this.children, required this.isMobile});

  @override
  Widget build(BuildContext context) {
    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children.map((c) {
          if (c is Expanded) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: c.child,
            );
          } else if (c is SizedBox && c.width != null) {
            return const SizedBox.shrink();
          }
          return Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: c,
          );
        }).toList(),
      );
    } else {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      );
    }
  }
}

class _ResponsiveTableWrapper extends StatelessWidget {
  final Widget child;
  final bool isMobile;
  const _ResponsiveTableWrapper({required this.child, required this.isMobile});

  @override
  Widget build(BuildContext context) {
    if (isMobile) {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          width: 800,
          child: child,
        ),
      );
    }
    return child;
  }
}

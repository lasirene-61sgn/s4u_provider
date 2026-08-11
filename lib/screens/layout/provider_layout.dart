import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/storage/shared_preference_helper.dart';
import '../auth/riverpod/auth_notifier.dart';
import '../profile/riverpod/profile_notifier.dart';
import '../dashboard/ui/dashboard_screen.dart';
import '../bookings/ui/bookings_screen.dart';
import '../handyman/ui/handyman_screen.dart';
import '../handyman/ui/handyman_request_screen.dart';
import '../handyman/ui/handyman_ratings_screen.dart';
import '../services/ui/addons_screen.dart';
import '../services/ui/packages_screen.dart';
import '../services/ui/requested_services_screen.dart';
import '../services/ui/service_request_list_screen.dart';
import '../services/ui/all_services_screen.dart';
import '../promotion/ui/provider_promotional_banner_screen.dart';
import '../earnings/ui/payments_screen.dart';
import '../earnings/ui/cash_payments_screen.dart';
import '../earnings/ui/withdrawal_request_screen.dart';
import '../handyman/ui/handyman_earning_screen.dart';
import '../handyman/ui/handyman_commission_screen.dart';
import '../handyman/ui/unassigned_handyman_screen.dart';
import '../earnings/ui/earnings_screen.dart';
import '../post_job/ui/post_job_screen.dart';
import '../profile/ui/profile_screen.dart';
import '../../core/widgets/image_viewer.dart';

import '../provider_info/ui/provider_info_screen.dart';
import '../services/riverpod/service_notifier.dart';
import '../services/riverpod/package_notifier.dart';
import '../services/riverpod/addon_notifier.dart';
import '../bookings/riverpod/bookings_notifier.dart';
import '../handyman/riverpod/handyman_notifier.dart';
import '../handyman/riverpod/handyman_earning_notifier.dart';
import '../handyman/riverpod/handyman_commission_notifier.dart';
import '../handyman/riverpod/handyman_ratings_notifier.dart';
import '../earnings/riverpod/payment_notifier.dart';
import '../earnings/riverpod/cash_payment_notifier.dart';
import '../earnings/riverpod/payout_notifier.dart';
import '../helpdesk/riverpod/help_desk_notifier.dart';
import '../promotion/riverpod/promotional_banner_notifier.dart';
import '../post_job/riverpod/post_job_notifier.dart';
import '../notifications/ui/notification_screen.dart';
import '../helpdesk/ui/help_desk_screen.dart';
import '../earnings/ui/wallet_history_screen.dart';
class ProviderLayout extends ConsumerStatefulWidget {
  const ProviderLayout({super.key});

  @override
  ConsumerState<ProviderLayout> createState() => _ProviderLayoutState();
}

class _ProviderLayoutState extends ConsumerState<ProviderLayout> {
  String _role = 'PROVIDER';
  
  List<Widget> _pages = [];
  List<Map<String, dynamic>> _navItems = [];
  bool _pagesReady = false;
  int _selectedIndex = 0;
  final Map<String, bool> _expandedMenus = {'Handyman': true};
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  bool _isSearching = false;
  final TextEditingController _searchCtrl = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _loadRole();
    Future.microtask(() => ref.read(profileProvider.notifier).refresh());
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _dispatchSearch(query);
    });
  }

  void _dispatchSearch(String query) {
    if (_role == 'PROVIDER') {
      if (_selectedIndex == 1) ref.read(bookingsProvider.notifier).refresh(search: query);
      else if (_selectedIndex == 2) ref.read(serviceProvider.notifier).fetchServices(search: query);
      else if (_selectedIndex == 3) ref.read(packageProvider.notifier).fetchAllPackages(search: query);
      else if (_selectedIndex == 4) ref.read(addonProvider.notifier).fetchAllAddons(search: query);
      else if (_selectedIndex == 5) ref.read(serviceProvider.notifier).fetchServices(search: query);
      else if (_selectedIndex == 6 || _selectedIndex == 15 || _selectedIndex == 16) ref.read(handymenProvider.notifier).refresh(search: query);
      else if (_selectedIndex == 17) ref.read(handymanEarningListProvider.notifier).refresh(search: query);
      else if (_selectedIndex == 18) ref.read(handymanCommissionProvider.notifier).refresh(search: query);
      else if (_selectedIndex == 7) ref.read(paymentProvider.notifier).fetchPayments(search: query);
      else if (_selectedIndex == 8) ref.read(cashPaymentProvider.notifier).fetchCashPayments(search: query);
      else if (_selectedIndex == 9) ref.read(payoutProvider.notifier).fetchPayouts(search: query);
      else if (_selectedIndex == 11) ref.read(promotionalBannerProvider.notifier).fetchAllBanners(search: query);
      else if (_selectedIndex == 12) ref.read(handymanRatingsProvider.notifier).loadRatings(search: query);
      else if (_selectedIndex == 13) ref.read(helpDeskProvider.notifier).fetchTickets(search: query);
      else if (_selectedIndex == 20) ref.read(postJobProvider.notifier).fetchJobs();
      // add more as needed
    } else {
      if (_selectedIndex == 1) ref.read(bookingsProvider.notifier).refresh(search: query);
      else if (_selectedIndex == 2) ref.read(paymentProvider.notifier).fetchPayments(search: query);
      else if (_selectedIndex == 3) ref.read(cashPaymentProvider.notifier).fetchCashPayments(search: query);
      else if (_selectedIndex == 4) ref.read(helpDeskProvider.notifier).fetchTickets(search: query);
    }
  }

  Future<void> _loadRole() async {
    setState(() {
      _role = SharedPreferenceHelper.getString('role') ?? 'PROVIDER';
      if (_role == 'HANDYMAN') {
        _pages = [
          const DashboardScreen(),
          const BookingsScreen(),
          const PaymentsScreen(),
          const CashPaymentsScreen(),
          const HelpDeskScreen(),
          const ProfileScreen(),
          const ProviderInfoScreen(), // index 6
          const WalletHistoryScreen(), // index 7
        ];
        _navItems = [
          {'type': 'header', 'label': 'MAIN'},
          {'type': 'item', 'label': 'Dashboard', 'icon': Icons.dashboard_outlined, 'pageIndex': 0},
          {'type': 'item', 'label': 'Bookings', 'icon': Icons.book_online_outlined, 'pageIndex': 1},
          
          {'type': 'header', 'label': 'TRANSACTIONS'},
          {'type': 'item', 'label': 'Payments', 'icon': Icons.payment_outlined, 'pageIndex': 2},
          {'type': 'item', 'label': 'Cash Payments', 'icon': Icons.money_outlined, 'pageIndex': 3},

          {'type': 'header', 'label': 'PROMOTION'},
          {'type': 'item', 'label': 'Help Desk', 'icon': Icons.support_agent_outlined, 'pageIndex': 4},

          {'type': 'header', 'label': 'SETTINGS'},
          {'type': 'item', 'label': 'Profile', 'icon': Icons.person_outline, 'pageIndex': 5},
          {'type': 'item', 'label': 'Profile Info', 'icon': Icons.info_outline, 'pageIndex': 6},
        ];
      } else {
        _pages = [
          const DashboardScreen(),
          const BookingsScreen(),
          const AllServicesScreen(),
          const PackagesScreen(),
          const AddonsScreen(),
          const RequestedServicesScreen(), // Used to be ServiceRequestListScreen()
          const HandymanScreen(),
          const PaymentsScreen(),
          const CashPaymentsScreen(),
          const WithdrawalRequestScreen(),
          const EarningsScreen(), // Earnings screen is currently separate
          const ProviderPromotionalBannerScreen(),
          const HandymanRatingsScreen(),
          const HelpDeskScreen(),
          const ProfileScreen(),
          const HandymanRequestScreen(),
          const UnassignedHandymanScreen(),
          const HandymanEarningScreen(),
          const HandymanCommissionScreen(),
          const ProviderInfoScreen(),    // index 19
          const PostJobScreen(),         // index 20
          const WalletHistoryScreen(), // index 21
        ];
        _navItems = [
          {'type': 'header', 'label': 'MAIN'},
          {'type': 'item', 'label': 'Dashboard', 'icon': Icons.dashboard_outlined, 'pageIndex': 0},
          {'type': 'item', 'label': 'Bookings', 'icon': Icons.book_online_outlined, 'pageIndex': 1},
          
          {'type': 'header', 'label': 'SERVICE'},
          {'type': 'item', 'label': 'All Services', 'icon': Icons.design_services_outlined, 'pageIndex': 2},
          {'type': 'item', 'label': 'Packages', 'icon': Icons.inventory_2_outlined, 'pageIndex': 3},
          {'type': 'item', 'label': 'Addons', 'icon': Icons.extension_outlined, 'pageIndex': 4},
          
          {'type': 'header', 'label': 'USER'},
          {
            'type': 'expandable',
            'label': 'Handyman',
            'icon': Icons.manage_accounts_outlined,
            'children': [
              {'label': 'Handyman List', 'icon': Icons.list_alt_outlined, 'pageIndex': 6},
              {'label': 'Handyman Request List', 'icon': Icons.assignment_outlined, 'pageIndex': 15},
              {'label': 'Unassigned Handyman', 'icon': Icons.person_add_disabled_outlined, 'pageIndex': 16},
              {'label': 'Handyman Earning List', 'icon': Icons.attach_money_outlined, 'pageIndex': 17},
              {'label': 'Handyman Commission List', 'icon': Icons.monetization_on_outlined, 'pageIndex': 18},
            ]
          },
          
          {'type': 'header', 'label': 'TRANSACTIONS'},
          {'type': 'item', 'label': 'Payments', 'icon': Icons.payment_outlined, 'pageIndex': 7},
          {'type': 'item', 'label': 'Cash Payments', 'icon': Icons.money_outlined, 'pageIndex': 8},
          {'type': 'item', 'label': 'Provider Withdrawal Requests', 'icon': Icons.account_balance_wallet_outlined, 'pageIndex': 9},

          
          {'type': 'header', 'label': 'PROMOTION'},
          {'type': 'item', 'label': 'Provider Promotional Banner', 'icon': Icons.campaign_outlined, 'pageIndex': 11},
          
          {'type': 'header', 'label': 'RATINGS'},
          {'type': 'item', 'label': 'Handyman Ratings List', 'icon': Icons.star_outline, 'pageIndex': 12},
          {'type': 'item', 'label': 'Help Desk', 'icon': Icons.support_agent_outlined, 'pageIndex': 13},
          
          {'type': 'header', 'label': 'SETTINGS'},
          {'type': 'item', 'label': 'Profile', 'icon': Icons.person_outline, 'pageIndex': 14},
          {'type': 'item', 'label': 'Provider Info', 'icon': Icons.info_outline, 'pageIndex': 19},
        ];
      }
      _pagesReady = true;
    });
  }

  void _onNavigate(int index) {
    setState(() {
      _selectedIndex = index;
      _isSearching = false; // Reset search when navigating
      _searchCtrl.clear();
      _dispatchSearch('');
    });
    
    if (_role == 'PROVIDER' && index == 2) {
      Future.microtask(() => ref.read(serviceProvider.notifier).refresh());
    }

    if (_role == 'PROVIDER' && index == 20) {
      Future.microtask(() => ref.read(postJobProvider.notifier).fetchJobs());
    }

    if (_scaffoldKey.currentState?.isDrawerOpen ?? false) {
      _scaffoldKey.currentState?.closeDrawer();
    }
  }

  int _getBottomNavIndex() {
    if (_role == 'PROVIDER') {
      if (_selectedIndex == 0) return 0;
      if (_selectedIndex == 2) return 1;
      if (_selectedIndex == 1) return 2;
      if (_selectedIndex == 14) return 3;
    } else {
      if (_selectedIndex == 0) return 0;
      if (_selectedIndex == 1) return 2;
      if (_selectedIndex == 5) return 3;
    }
    return 0; // Default to Home if on a sub-page
  }

  String _getCurrentTitle() {
    if (!_pagesReady || _navItems.isEmpty) return 'Partner Portal';
    
    for (final item in _navItems) {
      if (item['type'] == 'item' && item['pageIndex'] == _selectedIndex) {
        return item['label'] ?? 'Partner Portal';
      }
      if (item['type'] == 'expandable') {
        final children = item['children'] as List<dynamic>;
        for (final child in children) {
          if (child['pageIndex'] == _selectedIndex) {
            return child['label'] ?? 'Partner Portal';
          }
        }
      }
    }
    return 'Partner Portal';
  }

  @override
  Widget build(BuildContext context) {
    if (!_pagesReady) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final profile = ref.watch(profileProvider).profile;
    const bool isMobile = true;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.backgroundScaffold,
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchCtrl,
                onChanged: _onSearchChanged,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Search ${_getCurrentTitle().toLowerCase()}...',
                  border: InputBorder.none,
                  hintStyle: const TextStyle(color: AppColors.textMuted),
                ),
                style: const TextStyle(color: AppColors.primaryDark),
              )
            : Text(_getCurrentTitle(), style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryDark)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.primaryDark),
        actions: [
          if ([1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 15, 16, 17, 18, 20].contains(_selectedIndex)) 
            IconButton(
              icon: Icon(_isSearching ? Icons.close : Icons.search, color: AppColors.textMuted),
              onPressed: () {
                setState(() {
                  _isSearching = !_isSearching;
                  if (!_isSearching) {
                    _searchCtrl.clear();
                    _dispatchSearch('');
                  }
                });
              },
            ),
          if (_selectedIndex == 14)
            TextButton.icon(
              onPressed: () {
                ref.read(authProvider.notifier).logout();
              },
              icon: const Icon(Icons.logout, color: Colors.red),
              label: const Text('Logout', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            ),
          if (_selectedIndex == 0 && !_isSearching) ...[
            IconButton(
              icon: const Icon(Icons.notifications_outlined, color: AppColors.textMuted),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationScreen()));
              },
            ),
            PopupMenuButton<String>(
              offset: const Offset(0, 50),
              onSelected: (val) {
                if (val == 'logout') {
                  ref.read(authProvider.notifier).logout();
                } else if (val == 'profile') {
                  if (_role == 'HANDYMAN') {
                    _onNavigate(5);
                  } else {
                    _onNavigate(14);
                  }
                } else if (val == 'info') {
                  if (_role == 'PROVIDER') _onNavigate(19);
                  else if (_role == 'HANDYMAN') _onNavigate(6);
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'profile', child: Text('My Profile')),
                const PopupMenuItem(value: 'info', child: Text('My Info')),
                const PopupMenuItem(value: 'logout', child: Text('Logout')),
              ],
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: GestureDetector(
                  onTap: () {
                    final imageProvider = profile?.profileImage != null && profile!.profileImage!.isNotEmpty
                        ? NetworkImage(profile.profileImage!.startsWith('http') ? profile.profileImage! : 'https://s4u.lasireneexim.com${profile.profileImage!.startsWith('/') ? '' : '/'}${profile.profileImage}')
                        : const AssetImage('assets/s4u_logo.jpeg') as ImageProvider;
                    ImageViewer.show(context, imageProvider);
                  },
                  child: CircleAvatar(
                    radius: 16,
                    backgroundColor: AppColors.primaryLight,
                    backgroundImage: profile?.profileImage != null && profile!.profileImage!.isNotEmpty
                        ? NetworkImage(profile.profileImage!.startsWith('http') ? profile.profileImage! : 'https://s4u.lasireneexim.com${profile.profileImage!.startsWith('/') ? '' : '/'}${profile.profileImage}')
                        : const AssetImage('assets/s4u_logo.jpeg') as ImageProvider,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
      drawer: isMobile ? Drawer(
        width: 280,
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        child: SafeArea(child: _buildSidebarContent(ref)),
      ) : null,
      bottomNavigationBar: isMobile ? Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 24,
              offset: const Offset(0, -4),
            )
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildBottomNavItem(Icons.home_outlined, Icons.home, 'Home', 0),
                _buildBottomNavItem(Icons.design_services_outlined, Icons.design_services, 'Service', 1),
                _buildBottomNavItem(Icons.book_online_outlined, Icons.book_online, 'Booking', 2),
                _buildBottomNavItem(Icons.person_outline, Icons.person, 'Profile', 3),
              ],
            ),
          ),
        ),
      ) : null,
      body: Row(
        children: [
          if (!isMobile)
            Container(
              width: 280,
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(right: BorderSide(color: AppColors.borderLight)),
              ),
              child: _buildSidebarContent(ref),
            ),
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: _pages.isNotEmpty ? _pages[_selectedIndex] : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarContent(WidgetRef ref) {
    final profileState = ref.watch(profileProvider);
    final profile = profileState.profile;
    
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 32, bottom: 8, left: 24),
          child: Row(
            children: [
              Image.asset('assets/s4u_logo.jpeg', height: 32),
              const SizedBox(width: 12),
              Text(_role == 'HANDYMAN' ? 'Handyman' : 'Provider', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.primaryDark, letterSpacing: -0.5)),
            ],
          ),
        ),
        // Clickable user info row
        InkWell(
          onTap: () {
            if (_role == 'PROVIDER') {
              _onNavigate(19);
            } else if (_role == 'HANDYMAN') {
              _onNavigate(6);
            }
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    if (profile?.profileImage != null && profile!.profileImage!.isNotEmpty) {
                      ImageViewer.show(context, NetworkImage(profile.profileImage!.startsWith('http') ? profile.profileImage! : 'https://s4u.lasireneexim.com${profile.profileImage!.startsWith('/') ? '' : '/'}${profile.profileImage}'));
                    }
                  },
                  child: CircleAvatar(
                    radius: 20,
                    backgroundColor: AppColors.bgLighterPurple,
                    backgroundImage: profile?.profileImage != null && profile!.profileImage!.isNotEmpty
                        ? NetworkImage(profile.profileImage!.startsWith('http') ? profile.profileImage! : 'https://s4u.lasireneexim.com${profile.profileImage!.startsWith('/') ? '' : '/'}${profile.profileImage}')
                        : null,
                    child: (profile?.profileImage == null || profile!.profileImage!.isEmpty)
                        ? const Icon(Icons.storefront_rounded, color: AppColors.primary, size: 20)
                        : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(profile != null ? '${profile.firstName ?? ''} ${profile.lastName ?? ''}'.trim() : 'Loading...', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primaryDark)),
                      Text(profile?.email ?? '', style: const TextStyle(fontSize: 11, color: AppColors.textMuted), overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: AppColors.textMuted, size: 18),
              ],
            ),
          ),
        ),
        const Divider(color: AppColors.borderLight, height: 1),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final item in _navItems)
                  if (item['type'] == 'header')
                    Padding(
                      padding: const EdgeInsets.only(left: 16, top: 24, bottom: 8),
                      child: Text(
                        item['label'], 
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textMuted, letterSpacing: 1.2),
                      ),
                    )
                  else if (item['type'] == 'expandable')
                    _buildExpandableItem(item)
                  else
                    _buildNavItem(item['label'], item['icon'], item['pageIndex']),
              ],
            ),
          ),
        ),
        const Divider(color: AppColors.borderLight, height: 1),
        ListTile(
          leading: const Icon(Icons.logout_rounded, color: Colors.red),
          title: const Text('Log out', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          onTap: () => ref.read(authProvider.notifier).logout(),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildNavItem(String title, IconData icon, int pageIndex) {
    final bool isSelected = _selectedIndex == pageIndex;
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: InkWell(
        onTap: () => _onNavigate(pageIndex),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.navSelectedBg : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isSelected ? AppColors.navSelectedBorder : Colors.transparent, width: 1),
          ),
          child: Row(
            children: [
              Icon(icon, color: isSelected ? AppColors.primary : AppColors.textMuted, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(title, style: TextStyle(
                  color: isSelected ? AppColors.primary : AppColors.textSecondary,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  fontSize: 14,
                ), maxLines: 1, overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExpandableItem(Map<String, dynamic> item) {
    final bool isExpanded = _expandedMenus[item['label']] ?? false;
    final List<dynamic> children = item['children'];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () {
            setState(() {
              _expandedMenus[item['label']] = !isExpanded;
            });
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isExpanded ? AppColors.primary.withValues(alpha: 0.1) : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(item['icon'], color: isExpanded ? AppColors.primary : AppColors.textMuted, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(item['label'], style: TextStyle(
                    color: isExpanded ? AppColors.primary : AppColors.textSecondary,
                    fontWeight: isExpanded ? FontWeight.w700 : FontWeight.w500,
                    fontSize: 14,
                  )),
                ),
                Icon(isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, 
                    color: isExpanded ? AppColors.primary : AppColors.textMuted, size: 20),
              ],
            ),
          ),
        ),
        if (isExpanded)
          Container(
            margin: const EdgeInsets.only(left: 24, top: 4),
            decoration: const BoxDecoration(
              border: Border(left: BorderSide(color: AppColors.borderLight, width: 1.5)),
            ),
            child: Column(
              children: children.map((child) {
                final bool isChildSelected = _selectedIndex == child['pageIndex'];
                return InkWell(
                  onTap: () => _onNavigate(child['pageIndex']),
                  child: Row(
                    children: [
                      Container(
                        width: 16,
                        height: 1.5,
                        color: AppColors.borderLight,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Row(
                            children: [
                              Icon(child['icon'], color: isChildSelected ? AppColors.primary : AppColors.textMuted, size: 18),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(child['label'], style: TextStyle(
                                  color: isChildSelected ? AppColors.primary : AppColors.textSecondary,
                                  fontWeight: isChildSelected ? FontWeight.w700 : FontWeight.w500,
                                  fontSize: 13,
                                )),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }

  Widget _buildBottomNavItem(IconData unselectedIcon, IconData selectedIcon, String label, int index) {
    final isSelected = _getBottomNavIndex() == index;
    return GestureDetector(
      onTap: () {
        if (_role == 'PROVIDER') {
          if (index == 0) _onNavigate(0);
          else if (index == 1) _onNavigate(2); // Service
          else if (index == 2) _onNavigate(1); // Booking
          else if (index == 3) _onNavigate(14); // Profile
        } else {
          if (index == 0) _onNavigate(0);
          else if (index == 1) _onNavigate(0); // Handyman has no Service
          else if (index == 2) _onNavigate(1); // Booking
          else if (index == 3) _onNavigate(5); // Profile
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(isSelected ? selectedIcon : unselectedIcon, color: isSelected ? AppColors.primary : AppColors.textMuted, size: 24),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(color: isSelected ? AppColors.primary : AppColors.textMuted, fontWeight: isSelected ? FontWeight.bold : FontWeight.w500, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}

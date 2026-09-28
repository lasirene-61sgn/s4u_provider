import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import '../../../core/storage/shared_preference_helper.dart';
import '../../../core/widgets/image_viewer.dart';
import '../riverpod/dashboard_notifier.dart';
import '../model/dashboard_model.dart';
import '../../bookings/ui/bookings_screen.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  final Function(int)? onNavigate;
  const DashboardScreen({super.key, this.onNavigate});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  String _role = 'PROVIDER';
  CalendarView _calendarView = CalendarView.month;
  final CalendarController _calendarController = CalendarController();

  @override
  void initState() {
    super.initState();
    _role = SharedPreferenceHelper.getString('role') ?? 'PROVIDER';
    Future.microtask(() => ref.read(dashboardProvider.notifier).refresh());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(dashboardProvider);
    return _buildBody(state);
  }

  Widget _buildBody(DashboardState state) {
    if (state.isLoading && state.stats == null) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }

    if (state.error != null && state.stats == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text('Error: ${state.error}', style: const TextStyle(color: AppColors.textMuted)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.read(dashboardProvider.notifier).refresh(),
              child: const Text('Retry'),
            )
          ],
        ),
      );
    }

    final data = state.stats ?? DashboardStats(
      totalBooking: 0,
      totalService: 0,
      remainingPayout: 0,
      totalRevenue: 0,
      upcomingBookings: [],
      handymen: [],
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          // Metrics Row (Purple Cards)
          Builder(
            builder: (context) {
              final cards = _buildMetricCards(data);
              return Column(
                children: [
                  for (int i = 0; i < cards.length; i += 2) ...[
                    Row(
                      children: [
                        Expanded(child: cards[i]),
                        const SizedBox(width: 16),
                        if (i + 1 < cards.length) Expanded(child: cards[i + 1]) else const Expanded(child: SizedBox()),
                      ],
                    ),
                    if (i + 2 < cards.length) const SizedBox(height: 16),
                  ]
                ],
              );
            },
          ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.1),
          
          const SizedBox(height: 32),
          
          if (_role == 'HANDYMAN')
            _buildHandymanCalendar()
          else
            _buildProviderLowerSection(data),
        ],
      ),
    );
  }

  List<Widget> _buildMetricCards(DashboardStats data) {
    bool isHandyman = _role == 'HANDYMAN';
    if (isHandyman) {
      return [
        _buildPurpleMetricCard('Today Booking', data.todayBooking.toString(), Icons.today_outlined),
        _buildPurpleMetricCard('Total Booking', data.totalBooking.toString(), Icons.assignment_outlined, onTap: () {
          if (widget.onNavigate != null) {
            widget.onNavigate!(1); // 1 is Bookings index in ProviderLayout
          }
        }),
        _buildPurpleMetricCard('Complete Booking', data.completedBooking.toString(), Icons.check_circle_outline),
        _buildPurpleMetricCard('Remaining Payout', '₹${data.remainingPayout.toStringAsFixed(2)}', Icons.monetization_on_outlined),
        _buildPurpleMetricCard('Total Revenue', '₹${data.totalRevenue.toStringAsFixed(2)}', Icons.account_balance_wallet_outlined),
      ];
    } else {
      return [
        _buildPurpleMetricCard('Total Booking', data.totalBooking.toString(), Icons.assignment_outlined, onTap: () {
          if (widget.onNavigate != null) {
            widget.onNavigate!(1); // 1 is Bookings index in ProviderLayout
          }
        }),
        _buildPurpleMetricCard('Total Service', data.totalService.toString(), Icons.design_services_outlined, onTap: () {
          if (widget.onNavigate != null) {
            widget.onNavigate!(2); // 2 is Service index in ProviderLayout
          }
        }),
        _buildPurpleMetricCard('Active Handyman', data.totalActiveHandyman.toString(), Icons.engineering_outlined, onTap: () {
          if (widget.onNavigate != null) {
            widget.onNavigate!(6); // 6 is Handyman List index in ProviderLayout
          }
        }),
        _buildPurpleMetricCard('Cash In Hand', '₹${data.totalCashInHand.toStringAsFixed(2)}', Icons.payments_outlined),
        _buildPurpleMetricCard('Remaining Payout', '₹${data.remainingPayout.toStringAsFixed(2)}', Icons.monetization_on_outlined),
        _buildPurpleMetricCard('Total Revenue', '₹${data.totalRevenue.toStringAsFixed(2)}', Icons.account_balance_wallet_outlined),
      ];
    }
  }

  Widget _buildHandymanCalendar() {
    return Container(
      height: 600,
      padding: EdgeInsets.all(MediaQuery.of(context).size.width < 600 ? 16 : 24),
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(20), 
        border: Border.all(color: AppColors.borderLight)
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 16,
            runSpacing: 16,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left, color: AppColors.textSecondary),
                    onPressed: () {
                      _calendarController.backward!();
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
                    onPressed: () {
                      _calendarController.forward!();
                    },
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                      foregroundColor: AppColors.primary,
                      elevation: 0,
                    ),
                    onPressed: () {
                      _calendarController.displayDate = DateTime.now();
                    },
                    child: const Text('today'),
                  ),
                ],
              ),
              // View Toggles
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildViewToggle('month', CalendarView.month),
                    _buildViewToggle('week', CalendarView.week),
                    _buildViewToggle('day', CalendarView.day),
                    _buildViewToggle('list', CalendarView.schedule),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: SfCalendar(
              controller: _calendarController,
              view: _calendarView,
              headerHeight: 40,
              headerStyle: const CalendarHeaderStyle(
                textAlign: TextAlign.center,
                textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryDark),
              ),
              timeSlotViewSettings: const TimeSlotViewSettings(
                startHour: 6,
                endHour: 24,
                timeFormat: 'hha',
              ),
              todayHighlightColor: AppColors.primary,
              selectionDecoration: BoxDecoration(
                border: Border.all(color: AppColors.primary, width: 2),
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.1);
  }

  Widget _buildViewToggle(String label, CalendarView view) {
    final isSelected = _calendarView == view;
    return InkWell(
      onTap: () {
        setState(() {
          _calendarView = view;
          _calendarController.view = view;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withValues(alpha: 0.1) : Colors.transparent,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppColors.primary : AppColors.textMuted,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildProviderLowerSection(DashboardStats data) {
    return Column(
      children: [
        Container(
          height: 350,
          padding: EdgeInsets.all(MediaQuery.of(context).size.width < 600 ? 16 : 24),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.borderLight)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Monthly Revenue', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryDark)),
              const SizedBox(height: 32),
              Expanded(child: _buildLineChart(data)),
            ],
          ),
        ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.1),

        const SizedBox(height: 32),

        Builder(
          builder: (context) {
            final grids = [
              if (data.handymen.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.borderLight)),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Top Handyman', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primaryDark)),
                            TextButton(onPressed: () {
                              if (widget.onNavigate != null) widget.onNavigate!(6);
                            }, child: const Text('View All', style: TextStyle(color: AppColors.primary))),
                          ],
                        ),
                        const SizedBox(height: 16),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: data.handymen.length,
                          itemBuilder: (context, idx) {
                            final hm = data.handymen[idx];
                            return ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: GestureDetector(
                                onTap: () => ImageViewer.show(context, hm['profile_image'] != null ? NetworkImage(hm['profile_image']) : const AssetImage('assets/s4u_logo.jpeg') as ImageProvider),
                                child: CircleAvatar(
                                  backgroundImage: hm['profile_image'] != null 
                                    ? NetworkImage(hm['profile_image']) 
                                    : const AssetImage('assets/s4u_logo.jpeg') as ImageProvider,
                                ),
                              ),
                              title: Text(hm['display_name'] ?? hm['first_name'] ?? 'Handyman', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                              subtitle: const Text('Top Handyman', style: TextStyle(fontSize: 12)),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
              if (data.handymen.isNotEmpty)
                const SizedBox(height: 24),
              if (data.upcomingBookings.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.borderLight)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Recent Bookings', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primaryDark)),
                            TextButton(onPressed: () {
                              if (widget.onNavigate != null) widget.onNavigate!(1);
                            }, child: const Text('View All', style: TextStyle(color: AppColors.primary))),
                          ],
                        ),
                        const SizedBox(height: 16),
                        ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: data.upcomingBookings.length,
                              itemBuilder: (context, idx) {
                                final b = data.upcomingBookings[idx];
                                return ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  leading: GestureDetector(
                                    onTap: () => ImageViewer.show(context, b['customer_image'] != null ? NetworkImage(b['customer_image']) : const AssetImage('assets/s4u_logo.jpeg') as ImageProvider),
                                    child: CircleAvatar(
                                      backgroundImage: b['customer_image'] != null
                                          ? NetworkImage(b['customer_image'])
                                          : const AssetImage('assets/s4u_logo.jpeg') as ImageProvider,
                                    ),
                                  ),
                                  title: Text('${b['service_name'] ?? 'Booking'} #${b['id'] ?? ''}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                  subtitle: Text(b['date'] ?? b['booking_date'] ?? 'N/A', style: const TextStyle(fontSize: 12)),
                                  onTap: () {
                                    if (widget.onNavigate != null) widget.onNavigate!(1);
                                  },
                                );
                              },
                            ),
                    ],
                  ),
                ),
            ];
            return Column(
              children: grids,
            );
          }
        ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.1),
      ],
    );
  }

  Widget _buildPurpleMetricCard(String title, String value, IconData icon, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF635BFF), // Vibrant purple
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            colors: [Color(0xFF6B66D6), Color(0xFF5B52C3)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                  const SizedBox(height: 4),
                  Text(title, style: const TextStyle(fontSize: 12, color: Colors.white70), maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white, size: 20),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLineChart(DashboardStats data) {
    final List<FlSpot> spots = [];
    double maxVal = 100.0;
    
    if (data.monthlyRevenue != null && data.monthlyRevenue!['revenueData'] is List) {
      final revenueList = data.monthlyRevenue!['revenueData'] as List;
      for (int i = 0; i < 12; i++) {
        double val = 0.0;
        if (i < revenueList.length) {
          final monthData = revenueList[i];
          if (monthData is Map && monthData.isNotEmpty) {
            val = double.tryParse(monthData.values.first.toString()) ?? 0.0;
          }
        }
        if (val > maxVal) maxVal = val;
        spots.add(FlSpot(i.toDouble(), val));
      }
    } else {
      for (int i = 0; i < 12; i++) spots.add(FlSpot(i.toDouble(), 0));
    }

    // Set horizontal interval based on max value to keep lines reasonable
    double interval = (maxVal / 4).clamp(1.0, double.infinity).toDouble();

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true, 
          drawVerticalLine: false,
          horizontalInterval: interval,
          getDrawingHorizontalLine: (value) => FlLine(color: AppColors.borderLight, strokeWidth: 1),
        ),
        titlesData: FlTitlesData(
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (val, meta) {
                const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
                if (val >= 0 && val < 12) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(months[val.toInt()], style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
                  );
                }
                return const SizedBox();
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 45,
              getTitlesWidget: (val, meta) {
                if (val == 0) return const SizedBox();
                String text = '₹${val.toStringAsFixed(0)}';
                if (val >= 1000) text = '₹${(val / 1000).toStringAsFixed(1)}k';
                return Text(text, style: const TextStyle(color: AppColors.textMuted, fontSize: 12));
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        minY: 0,
        maxY: maxVal * 1.1, // Add 10% headroom
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: false,
            color: const Color(0xFF6B66D6), // match the purple
            barWidth: 2,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: const Color(0xFF6B66D6).withValues(alpha: 0.1),
            ),
          ),
        ],
      ),
    );
  }
}

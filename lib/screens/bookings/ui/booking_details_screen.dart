import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart' as fp;
import 'package:image_picker/image_picker.dart';
import 'package:provider_app/core/constants/app_colors.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/api/api_client.dart';
import '../model/booking_model.dart';
import '../riverpod/bookings_notifier.dart';
import 'dart:convert';
import '../../handyman/riverpod/handyman_notifier.dart';
import '../../../core/storage/shared_preference_helper.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../../core/widgets/image_viewer.dart';

class BookingDetailsScreen extends ConsumerStatefulWidget {
  final int bookingId;
  final VoidCallback? onBack;
  const BookingDetailsScreen({super.key, required this.bookingId, this.onBack});

  @override
  ConsumerState<BookingDetailsScreen> createState() => _BookingDetailsScreenState();
}

class _BookingDetailsScreenState extends ConsumerState<BookingDetailsScreen> {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(bookingsProvider.notifier).fetchBookingDetail(widget.bookingId);
      if (ref.read(bookingsProvider).bookings.isEmpty) {
        ref.read(bookingsProvider.notifier).refresh();
      }
      ref.read(handymenProvider.notifier).refresh();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(bookingsProvider);

    if (state.isLoading && state.bookings.isEmpty && state.isDetailLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final detail = state.currentBookingDetail;
    Booking? b;
    if (detail?.bookingDetail != null) {
      b = detail!.bookingDetail;
    } else {
      b = state.bookings.firstWhereOrNull((b) => b.id == widget.bookingId) ?? (Get.arguments as Booking?);
    }

        if (b == null) {
          return Scaffold(
            backgroundColor: const Color(0xFFF8FAFC),
            appBar: AppBar(
          title: const Text('Booking Details', style: TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: Colors.white,
          foregroundColor: AppColors.textSecondary,
          elevation: 0,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.receipt_long, size: 60, color: AppColors.textMuted),
              const SizedBox(height: 16),
              const Text('Booking not found', style: TextStyle(color: AppColors.textMuted, fontSize: 16)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Get.back(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      );
    }

    final bookingData = b;
    final content = LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 850;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isWide)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 7,
                        child: Column(
                          children: [
                            _buildDetailsBox(bookingData, detail),
                            const SizedBox(height: 20),
                            _buildUserProviderCards(bookingData, detail),
                          ],
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        flex: 3,
                        child: _buildPaymentSummary(bookingData),
                      ),
                    ],
                  )
                else
                  Column(
                    children: [
                      _buildDetailsBox(bookingData, detail),
                      const SizedBox(height: 16),
                      _buildUserProviderCards(bookingData, detail),
                      const SizedBox(height: 16),
                      _buildPaymentSummary(bookingData),
                    ],
                  ),
              ],
            ),
          );
        },
      );

    final appBar = _buildAppBar(bookingData, state, detail);

    if (widget.onBack != null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: appBar,
        body: content,
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: appBar,
      body: content,
    );
  }

  // ─────────────────── APP BAR ───────────────────
  PreferredSizeWidget _buildAppBar(Booking b, BookingsState state, BookingDetailResponse? detail) {
    return AppBar(
      backgroundColor: Colors.white,
      foregroundColor: AppColors.textPrimary,
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () {
          if (widget.onBack != null) {
            widget.onBack!();
          } else {
            Get.back();
          }
        },
      ),
      title: Text(
        b.serviceName ?? 'Booking Details',
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        overflow: TextOverflow.ellipsis,
      ),
      actions: [
        if (detail?.bookingActivity.isNotEmpty ?? false)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: TextButton.icon(
              onPressed: () => _showStatusHistoryDialog(context, detail!.bookingActivity),
              icon: const Icon(Icons.history, size: 18),
              label: const Text('Status View'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          )
        else
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: _statusColor(b.bookingStatus).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                (b.bookingStatus ?? 'Unknown').toUpperCase().replaceAll('_', ' '),
                style: TextStyle(color: _statusColor(b.bookingStatus), fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ),
          )
      ],
    );
  }

  // ─────────────────── BOOKING DETAILS BOX ───────────────────
  Widget _buildDetailsBox(Booking booking, BookingDetailResponse? detail) {
    return Container(
      decoration: _card(),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('ID #${booking.id}',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary)),
            ],
          ),
          const SizedBox(height: 28),
          Row(
            children: [
              Expanded(child: _infoCol('Booking Placed', booking.bookingPlaced ?? 'N/A')),
              Expanded(child: _infoCol('Booking Date', booking.bookingDate ?? 'N/A')),
              Expanded(child: _infoCol('Booking Status', booking.bookingStatus, isStatus: true)),
            ],
          ),
          const SizedBox(height: 28),
          Row(
            children: [
              Expanded(
                  child: _infoCol('Total Amount',
                      '₹${booking.totalAmount?.toStringAsFixed(2) ?? '0.00'}',
                      isAmount: true)),
              Expanded(child: _infoCol('Payment Method', booking.paymentMethod ?? '-', isMethod: true)),
              Expanded(
                  child: _infoCol('Payment Status', booking.paymentStatus ?? 'Pending',
                      isPaymentStatus: true)),
            ],
          ),
          const SizedBox(height: 24),
          const Divider(color: AppColors.borderLight, height: 1),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: Wrap(
              alignment: WrapAlignment.end,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildActionButtons(context, ref, booking, detail),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────── CUSTOMER, PROVIDER, HANDYMAN CARDS ───────────────────
  Widget _buildUserProviderCards(Booking booking, BookingDetailResponse? detail) {
    return LayoutBuilder(builder: (ctx, c) {
      final isWide = c.maxWidth > 800; // Use a wider breakpoint since we have 3 cards now
      
      final customerCard = _personCard(
        'Customer', 
        detail?.customer?.displayName ?? booking.userName, 
        detail?.customer?.contactNumber ?? booking.userPhone, 
        detail?.customer?.email ?? booking.userEmail, 
        detail?.customer?.profileImage ?? booking.userImage, 
        detail?.customer?.address ?? booking.address
      );
      final providerCard = _personCard(
        'Provider', 
        detail?.providerData?.displayName ?? booking.providerName, 
        detail?.providerData?.contactNumber ?? booking.providerPhone, 
        detail?.providerData?.email ?? booking.providerEmail, 
        detail?.providerData?.profileImage ?? booking.providerImage, 
        detail?.providerData?.address ?? booking.providerAddress
      );
      
      Widget? handymanCard;
      final hmData = (detail?.handymanData.isNotEmpty ?? false) ? detail!.handymanData.first : null;
      
      if (hmData != null || booking.handymanName != null || booking.bookingStatus.contains('HANDYMAN') || booking.bookingStatus == 'ACCEPTED' || booking.bookingStatus.contains('ASSIGNED')) {
        handymanCard = _personCard(
          'Handyman', 
          hmData?.displayName ?? booking.handymanName, 
          hmData?.contactNumber ?? booking.handymanPhone, 
          hmData?.email ?? booking.handymanEmail, 
          hmData?.profileImage ?? booking.handymanImage, 
          hmData?.address ?? booking.handymanAddress
        );
      }

      if (isWide) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: customerCard),
            const SizedBox(width: 16),
            Expanded(child: providerCard),
            if (handymanCard != null) ...[
              const SizedBox(width: 16),
              Expanded(child: handymanCard),
            ]
          ],
        );
      }
      return Column(
        children: [
          customerCard,
          const SizedBox(height: 16),
          providerCard,
          if (handymanCard != null) ...[
            const SizedBox(height: 16),
            handymanCard,
          ]
        ],
      );
    });
  }

  Widget _personCard(String role, String? name, String? phone, String? email, String? image, String? address) {
    final hasData = name != null || phone != null || email != null;

    return Container(
      decoration: _card(),
      padding: const EdgeInsets.all(20),
      child: !hasData
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 8),
                Icon(Icons.person_off_outlined, size: 36, color: AppColors.textMuted.withValues(alpha: 0.6)),
                const SizedBox(height: 10),
                Text('$role Not Assigned',
                    style: const TextStyle(color: AppColors.textMuted, fontSize: 13, fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        if (image != null) {
                          ImageViewer.show(context, NetworkImage(image.startsWith('http') ? image : '${ApiConstants.baseUrl.replaceAll('/api', '')}$image'));
                        }
                      },
                      child: CircleAvatar(
                        radius: 22,
                        backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                        backgroundImage: image != null
                            ? NetworkImage(image.startsWith('http')
                                ? image
                                : '${ApiConstants.baseUrl.replaceAll('/api', '')}$image')
                            : null,
                        child: image == null
                            ? Text(
                                (name ?? role)[0].toUpperCase(),
                                style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 16),
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(role.toUpperCase(),
                              style: const TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                          const SizedBox(height: 2),
                          Text(name ?? 'Unknown',
                              style: const TextStyle(color: AppColors.textSecondary, fontSize: 14, fontWeight: FontWeight.bold),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                const Divider(color: Color(0xFFF1F5F9), height: 1),
                const SizedBox(height: 14),
                Row(
                  children: [
                    const Icon(Icons.call_outlined, size: 15, color: AppColors.textMuted),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(phone ?? email ?? 'N/A',
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                          overflow: TextOverflow.ellipsis),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.location_on_outlined, size: 15, color: AppColors.textMuted),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(address ?? '-',
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis),
                    ),
                  ],
                ),
              ],
            ),
    );
  }

  // ─────────────────── PAYMENT SUMMARY ───────────────────
  Widget _buildPaymentSummary(Booking booking) {
    final remaining = (booking.totalAmount ?? 0) - (booking.advanceAmount ?? 0);
    return Container(
      decoration: _card(),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Payment Summary',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
          const SizedBox(height: 20),
          _sumRow('Quantity', '1'),
          const SizedBox(height: 12),
          _sumRow('Price',
              '₹${booking.totalAmount?.toStringAsFixed(2) ?? '0.00'} × 1 = ₹${booking.totalAmount?.toStringAsFixed(2) ?? '0.00'}'),
          const SizedBox(height: 12),
          _sumRow('Discount', '-₹${booking.discount?.toStringAsFixed(2) ?? '0.00'}', color: Colors.green),
          const SizedBox(height: 12),
          _sumRow('Sub Total',
              '₹${booking.subtotal?.toStringAsFixed(2) ?? booking.totalAmount?.toStringAsFixed(2) ?? '0.00'}',
              color: Colors.green),
          const SizedBox(height: 12),
          _sumRow('Tax', '₹${booking.tax?.toStringAsFixed(2) ?? '0.00'}', color: Colors.redAccent),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 14),
            child: Divider(color: Color(0xFFF1F5F9)),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Grand Total',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 14, fontWeight: FontWeight.bold)),
              Text('₹${booking.totalAmount?.toStringAsFixed(2) ?? '0.00'}',
                  style: const TextStyle(color: AppColors.primary, fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 20),
          _sumRow('Advance Amount (50%)',
              '₹${booking.advanceAmount?.toStringAsFixed(2) ?? '0.00'}'),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Remaining Amount',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                        color: booking.paymentStatus == 'PAID' ? AppColors.success : Colors.orange,
                        borderRadius: BorderRadius.circular(4)),
                    child: Text(
                      booking.paymentStatus ?? 'Pending',
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Text('₹${remaining.toStringAsFixed(2)}',
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─────────────────── ACTION BUTTONS (status-based, role-aware) ───────────────────
  Widget _buildActionButtons(BuildContext context, WidgetRef ref, Booking booking, BookingDetailResponse? detail) {
    final status = (booking.bookingStatus ?? '').toLowerCase();
    final notifier = ref.read(bookingsProvider.notifier);
    final role = SharedPreferenceHelper.getString('role') ?? 'PROVIDER';
    final isHandyman = role == 'HANDYMAN';

    Widget btn(String label, {required Color bg, required IconData icon, required VoidCallback onTap}) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: bg.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: bg),
              const SizedBox(width: 6),
              Text(label, style: TextStyle(color: bg, fontSize: 12, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      );
    }

    Widget statusBadge(String label, {Color color = Colors.orange, IconData icon = Icons.hourglass_top}) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 6),
            Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
          ],
        ),
      );
    }

    // ════════ BOOKING ACTION FLOW ════════

    // PENDING
    if (status == 'pending' || status == 'waiting') {
      return Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          btn('Accept', bg: const Color(0xFF10B981), icon: Icons.check,
              onTap: () => notifier.updateBookingStatus(booking.id, 'accept', paymentStatus: booking.paymentStatus ?? 'pending')),
          btn('Reject', bg: const Color(0xFFEF4444), icon: Icons.close,
              onTap: () => notifier.updateBookingStatus(booking.id, 'rejected', paymentStatus: booking.paymentStatus ?? 'pending')),
        ],
      );
    }

    if (status == 'pending_approval') {
      return Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          btn('Complete', bg: const Color(0xFF10B981), icon: Icons.check_circle,
              onTap: () => notifier.updateBookingStatus(booking.id, 'completed', paymentStatus: booking.paymentStatus ?? 'pending')),
        ],
      );
    }

    // ACCEPT
    if (status == 'accept') {
      final hasHandyman = (booking.handymanName != null && booking.handymanName!.isNotEmpty) || (detail?.handymanData.isNotEmpty ?? false);
      return Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          if (!isHandyman)
            btn(hasHandyman ? 'Re-assign Handyman' : 'Assign Handyman', bg: const Color(0xFF635BFF), icon: Icons.engineering,
                onTap: () => _showAssignHandymanDialog(context, ref, booking.id)),
          if (hasHandyman)
            btn('Start Drive', bg: const Color(0xFF10B981), icon: Icons.directions_car,
                onTap: () => notifier.updateBookingStatus(booking.id, 'on_going', paymentStatus: booking.paymentStatus ?? 'pending')),
          btn('Cancel Booking', bg: const Color(0xFFEF4444), icon: Icons.cancel_outlined,
              onTap: () => notifier.updateBookingStatus(booking.id, 'cancelled', paymentStatus: booking.paymentStatus ?? 'pending')),
        ],
      );
    }

    // ON_GOING / IN_PROGRESS / HOLD
    if (status == 'on_going' || status == 'in_progress' || status == 'hold') {
      return Wrap(
        spacing: 8,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          statusBadge(status.replaceAll('_', ' ').toUpperCase(), color: _statusColor(status), icon: Icons.build),
          if (status == 'in_progress') ...[
            btn('Submit Proof', bg: const Color(0xFF635BFF), icon: Icons.upload_file,
                onTap: () => _showSubmitProofDialog(context, ref, booking.id)),
          ],
        ],
      );
    }

    // COMPLETED
    if (status == 'completed') {
      return Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          if (booking.paymentStatus?.toLowerCase() == 'pending' && booking.paymentId != null)
            btn('Payment Approve', bg: const Color(0xFF10B981), icon: Icons.verified,
                onTap: () => notifier.updateBookingStatus(booking.id, 'completed', paymentStatus: 'paid')),
          if (booking.paymentStatus?.toLowerCase() == 'paid')
            btn('Download Invoice', bg: const Color(0xFF635BFF), icon: Icons.download,
                onTap: () => notifier.downloadInvoice(booking.id)),
        ],
      );
    }

    // Default: show status badge
    return statusBadge(status.replaceAll('_', ' ').toUpperCase(),
        color: _statusColor(status), icon: Icons.info_outline);
  }

  // ─────────────────── ASSIGN HANDYMAN DIALOG ───────────────────

  void _showStatusHistoryDialog(BuildContext context, List<BookingActivity> activities) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          builder: (_, controller) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
                  const SizedBox(height: 16),
                  const Text('Booking Tracking', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                  const SizedBox(height: 16),
                  const Divider(height: 1),
                  Expanded(
                    child: activities.isEmpty
                      ? const Center(child: Text('No tracking history available.', style: TextStyle(color: AppColors.textMuted)))
                      : ListView.builder(
                          controller: controller,
                          itemCount: activities.length,
                          itemBuilder: (ctx, i) {
                            final activity = activities[i];
                            final isLast = i == activities.length - 1;
                            final isFirst = i == 0;
                            
                            return IntrinsicHeight(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  const SizedBox(width: 24),
                                  Column(
                                    children: [
                                      Container(
                                        width: 2,
                                        height: 24,
                                        color: isFirst ? Colors.transparent : AppColors.primary,
                                      ),
                                      Container(
                                        width: 14,
                                        height: 14,
                                        decoration: const BoxDecoration(
                                          color: AppColors.primary,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      Expanded(
                                        child: Container(
                                          width: 2,
                                          color: isLast ? Colors.transparent : AppColors.primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.only(bottom: 24.0, top: 20),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            (activity.activityType ?? 'Unknown').replaceAll('_', ' ').toUpperCase(), 
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.primary)
                                          ),
                                          const SizedBox(height: 4),
                                          Text(activity.activityMessage ?? '', style: const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
                                          const SizedBox(height: 4),
                                          Text(activity.datetime ?? '', style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 24),
                                ],
                              ),
                            );
                          },
                        ),
                  ),
                ],
              ),
            );
          }
        );
      }
    );
  }

  void _showAssignHandymanDialog(BuildContext context, WidgetRef ref, int bookingId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        titlePadding: EdgeInsets.zero,
        title: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.05),
            borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
          ),
          child: Row(
            children: [
              const Icon(Icons.engineering, color: AppColors.primary),
              const SizedBox(width: 10),
              const Expanded(
                child: Text('Select Handyman',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 18, color: AppColors.textMuted),
                onPressed: () => Navigator.pop(ctx),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ),
        contentPadding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
        content: SizedBox(
          width: 440,
          child: Consumer(
            builder: (c, r, _) {
              final hState = r.watch(handymenProvider);
              if (hState.isLoading && hState.handymen.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
                );
              }
              if (hState.error != null && hState.handymen.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text('Error: ${hState.error}', style: const TextStyle(color: Colors.red)),
                );
              }
              final men = hState.handymen;
              if (men.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.engineering, size: 48, color: AppColors.textMuted),
                        SizedBox(height: 12),
                        Text('No handymen available', style: TextStyle(color: AppColors.textMuted)),
                      ],
                    ),
                  ),
                );
              }
              return ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 360),
                child: ListView.separated(
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: men.length,
                  separatorBuilder: (_, __) => const Divider(height: 1, color: Color(0xFFF1F5F9)),
                  itemBuilder: (cc, ii) {
                    final h = men[ii];
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                      leading: CircleAvatar(
                        radius: 20,
                        backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                        child: Text(
                          h.name.isNotEmpty ? h.name[0].toUpperCase() : 'H',
                          style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                        ),
                      ),
                      title: Text(h.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                      subtitle: Text(
                        h.city.isNotEmpty ? h.city : h.email,
                        style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                      ),
                      trailing: ElevatedButton(
                        onPressed: () async {
                          Navigator.pop(ctx);
                          await r.read(bookingsProvider.notifier).assignHandyman(bookingId, h.id);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text('Assign', style: TextStyle(fontSize: 12)),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  // ─────────────────── SUBMIT PROOF DIALOG ───────────────────
  void _showSubmitProofDialog(BuildContext context, WidgetRef ref, int bookingId) {
    final titleController = TextEditingController(text: 'Job Completed Proof');
    fp.PlatformFile? selectedFile;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Text('Submit Service Proof', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: 'Proof Title',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (selectedFile != null)
                    Stack(
                      alignment: Alignment.topRight,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.borderLight),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.insert_drive_file, color: AppColors.primary),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(selectedFile!.name, overflow: TextOverflow.ellipsis),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.cancel, color: Colors.red),
                          onPressed: () {
                            setState(() => selectedFile = null);
                          },
                        ),
                      ],
                    )
                  else
                    ElevatedButton.icon(
                      icon: const Icon(Icons.photo_camera),
                      label: const Text('Select Photo'),
                      onPressed: () async {
                        final ImageSource? source = await showModalBottomSheet<ImageSource>(
                          context: context,
                          builder: (context) => SafeArea(
                            child: Wrap(
                              children: [
                                ListTile(
                                  leading: const Icon(Icons.camera_alt),
                                  title: const Text('Take a Photo'),
                                  onTap: () => Navigator.pop(context, ImageSource.camera),
                                ),
                                ListTile(
                                  leading: const Icon(Icons.photo_library),
                                  title: const Text('Choose from Gallery'),
                                  onTap: () => Navigator.pop(context, ImageSource.gallery),
                                ),
                              ],
                            ),
                          ),
                        );

                        if (source != null) {
                          final ImagePicker picker = ImagePicker();
                          final XFile? image = await picker.pickImage(source: source);
                          if (image != null) {
                            setState(() {
                              selectedFile = fp.PlatformFile(
                                name: image.name,
                                size: 0,
                                path: image.path,
                              );
                            });
                          }
                        }
                      },
                    ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancel', style: TextStyle(color: AppColors.textMuted)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
                  onPressed: () {
                    if (selectedFile != null) {
                      ref.read(bookingsProvider.notifier).saveServiceProof(bookingId, titleController.text, selectedFile!);
                      Navigator.pop(ctx);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a file')));
                    }
                  },
                  child: const Text('Submit'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ─────────────────── OTP DIALOG ───────────────────
  void _showOtpDialog(BuildContext context, WidgetRef ref, int bookingId, {required bool isStart}) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(isStart ? Icons.lock_open : Icons.verified_outlined,
                color: AppColors.primary, size: 22),
            const SizedBox(width: 10),
            Text(isStart ? 'Enter Start OTP' : 'Enter Completion OTP',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isStart
                  ? 'Enter the 4-digit OTP provided by the customer to start the job.'
                  : 'Enter the 4-digit OTP provided by the customer to mark the job complete.',
              style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: ctrl,
              keyboardType: TextInputType.number,
              maxLength: 6,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'e.g. 1234',
                filled: true,
                fillColor: const Color(0xFFF8FAFC),
                counterText: '',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppColors.primary),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textMuted)),
          ),
          ElevatedButton(
            onPressed: () async {
              final otp = ctrl.text.trim();
              if (otp.isEmpty) return;
              Navigator.pop(ctx);
              bool ok = isStart
                  ? await ref.read(bookingsProvider.notifier).verifyStartOtp(bookingId, otp)
                  : await ref.read(bookingsProvider.notifier).verifyCompletionOtp(bookingId, otp);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(ok
                      ? (isStart ? 'Job started successfully!' : 'Job completed successfully!')
                      : 'Invalid OTP. Please try again.'),
                  backgroundColor: ok ? Colors.green : Colors.red,
                ));
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Verify OTP'),
          ),
        ],
      ),
    );
  }

  // ─────────────────── HELPERS ───────────────────
  Widget _infoCol(String label, String value,
      {bool isStatus = false, bool isAmount = false, bool isMethod = false, bool isPaymentStatus = false}) {
    Color valueColor = AppColors.textSecondary;
    if (isStatus) valueColor = _statusColor(value);
    if (isAmount || isMethod) valueColor = AppColors.primary;
    if (isPaymentStatus) valueColor = Colors.green;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
        const SizedBox(height: 6),
        Text(value, style: TextStyle(color: valueColor, fontSize: 13, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _sumRow(String label, String value, {Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 13)),
        Text(value,
            style: TextStyle(color: color ?? AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w500)),
      ],
    );
  }

  BoxDecoration _card() => BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: const [
          BoxShadow(color: Color(0x08000000), blurRadius: 12, offset: Offset(0, 4)),
        ],
      );

  Color _statusColor(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING':
      case 'WAITING':
      case 'PAYMENT_PENDING':
        return Colors.redAccent;
      case 'ACCEPTED':
      case 'PROVIDER_ASSIGNED':
      case 'ADMIN_ASSIGNED':
        return Colors.green;
      case 'HANDYMAN_ASSIGNED':
      case 'HANDYMAN_ACCEPTED':
        return Colors.orange;
      case 'ARRIVED':
      case 'STARTED':
      case 'RESUMED':
        return const Color(0xFF06B6D4);
      case 'PAUSED':
        return AppColors.warning;
      case 'COMPLETED':
      case 'CUSTOMER_VERIFIED':
      case 'INVOICE_GENERATED':
        return AppColors.primary;
      case 'PAID':
      case 'CLOSED':
        return AppColors.success;
      case 'REJECTED':
      case 'FAILED':
        return const Color(0xFFEF4444);
      default:
        return AppColors.textSecondary;
    }
  }
}
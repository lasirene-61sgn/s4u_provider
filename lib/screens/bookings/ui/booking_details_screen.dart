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

    if (state.isLoading && state.bookings.isEmpty) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final booking = state.bookings.firstWhereOrNull((b) => b.id == widget.bookingId);
    final b = booking ?? (Get.arguments as Booking?);

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

    final content = LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 850;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTopBar(b, state),
                const SizedBox(height: 20),
                if (isWide)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 7,
                        child: Column(
                          children: [
                            _buildDetailsBox(b),
                            const SizedBox(height: 20),
                            _buildUserProviderCards(b),
                          ],
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        flex: 3,
                        child: _buildPaymentSummary(b),
                      ),
                    ],
                  )
                else
                  Column(
                    children: [
                      _buildDetailsBox(b),
                      const SizedBox(height: 16),
                      _buildUserProviderCards(b),
                      const SizedBox(height: 16),
                      _buildPaymentSummary(b),
                    ],
                  ),
              ],
            ),
          );
        },
      );

    if (widget.onBack != null) {
      return Container(
        color: const Color(0xFFF8FAFC),
        child: content,
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: content,
    );
  }

  // ─────────────────── TOP BAR ───────────────────
  Widget _buildTopBar(Booking b, BookingsState state) {
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 16,
      runSpacing: 16,
      children: [

        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            if (b.bookingStatus?.toLowerCase() == 'completed')
              state.downloadingInvoiceId == b.id
                ? ElevatedButton(
                    onPressed: null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      disabledBackgroundColor: AppColors.primary.withOpacity(0.7),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const SizedBox(
                      width: 20, height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)
                    ),
                  )
                : ElevatedButton.icon(
                    onPressed: () async => await ref.read(bookingsProvider.notifier).downloadInvoice(b.id),
                    icon: const Icon(Icons.download, size: 16),
                    label: const Text('Download Invoice', style: TextStyle(fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                if (widget.onBack != null) {
                  widget.onBack!();
                } else {
                  Get.back();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                foregroundColor: AppColors.primary,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('<< BACK', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ],
    );
  }

  // ─────────────────── BOOKING DETAILS BOX ───────────────────
  Widget _buildDetailsBox(Booking booking) {
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
                _buildActionButtons(context, ref, booking),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────── CUSTOMER, PROVIDER, HANDYMAN CARDS ───────────────────
  Widget _buildUserProviderCards(Booking booking) {
    return LayoutBuilder(builder: (ctx, c) {
      final isWide = c.maxWidth > 800; // Use a wider breakpoint since we have 3 cards now
      
      final customerCard = _personCard('Customer', booking.userName, booking.userPhone, booking.userEmail, booking.userImage, booking.address);
      final providerCard = _personCard('Provider', booking.providerName, booking.providerPhone, booking.providerEmail, booking.providerImage, booking.providerAddress);
      
      Widget? handymanCard;
      if (booking.handymanName != null || booking.bookingStatus.contains('HANDYMAN') || booking.bookingStatus == 'ACCEPTED' || booking.bookingStatus.contains('ASSIGNED')) {
        handymanCard = _personCard('Handyman', booking.handymanName, booking.handymanPhone, booking.handymanEmail, booking.handymanImage, booking.handymanAddress);
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
  Widget _buildActionButtons(BuildContext context, WidgetRef ref, Booking booking) {
    final status = (booking.bookingStatus ?? '').toLowerCase();
    final notifier = ref.read(bookingsProvider.notifier);
    final role = SharedPreferenceHelper.getString('role') ?? 'PROVIDER';
    final isHandyman = role == 'HANDYMAN';

    Widget btn(String label, {Color bg = AppColors.primary, VoidCallback? onTap, IconData? icon}) {
      return Container(
        margin: const EdgeInsets.only(left: 8),
        child: icon != null
            ? ElevatedButton.icon(
                icon: Icon(icon, size: 15),
                label: Text(label),
                onPressed: onTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: bg,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              )
            : ElevatedButton(
                onPressed: onTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: bg,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: Text(label),
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
    if (status == 'pending' || status == 'pending_approval' || status == 'waiting') {
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

    // ACCEPT
    if (status == 'accept') {
      final hasHandyman = booking.handymanName != null && booking.handymanName!.isNotEmpty;
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
          if (status == 'in_progress')
            btn('Complete', bg: const Color(0xFF10B981), icon: Icons.check_circle,
                onTap: () => notifier.updateBookingStatus(booking.id, 'completed', paymentStatus: booking.paymentStatus ?? 'pending')),
        ],
      );
    }

    // COMPLETED
    if (status == 'completed') {
      return const SizedBox.shrink();
    }

    // Default: show status badge
    return statusBadge(status.replaceAll('_', ' ').toUpperCase(),
        color: _statusColor(status), icon: Icons.info_outline);
  }

  // ─────────────────── ASSIGN HANDYMAN DIALOG ───────────────────
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
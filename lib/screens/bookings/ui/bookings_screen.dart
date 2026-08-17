import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../handyman/riverpod/handyman_notifier.dart'; // To get handymenProvider

import '../riverpod/bookings_notifier.dart';
import '../model/booking_model.dart';
import 'booking_details_screen.dart';
import '../../../core/storage/shared_preference_helper.dart';
import '../../../core/widgets/image_viewer.dart';

// --- UI ---
class BookingsScreen extends ConsumerStatefulWidget {
  const BookingsScreen({super.key});

  @override
  ConsumerState<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends ConsumerState<BookingsScreen> {

  int? _selectedBookingId;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
        ref.read(bookingsProvider.notifier).loadMore();
      }
    });
    Future.microtask(() => ref.read(bookingsProvider.notifier).refresh());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {


    final state = ref.watch(bookingsProvider);
    const bool isMobile = true;

    return Padding(
      padding: EdgeInsets.only(bottom: isMobile ? 16.0 : 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isMobile) const Padding(
            padding: EdgeInsets.only(left: 24.0, top: 24.0, bottom: 24.0),
            child: Text('Bookings', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primaryDark)),
          ),
          Expanded(
            child: Container(
              decoration: isMobile ? null : BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: Column(
                children: [

                  if (!isMobile) Container(
                    color: const Color(0xFF635BFF),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: const Row(
                      children: [
                        SizedBox(width: 60, child: Text('ID', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13))),
                        Expanded(flex: 2, child: Text('Service', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13))),
                        Expanded(child: Text('Booking Date', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13))),
                        Expanded(flex: 2, child: Text('User', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13))),
                        Expanded(child: Text('Status', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13))),
                        Expanded(child: Text('Total Amount', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13))),
                        Expanded(child: Text('Payment Status', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13))),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Builder(
                      builder: (context) {
                        if (state.isLoading && state.bookings.isEmpty) {
                          return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                        }
                        if (state.error != null && state.bookings.isEmpty) {
                          return Center(child: Text('Error: ${state.error}'));
                        }
                        if (state.bookings.isEmpty) {
                          return const Center(child: Text('No data available in table', style: TextStyle(color: AppColors.textSecondary)));
                        }
                        return RefreshIndicator(
                          onRefresh: () async => ref.read(bookingsProvider.notifier).refresh(),
                          child: ListView.separated(
                            controller: _scrollController,
                            itemCount: state.bookings.length + (state.isFetchingMore ? 1 : 0),
                            separatorBuilder: (context, index) => isMobile ? const SizedBox(height: 16) : const Divider(height: 1, color: AppColors.borderLight),
                            itemBuilder: (context, index) {
                              if (index == state.bookings.length) {
                                return const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 16.0),
                                  child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
                                );
                              }
                              return isMobile ? _buildBookingCard(state.bookings[index]) : _buildBookingRow(state.bookings[index]);
                            },
                          ),
                        );
                      }
                    ),
                  ),
                  if (!isMobile) const Divider(height: 1, color: AppColors.borderLight),
                  if (!isMobile) Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Wrap(
                      alignment: WrapAlignment.spaceBetween,
                      runSpacing: 16.0,
                      children: [
                        Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            const Text('Show ', style: TextStyle(color: AppColors.textSecondary)),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                border: Border.all(color: AppColors.borderLight),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Row(
                                children: [
                                  Text('10', style: TextStyle(color: AppColors.textSecondary)),
                                  SizedBox(width: 8),
                                  Icon(Icons.unfold_more, size: 16, color: AppColors.textMuted),
                                ],
                              ),
                            ),
                            const Text(' entries', style: TextStyle(color: AppColors.textSecondary)),
                            const SizedBox(width: 16),
                            Text('Showing 1 to ${state.bookings.length} of ${state.bookings.length} entries', style: const TextStyle(color: AppColors.textMuted)),
                          ],
                        ),
                        Row(
                          children: [
                            IconButton(onPressed: null, icon: const Icon(Icons.chevron_left)),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(color: const Color(0xFF635BFF), borderRadius: BorderRadius.circular(4)),
                              child: const Text('1', style: TextStyle(color: Colors.white)),
                            ),
                            IconButton(onPressed: null, icon: const Icon(Icons.chevron_right)),
                          ],
                        ),
                      ],
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

  Widget _buildBookingRow(Booking booking) {
    Color statusColor;
    String statusText = booking.bookingStatus.replaceAll('_', ' ');
    
    switch (booking.bookingStatus) {
      case 'COMPLETED':
      case 'PAID':
      case 'CLOSED':
      case 'CUSTOMER_VERIFIED':
      case 'INVOICE_GENERATED':
      case 'ACCEPTED':
        statusColor = Colors.green;
        break;
      case 'PROVIDER_ASSIGNED':
      case 'ADMIN_ASSIGNED':
      case 'PENDING':
        statusColor = Colors.orange;
        break;
      default:
        statusColor = Colors.green;
    }

    return InkWell(
      onTap: () {
        Get.to(() => BookingDetailsScreen(bookingId: booking.id));
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            SizedBox(width: 60, child: Text('#${booking.id}', style: const TextStyle(color: Color(0xFF635BFF), fontWeight: FontWeight.bold))),
            Expanded(
              flex: 2,
              child: Text('${booking.serviceName ?? 'N/A'}\n', style: const TextStyle(color: Color(0xFF635BFF), fontSize: 13, fontWeight: FontWeight.w500)),
            ),
            Expanded(
              child: Text(
                booking.bookingDate ?? 'N/A',
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w500),
              ),
            ),
            Expanded(
              flex: 2,
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      final imageProvider = booking.userImage != null 
                          ? NetworkImage(booking.userImage!.startsWith('http') ? booking.userImage! : 'http://127.0.0.1:8080/api${booking.userImage}')
                          : const AssetImage('assets/s4u_logo.jpeg') as ImageProvider;
                      ImageViewer.show(context, imageProvider);
                    },
                    child: CircleAvatar(
                      radius: 16,
                      backgroundImage: booking.userImage != null 
                          ? NetworkImage(booking.userImage!.startsWith('http') ? booking.userImage! : 'http://127.0.0.1:8080/api${booking.userImage}')
                          : const AssetImage('assets/s4u_logo.jpeg') as ImageProvider,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(booking.userName ?? 'Unknown User', style: const TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.bold, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
                        Text(booking.userEmail ?? 'No email provided', style: const TextStyle(color: AppColors.textMuted, fontSize: 11), maxLines: 1, overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(statusText, style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
            Expanded(child: Text(booking.totalAmount != null ? '₹${booking.totalAmount!.toStringAsFixed(2)}' : 'N/A', style: const TextStyle(color: AppColors.textSecondary, fontSize: 13))),
            Expanded(
              child: Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF635BFF),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(booking.paymentStatus ?? 'Pending', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingCard(Booking booking) {
    Color statusColor;
    String statusText = booking.bookingStatus.replaceAll('_', ' ');
    
    switch (booking.bookingStatus) {
      case 'COMPLETED':
      case 'PAID':
      case 'CLOSED':
      case 'CUSTOMER_VERIFIED':
      case 'INVOICE_GENERATED':
      case 'ACCEPTED':
        statusColor = Colors.green;
        break;
      case 'PROVIDER_ASSIGNED':
      case 'ADMIN_ASSIGNED':
      case 'PENDING':
        statusColor = Colors.orange;
        break;
      default:
        statusColor = Colors.green;
    }

    return InkWell(
      onTap: () {
        Get.to(() => BookingDetailsScreen(bookingId: booking.id));
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderLight),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('#${booking.id}', style: const TextStyle(color: Color(0xFF635BFF), fontWeight: FontWeight.bold)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(statusText, style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text('${booking.serviceName ?? 'N/A'}', style: const TextStyle(color: Color(0xFF635BFF), fontSize: 15, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(booking.bookingDate ?? 'N/A', style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w500)),
            const SizedBox(height: 16),
            const Divider(height: 1, color: AppColors.borderLight),
            const SizedBox(height: 16),
            Row(
              children: [
                  GestureDetector(
                    onTap: () {
                      final imageProvider = booking.userImage != null 
                          ? NetworkImage(booking.userImage!.startsWith('http') ? booking.userImage! : 'http://127.0.0.1:8080/api${booking.userImage}')
                          : const AssetImage('assets/s4u_logo.jpeg') as ImageProvider;
                      ImageViewer.show(context, imageProvider);
                    },
                    child: CircleAvatar(
                      radius: 16,
                      backgroundImage: booking.userImage != null 
                          ? NetworkImage(booking.userImage!.startsWith('http') ? booking.userImage! : 'http://127.0.0.1:8080/api${booking.userImage}')
                          : const AssetImage('assets/s4u_logo.jpeg') as ImageProvider,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(booking.userName ?? 'Unknown User', style: const TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.bold, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
                        Text(booking.userEmail ?? 'No email provided', style: const TextStyle(color: AppColors.textMuted, fontSize: 11), maxLines: 1, overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Total Amount', style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
                    Text(booking.totalAmount != null ? '₹${booking.totalAmount!.toStringAsFixed(2)}' : 'N/A', style: const TextStyle(color: AppColors.textSecondary, fontSize: 14, fontWeight: FontWeight.bold)),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF635BFF),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(booking.paymentStatus ?? 'Pending', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

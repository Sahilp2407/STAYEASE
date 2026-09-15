import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/hotel_models.dart';
import '../services/app_state.dart';

const _kPrimary = Color(0xFF6F8068); // Sage Green
const _kAccent = Color(0xFFC98F65); // Muted Terracotta
const _kText = Color(0xFF252923); // Deep Charcoal
const _kTextMuted = Color(0xFF60675D); // Olive/Charcoal Muted
const _kTextFaint = Color(0xFF8F988A); // Faint Sage Charcoal
const _kBorder = Color(0xFFE5E2D8); // Linen Warm Border
const _kCard = Color(0xFFFFFFFF); // Pure White
const _kBg = Color(0xFFF7F5EF); // Warm Cream

class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime dt) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${dt.day} ${months[dt.month - 1]}';
  }

  void _showBookingDetailsModal(Booking booking) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: _kCard,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: _kBorder,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Booking Voucher',
                    style: GoogleFonts.cormorantGaramond(
                      color: _kText,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    booking.id,
                    style: GoogleFonts.montserrat(
                      color: _kPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                booking.hotel.name,
                style: GoogleFonts.montserrat(color: _kText, fontSize: 15, fontWeight: FontWeight.w600),
              ),
              Text(
                '${booking.room.name} • ${booking.hotel.location}',
                style: GoogleFonts.montserrat(color: _kTextMuted, fontSize: 12),
              ),
              const SizedBox(height: 16),
              const Divider(color: _kBorder),
              const SizedBox(height: 12),
              _modalRow('Dates', '${_formatDate(booking.checkIn)} – ${_formatDate(booking.checkOut)} (${booking.nights} Nights)'),
              const SizedBox(height: 8),
              _modalRow('Guests', '${booking.adults} Adults, ${booking.roomsCount} Suite'),
              const SizedBox(height: 8),
              _modalRow('Lead Guest', booking.guestName),
              const SizedBox(height: 8),
              _modalRow('Payment Method', booking.paymentMethod),
              const SizedBox(height: 8),
              _modalRow('Total Paid', '₹${booking.totalAmount}', isBold: true),
              const SizedBox(height: 20),
              if (booking.status == BookingStatus.upcoming)
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.redAccent,
                      side: const BorderSide(color: Colors.redAccent),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      AppState.instance.cancelBooking(booking.id);
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Booking successfully cancelled')),
                      );
                    },
                    child: const Text('Cancel Reservation'),
                  ),
                ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  Widget _modalRow(String label, String val, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: GoogleFonts.montserrat(color: _kTextMuted, fontSize: 12)),
        Text(
          val,
          style: GoogleFonts.montserrat(
            color: isBold ? _kAccent : _kText,
            fontSize: isBold ? 14 : 12.5,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w600,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      appBar: AppBar(
        backgroundColor: _kBg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: _kText),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'My Bookings',
          style: GoogleFonts.cormorantGaramond(
            color: _kText,
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: _kPrimary,
          indicatorWeight: 2.5,
          labelColor: _kPrimary,
          unselectedLabelColor: _kTextFaint,
          labelStyle: GoogleFonts.montserrat(fontWeight: FontWeight.w700, fontSize: 13),
          unselectedLabelStyle: GoogleFonts.montserrat(fontWeight: FontWeight.w500, fontSize: 13),
          tabs: const [
            Tab(text: 'Upcoming'),
            Tab(text: 'Completed'),
            Tab(text: 'Cancelled'),
          ],
        ),
      ),
      body: ListenableBuilder(
        listenable: AppState.instance,
        builder: (context, _) {
          final allBookings = AppState.instance.bookings;
          final upcoming = allBookings.where((b) => b.status == BookingStatus.upcoming).toList();
          final completed = allBookings.where((b) => b.status == BookingStatus.completed).toList();
          final cancelled = allBookings.where((b) => b.status == BookingStatus.cancelled).toList();

          return TabBarView(
            controller: _tabController,
            children: [
              _buildBookingList(upcoming, BookingStatus.upcoming),
              _buildBookingList(completed, BookingStatus.completed),
              _buildBookingList(cancelled, BookingStatus.cancelled),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBookingList(List<Booking> list, BookingStatus status) {
    if (list.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              status == BookingStatus.upcoming
                  ? Icons.calendar_today_rounded
                  : status == BookingStatus.completed
                      ? Icons.hotel_rounded
                      : Icons.cancel_outlined,
              color: _kTextFaint,
              size: 48,
            ),
            const SizedBox(height: 12),
            Text(
              status == BookingStatus.upcoming
                  ? 'No upcoming stays'
                  : status == BookingStatus.completed
                      ? 'No completed stays yet'
                      : 'No cancelled bookings',
              style: GoogleFonts.cormorantGaramond(
                color: _kText,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Your future reservations will appear here.',
              style: GoogleFonts.montserrat(color: _kTextMuted, fontSize: 12),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: list.length,
      itemBuilder: (ctx, i) {
        final b = list[i];
        final isUpcoming = b.status == BookingStatus.upcoming;

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: _kCard,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _kBorder),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF252923).withValues(alpha: 0.04),
                blurRadius: 12,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Status Badge Header
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: isUpcoming
                            ? _kPrimary.withValues(alpha: 0.12)
                            : b.status == BookingStatus.completed
                                ? const Color(0x1A4CAF50)
                                : const Color(0x1AF44336),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isUpcoming
                                ? Icons.verified_rounded
                                : b.status == BookingStatus.completed
                                    ? Icons.done_all_rounded
                                    : Icons.close_rounded,
                            size: 13,
                            color: isUpcoming
                                ? _kPrimary
                                : b.status == BookingStatus.completed
                                    ? Colors.green
                                    : Colors.redAccent,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            isUpcoming
                                ? 'Confirmed Stay'
                                : b.status == BookingStatus.completed
                                    ? 'Completed'
                                    : 'Cancelled',
                            style: GoogleFonts.montserrat(
                              color: isUpcoming
                                  ? _kPrimary
                                  : b.status == BookingStatus.completed
                                      ? Colors.green
                                      : Colors.redAccent,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      b.id,
                      style: GoogleFonts.montserrat(
                        color: _kTextFaint,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              // Hotel Info
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: SizedBox(
                        width: 64,
                        height: 64,
                        child: Image.network(
                          b.hotel.images.first,
                          fit: BoxFit.cover,
                          errorBuilder: (ctx, err, stack) => Container(color: _kPrimary),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            b.hotel.name,
                            style: GoogleFonts.cormorantGaramond(
                              color: _kText,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            b.room.name,
                            style: GoogleFonts.montserrat(
                              color: _kPrimary,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            b.hotel.location,
                            style: GoogleFonts.montserrat(
                              color: _kTextMuted,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const Divider(color: _kBorder, height: 16),

              // Dates & Guests
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'DATES',
                          style: GoogleFonts.montserrat(color: _kTextFaint, fontSize: 9.5, fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${_formatDate(b.checkIn)} – ${_formatDate(b.checkOut)}',
                          style: GoogleFonts.montserrat(color: _kText, fontSize: 12.5, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'TOTAL',
                          style: GoogleFonts.montserrat(color: _kTextFaint, fontSize: 9.5, fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '₹${b.totalAmount}',
                          style: GoogleFonts.cormorantGaramond(color: _kAccent, fontSize: 18, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // View Details CTA
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                child: SizedBox(
                  width: double.infinity,
                  height: 42,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _kPrimary,
                      side: const BorderSide(color: _kPrimary),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () => _showBookingDetailsModal(b),
                    child: Text(
                      'View Details',
                      style: GoogleFonts.montserrat(fontSize: 12.5, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

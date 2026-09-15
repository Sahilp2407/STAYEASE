import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/hotel_models.dart';
import 'my_bookings_screen.dart';

const _kPrimary = Color(0xFF6F8068); // Sage Green
const _kAccent = Color(0xFFC98F65); // Muted Terracotta
const _kText = Color(0xFF252923); // Deep Charcoal
const _kTextMuted = Color(0xFF60675D); // Olive/Charcoal Muted
const _kBorder = Color(0xFFE5E2D8); // Linen Warm Border
const _kCard = Color(0xFFFFFFFF); // Pure White
const _kBg = Color(0xFFF7F5EF); // Warm Cream

class BookingConfirmationScreen extends StatefulWidget {
  final Booking booking;

  const BookingConfirmationScreen({super.key, required this.booking});

  @override
  State<BookingConfirmationScreen> createState() => _BookingConfirmationScreenState();
}

class _BookingConfirmationScreenState extends State<BookingConfirmationScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _checkAnimController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _checkAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _scaleAnimation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _checkAnimController, curve: Curves.elasticOut),
    );
    _fadeAnimation = CurvedAnimation(parent: _checkAnimController, curve: Curves.easeIn);

    _checkAnimController.forward();
  }

  @override
  void dispose() {
    _checkAnimController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime dt) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    final b = widget.booking;

    return Scaffold(
      backgroundColor: _kBg,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 16),

              // Animated Checkmark Icon
              ScaleTransition(
                scale: _scaleAnimation,
                child: Container(
                  width: 84,
                  height: 84,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _kPrimary,
                    boxShadow: [
                      BoxShadow(
                        color: _kPrimary.withValues(alpha: 0.35),
                        blurRadius: 28,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(Icons.check_rounded, color: Colors.white, size: 48),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // "Booking Confirmed! 🎉"
              FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  children: [
                    Text(
                      'Booking Confirmed! 🎉',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.cormorantGaramond(
                        color: _kText,
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Your stay is successfully booked.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.montserrat(
                        color: _kTextMuted,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // Luxury Voucher Card
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: _kCard,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: _kBorder),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF252923).withValues(alpha: 0.06),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Hotel Photo & Title Header
                    Padding(
                      padding: const EdgeInsets.all(18),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: SizedBox(
                              width: 58,
                              height: 58,
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
                                const SizedBox(height: 2),
                                Row(
                                  children: [
                                    const Icon(Icons.location_on_outlined, color: _kPrimary, size: 13),
                                    const SizedBox(width: 3),
                                    Expanded(
                                      child: Text(
                                        b.hotel.location,
                                        style: GoogleFonts.montserrat(
                                          color: _kTextMuted,
                                          fontSize: 11,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Dashed ticket separator line
                    CustomPaint(
                      painter: _TicketDividerPainter(),
                      child: const SizedBox(height: 16, width: double.infinity),
                    ),

                    // Voucher Details Grid
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                      child: Column(
                        children: [
                          _voucherRow('Booking ID', b.id, isHighlight: true),
                          const Divider(color: _kBorder, height: 18),
                          _voucherRow('Check-in', _formatDate(b.checkIn)),
                          const Divider(color: _kBorder, height: 18),
                          _voucherRow('Check-out', _formatDate(b.checkOut)),
                          const Divider(color: _kBorder, height: 18),
                          _voucherRow('Guests', '${b.adults} Adults • ${b.roomsCount} Room'),
                          const Divider(color: _kBorder, height: 18),
                          _voucherRow('Payment Method', b.paymentMethod),
                          const Divider(color: _kBorder, height: 18),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Total Paid',
                                style: GoogleFonts.montserrat(
                                  color: _kText,
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                '₹${b.totalAmount}',
                                style: GoogleFonts.cormorantGaramond(
                                  color: _kAccent,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // Action Buttons: [ View Booking ] and [ Back to Home ]
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _kPrimary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    shadowColor: _kPrimary.withValues(alpha: 0.3),
                  ),
                  onPressed: () {
                    // Navigate to My Bookings Screen
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (_) => const MyBookingsScreen(),
                      ),
                    );
                  },
                  child: Text(
                    'View Booking',
                    style: GoogleFonts.montserrat(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _kText,
                    side: const BorderSide(color: _kBorder),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () {
                    // Return all the way to Home Dashboard
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  child: Text(
                    'Back to Home',
                    style: GoogleFonts.montserrat(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _voucherRow(String label, String value, {bool isHighlight = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.montserrat(
            color: _kTextMuted,
            fontSize: 12.5,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.montserrat(
            color: isHighlight ? _kPrimary : _kText,
            fontSize: 12.5,
            fontWeight: isHighlight ? FontWeight.w700 : FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

// Decorative Ticket Dashed Line with Notches
class _TicketDividerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final dashPaint = Paint()
      ..color = _kBorder
      ..strokeWidth = 1.2;

    const dashWidth = 5.0;
    const dashSpace = 4.0;
    double startX = 14;

    while (startX < size.width - 14) {
      canvas.drawLine(Offset(startX, size.height / 2), Offset(startX + dashWidth, size.height / 2), dashPaint);
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

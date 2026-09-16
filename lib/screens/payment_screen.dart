import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/hotel_models.dart';
import '../services/app_state.dart';
import 'booking_confirmation_screen.dart';

const _kPrimary = Color(0xFF6F8068); // Sage Green
const _kAccent = Color(0xFFC98F65); // Muted Terracotta
const _kText = Color(0xFF252923); // Deep Charcoal
const _kTextMuted = Color(0xFF60675D); // Olive/Charcoal Muted
const _kTextFaint = Color(0xFF8F988A); // Faint Sage Charcoal
const _kBorder = Color(0xFFE5E2D8); // Linen Warm Border
const _kCard = Color(0xFFFFFFFF); // Pure White
const _kCardAlt = Color(0xFFF0EDE5); // Warm Linen Cream
const _kBg = Color(0xFFF7F5EF); // Warm Cream

// UPI, Card, Net Banking aur Pay at Hotel ke options ke sath checkout screen
class PaymentScreen extends StatefulWidget {
  final Hotel hotel;
  final Room room;
  final DateTime checkIn;
  final DateTime checkOut;
  final int nights;
  final int adults;
  final int roomsCount;
  final String guestName;
  final String guestEmail;
  final String guestPhone;
  final String specialRequests;
  final int roomTotal;
  final int taxes;
  final int serviceFee;
  final int totalAmount;

  const PaymentScreen({
    super.key,
    required this.hotel,
    required this.room,
    required this.checkIn,
    required this.checkOut,
    required this.nights,
    required this.adults,
    required this.roomsCount,
    required this.guestName,
    required this.guestEmail,
    required this.guestPhone,
    required this.specialRequests,
    required this.roomTotal,
    required this.taxes,
    required this.serviceFee,
    required this.totalAmount,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  int _selectedPaymentMethod = 0; // 0: UPI, 1: Card, 2: NetBanking, 3: PayAtHotel
  int _selectedUpiApp = 0; // 0: GPay, 1: PhonePe, 2: Paytm
  bool _isProcessing = false;

  final _cardNumberController = TextEditingController(text: '4242 •••• •••• 1024');
  final _cardExpiryController = TextEditingController(text: '08/29');
  final _cardCvvController = TextEditingController(text: '884');
  final _upiIdController = TextEditingController(text: 'sahil@okhdfcbank');

  @override
  void dispose() {
    _cardNumberController.dispose();
    _cardExpiryController.dispose();
    _cardCvvController.dispose();
    _upiIdController.dispose();
    super.dispose();
  }

  // Payment process karke unique booking ID generate karna aur Firestore me save karna
  void _onPay() async {
    setState(() => _isProcessing = true);
    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;

    // Generate random booking ID matching spec style: #STY928374
    final randomNum = 900000 + math.Random().nextInt(99999);
    final bookingId = '#STY$randomNum';

    final paymentMethodNames = ['Google Pay (UPI)', 'Credit Card (••1024)', 'Net Banking', 'Pay at Hotel'];

    final newBooking = Booking(
      id: bookingId,
      userId: AppState.instance.currentUid,
      hotel: widget.hotel,
      room: widget.room,
      checkIn: widget.checkIn,
      checkOut: widget.checkOut,
      nights: widget.nights,
      adults: widget.adults,
      roomsCount: widget.roomsCount,
      guestName: widget.guestName,
      guestEmail: widget.guestEmail,
      guestPhone: widget.guestPhone,
      specialRequests: widget.specialRequests,
      roomTotal: widget.roomTotal,
      taxes: widget.taxes,
      serviceFee: widget.serviceFee,
      totalAmount: widget.totalAmount,
      status: BookingStatus.upcoming,
      paymentMethod: paymentMethodNames[_selectedPaymentMethod],
      bookedAt: DateTime.now(),
    );

    // Save to global reactive state
    AppState.instance.addBooking(newBooking);

    setState(() => _isProcessing = false);

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => BookingConfirmationScreen(booking: newBooking),
      ),
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
          'Secure Payment',
          style: GoogleFonts.cormorantGaramond(
            color: _kText,
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 110),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Summary Header Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _kCard,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: _kBorder),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF252923).withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: SizedBox(
                      width: 50,
                      height: 50,
                      child: Image.network(
                        widget.hotel.images.first,
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
                          widget.hotel.name,
                          style: GoogleFonts.cormorantGaramond(
                            color: _kText,
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '${widget.room.name} • 2 Nights',
                          style: GoogleFonts.montserrat(color: _kTextMuted, fontSize: 11),
                        ),
                        Text(
                          'Guest: ${widget.guestName}',
                          style: GoogleFonts.montserrat(color: _kTextFaint, fontSize: 10.5),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Total',
                        style: GoogleFonts.montserrat(color: _kTextFaint, fontSize: 10.5, fontWeight: FontWeight.w600),
                      ),
                      Text(
                        '₹${widget.totalAmount}',
                        style: GoogleFonts.cormorantGaramond(
                          color: _kAccent,
                          fontSize: 21,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // 2. Payment Methods Accordion
            Text(
              'Select Payment Method',
              style: GoogleFonts.cormorantGaramond(
                color: _kText,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),

            // Option 0: UPI
            _buildPaymentOptionTile(
              index: 0,
              icon: Icons.qr_code_2_rounded,
              title: 'UPI Payment',
              subtitle: 'Google Pay, PhonePe, Paytm, BHIM',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _upiAppPill(0, 'Google Pay'),
                      const SizedBox(width: 8),
                      _upiAppPill(1, 'PhonePe'),
                      const SizedBox(width: 8),
                      _upiAppPill(2, 'Paytm'),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _upiIdController,
                    style: GoogleFonts.montserrat(color: _kText, fontSize: 13),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: _kCardAlt,
                      hintText: 'Enter UPI ID (e.g. mobile@upi)',
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      prefixIcon: const Icon(Icons.alternate_email, color: _kPrimary, size: 18),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // Option 1: Credit / Debit Card
            _buildPaymentOptionTile(
              index: 1,
              icon: Icons.credit_card_rounded,
              title: 'Credit / Debit Card',
              subtitle: 'Visa, Mastercard, RuPay, Amex',
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  TextField(
                    controller: _cardNumberController,
                    style: GoogleFonts.montserrat(color: _kText, fontSize: 13),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: _kCardAlt,
                      hintText: 'Card Number',
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      prefixIcon: const Icon(Icons.payment_rounded, color: _kPrimary, size: 18),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _cardExpiryController,
                          style: GoogleFonts.montserrat(color: _kText, fontSize: 13),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: _kCardAlt,
                            hintText: 'MM/YY',
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: _cardCvvController,
                          obscureText: true,
                          style: GoogleFonts.montserrat(color: _kText, fontSize: 13),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: _kCardAlt,
                            hintText: 'CVV',
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // Option 2: Net Banking
            _buildPaymentOptionTile(
              index: 2,
              icon: Icons.account_balance_rounded,
              title: 'Net Banking',
              subtitle: 'All major Indian banks supported',
              child: Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: ['HDFC Bank', 'ICICI Bank', 'SBI', 'Axis Bank', 'Kotak'].map((b) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _kCardAlt,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: _kBorder),
                      ),
                      child: Text(
                        b,
                        style: GoogleFonts.montserrat(color: _kText, fontSize: 11.5, fontWeight: FontWeight.w600),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

            const SizedBox(height: 10),

            // Option 3: Pay at Hotel
            _buildPaymentOptionTile(
              index: 3,
              icon: Icons.hotel_rounded,
              title: 'Pay at Hotel',
              subtitle: 'Pay via cash or card during check-in',
              child: Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'No immediate deduction. A credit card authorization holds your suite until 6:00 PM on arrival day.',
                  style: GoogleFonts.montserrat(color: _kTextMuted, fontSize: 11.5, height: 1.5),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // 3. Security Encryption Indicator
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.lock_rounded, color: _kPrimary, size: 14),
                  const SizedBox(width: 6),
                  Text(
                    '256-bit Bank Grade SSL Encryption • 100% Safe',
                    style: GoogleFonts.montserrat(
                      color: _kTextMuted,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      // Sticky Payment Button
      bottomNavigationBar: Container(
        padding: EdgeInsets.fromLTRB(20, 12, 20, MediaQuery.of(context).padding.bottom + 12),
        decoration: BoxDecoration(
          color: _kCard,
          border: const Border(top: BorderSide(color: _kBorder)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF252923).withValues(alpha: 0.06),
              blurRadius: 16,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: SizedBox(
          height: 52,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _kPrimary,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              shadowColor: _kPrimary.withValues(alpha: 0.35),
            ),
            onPressed: _isProcessing ? null : _onPay,
            child: _isProcessing
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : Text(
                    'Pay ₹${widget.totalAmount}',
                    style: GoogleFonts.montserrat(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.4,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentOptionTile({
    required int index,
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    final isSelected = _selectedPaymentMethod == index;

    return GestureDetector(
      onTap: () => setState(() => _selectedPaymentMethod = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _kCard,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected ? _kPrimary : _kBorder,
            width: isSelected ? 1.8 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? _kPrimary.withValues(alpha: 0.08)
                  : const Color(0xFF252923).withValues(alpha: 0.03),
              blurRadius: isSelected ? 12 : 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: isSelected ? _kPrimary.withValues(alpha: 0.12) : _kCardAlt,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: isSelected ? _kPrimary : _kTextMuted, size: 20),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.montserrat(
                          color: _kText,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: GoogleFonts.montserrat(
                          color: _kTextMuted,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? _kPrimary : _kBorder,
                      width: isSelected ? 6 : 1.5,
                    ),
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            if (isSelected) child,
          ],
        ),
      ),
    );
  }

  Widget _upiAppPill(int idx, String name) {
    final active = _selectedUpiApp == idx;
    return GestureDetector(
      onTap: () => setState(() => _selectedUpiApp = idx),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: active ? _kPrimary.withValues(alpha: 0.15) : _kCardAlt,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: active ? _kPrimary : _kBorder),
        ),
        child: Text(
          name,
          style: GoogleFonts.montserrat(
            color: active ? _kPrimary : _kTextMuted,
            fontSize: 11,
            fontWeight: active ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

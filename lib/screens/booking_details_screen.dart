import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/hotel_models.dart';
import '../services/app_state.dart';
import 'payment_screen.dart';

// ─── Color Palette: StayEase Boutique Luxury ─────────────────────────────────
const _kPrimary = Color(0xFF6F8068); // Sage Green
const _kPrimaryLight = Color(0xFFF0F4EE); // Soft Sage Tint
const _kAccent = Color(0xFFC98F65); // Muted Terracotta
const _kAccentLight = Color(0xFFFBF4EE); // Soft Terracotta Tint
const _kText = Color(0xFF252923); // Deep Charcoal
const _kTextMuted = Color(0xFF60675D); // Olive/Charcoal Muted
const _kTextFaint = Color(0xFF8F988A); // Faint Sage Charcoal
const _kBorder = Color(0xFFE5E2D8); // Linen Warm Border
const _kCard = Color(0xFFFFFFFF); // Pure White
const _kBg = Color(0xFFF7F5EF); // Warm Cream

// Har guest ke form inputs aur details hold karne ka helper class
class GuestInfo {
  String title; // 'Mr.', 'Ms.', 'Mrs.'
  final TextEditingController firstNameCtrl;
  final TextEditingController lastNameCtrl;
  final TextEditingController? emailCtrl;
  final TextEditingController? phoneCtrl;
  bool isPrimary;
  bool isExpanded;

  GuestInfo({
    this.title = 'Mr.',
    required this.firstNameCtrl,
    required this.lastNameCtrl,
    this.emailCtrl,
    this.phoneCtrl,
    this.isPrimary = false,
    this.isExpanded = true,
  });

  // Text controllers ko memory se dispose karna
  void dispose() {
    firstNameCtrl.dispose();
    lastNameCtrl.dispose();
    emailCtrl?.dispose();
    phoneCtrl?.dispose();
  }
}

// Guest information, stay dates aur fare summary capture karne wali screen
class BookingDetailsScreen extends StatefulWidget {
  final Hotel hotel;
  final Room selectedRoom;

  const BookingDetailsScreen({
    super.key,
    required this.hotel,
    required this.selectedRoom,
  });

  @override
  State<BookingDetailsScreen> createState() => _BookingDetailsScreenState();
}

class _BookingDetailsScreenState extends State<BookingDetailsScreen> {
  final List<GuestInfo> _guests = [];
  final _specialRequestsController = TextEditingController();

  final int _nights = 2;
  final int _roomsCount = 1;
  final DateTime _checkIn = DateTime(2026, 9, 8);
  final DateTime _checkOut = DateTime(2026, 9, 10);

  final List<String> _quickRequests = [
    'Early Check-in',
    'High Floor',
    'Quiet Room',
    'Airport Transfer',
    'Late Check-out',
  ];
  final Set<String> _selectedQuickRequests = {};

  @override
  void initState() {
    super.initState();
    _initGuests();
  }

  // User logged in hone par uski details auto-fill karne ka function
  void _initGuests() {
    final state = AppState.instance;
    String primaryFirst = 'Sahil';
    String primaryLast = 'Pandey';
    String primaryEmail = 'sahil@stayease.com';
    String primaryPhone = '+91 98200 12345';

    if (state.isLoggedIn) {
      // Clean any auth providers suffix like '(Google)'
      final cleanName = state.userName.replaceAll(RegExp(r'\(.*?\)'), '').trim();
      final parts = cleanName.split(' ');
      if (parts.isNotEmpty) primaryFirst = parts.first;
      if (parts.length > 1) primaryLast = parts.sublist(1).join(' ');
      primaryEmail = state.userEmail;
      primaryPhone = state.userPhone;
    }

    // Guest 1: Primary Lead Guest
    _guests.add(
      GuestInfo(
        title: 'Mr.',
        firstNameCtrl: TextEditingController(text: primaryFirst),
        lastNameCtrl: TextEditingController(text: primaryLast),
        emailCtrl: TextEditingController(text: primaryEmail),
        phoneCtrl: TextEditingController(text: primaryPhone),
        isPrimary: true,
        isExpanded: true,
      ),
    );

    // Guest 2: Companion Adult
    _guests.add(
      GuestInfo(
        title: 'Ms.',
        firstNameCtrl: TextEditingController(text: 'Priya'),
        lastNameCtrl: TextEditingController(text: 'Sharma'),
        isPrimary: false,
        isExpanded: true,
      ),
    );
  }

  @override
  void dispose() {
    for (final g in _guests) {
      g.dispose();
    }
    _specialRequestsController.dispose();
    super.dispose();
  }

  // Room capacity check karke naya guest add karne ka function
  void _addGuest() {
    final maxCapacity = widget.selectedRoom.capacity;
    if (_guests.length >= maxCapacity + 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Maximum room capacity is $maxCapacity adults for ${widget.selectedRoom.name}.',
            style: GoogleFonts.montserrat(color: _kBg, fontSize: 12),
          ),
          backgroundColor: _kText,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    setState(() {
      _guests.add(
        GuestInfo(
          title: 'Mr.',
          firstNameCtrl: TextEditingController(),
          lastNameCtrl: TextEditingController(),
          isPrimary: false,
          isExpanded: true,
        ),
      );
    });
  }

  // Guest list se specific companion ko remove karna
  void _removeGuest(int index) {
    if (index == 0) return; // Cannot delete primary lead guest
    setState(() {
      final removed = _guests.removeAt(index);
      removed.dispose();
    });
  }

  // Quick special request chips (e.g. Early Check-in) toggle karna
  void _toggleQuickRequest(String req) {
    setState(() {
      if (_selectedQuickRequests.contains(req)) {
        _selectedQuickRequests.remove(req);
      } else {
        _selectedQuickRequests.add(req);
      }

      // Sync into the controller text cleanly
      _specialRequestsController.text = _selectedQuickRequests.join(', ');
    });
  }

  // Primary guest validate karke bill calculate karna aur Payment Screen open karna
  void _onContinueToPayment() {
    // Validate primary guest
    final primary = _guests.first;
    if (primary.firstNameCtrl.text.trim().isEmpty || primary.lastNameCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter first and last name for Primary Guest.',
              style: GoogleFonts.montserrat(color: _kBg)),
          backgroundColor: _kText,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    final roomTotal = widget.selectedRoom.pricePerNight * _nights;
    final taxes = (roomTotal * 0.18).round();
    const serviceFee = 500;
    final totalAmount = roomTotal + taxes + serviceFee;

    // Collect all guest names for confirmation record
    final guestNamesList = _guests
        .map((g) => '${g.title} ${g.firstNameCtrl.text.trim()} ${g.lastNameCtrl.text.trim()}'.trim())
        .where((n) => n.isNotEmpty)
        .join(', ');

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PaymentScreen(
          hotel: widget.hotel,
          room: widget.selectedRoom,
          checkIn: _checkIn,
          checkOut: _checkOut,
          nights: _nights,
          adults: _guests.length,
          roomsCount: _roomsCount,
          guestName: guestNamesList,
          guestEmail: primary.emailCtrl?.text.trim() ?? 'sahil@stayease.com',
          guestPhone: primary.phoneCtrl?.text.trim() ?? '+91 98200 12345',
          specialRequests: _specialRequestsController.text.trim(),
          roomTotal: roomTotal,
          taxes: taxes,
          serviceFee: serviceFee,
          totalAmount: totalAmount,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hotel = widget.hotel;
    final room = widget.selectedRoom;

    final roomTotal = room.pricePerNight * _nights;
    final taxes = (roomTotal * 0.18).round();
    const serviceFee = 500;
    final totalAmount = roomTotal + taxes + serviceFee;

    return Scaffold(
      backgroundColor: _kBg,
      appBar: AppBar(
        backgroundColor: _kBg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: _kText, size: 18),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Booking Details',
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
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 110),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── 1. Your Stay Card ────────────────────────────────────────────
            _buildStayCard(hotel, room),
            const SizedBox(height: 16),

            // ── 2. All Guests Details Section (Crisp, Premium UI) ────────────
            _buildAllGuestsSection(),
            const SizedBox(height: 16),

            // ── 3. Special Requests Card with Quick Chips ────────────────────
            _buildSpecialRequestsCard(),
            const SizedBox(height: 16),

            // ── 4. Itemized Price Breakdown ──────────────────────────────────
            _buildPriceBreakdownCard(room, roomTotal, taxes, serviceFee, totalAmount),
          ],
        ),
      ),
      // Sticky Continue to Payment Bottom Bar
      bottomNavigationBar: Container(
        padding: EdgeInsets.fromLTRB(20, 14, 20, MediaQuery.of(context).padding.bottom + 14),
        decoration: BoxDecoration(
          color: _kCard,
          border: const Border(top: BorderSide(color: _kBorder, width: 0.8)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF252923).withValues(alpha: 0.06),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Row(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total Payable (${_guests.length} Guests)',
                  style: GoogleFonts.montserrat(
                    color: _kTextFaint,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '₹${_formatPrice(totalAmount)}',
                  style: GoogleFonts.cormorantGaramond(
                    color: _kText,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const Spacer(),
            SizedBox(
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _kPrimary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 22),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: _onContinueToPayment,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Continue to Payment',
                      style: GoogleFonts.montserrat(
                        fontWeight: FontWeight.w700,
                        fontSize: 13.5,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(Icons.arrow_forward_rounded, size: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // 1. STAY SUMMARY CARD
  // ───────────────────────────────────────────────────────────────────────────
  Widget _buildStayCard(Hotel hotel, Room room) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _kBorder, width: 1),
        boxShadow: [
          BoxShadow(
            color: _kText.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Your Stay',
                style: GoogleFonts.cormorantGaramond(
                  color: _kText,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3.5),
                decoration: BoxDecoration(
                  color: _kPrimaryLight,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.check_circle, color: _kPrimary, size: 12),
                    const SizedBox(width: 4),
                    Text(
                      'Confirmed Selection',
                      style: GoogleFonts.montserrat(
                        color: _kPrimary,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: 64,
                  height: 64,
                  child: Image.network(
                    hotel.images.first,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(color: _kPrimary),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hotel.name,
                      style: GoogleFonts.cormorantGaramond(
                        color: _kText,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        height: 1.15,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      room.name,
                      style: GoogleFonts.montserrat(
                        color: _kPrimary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      hotel.location,
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
          const SizedBox(height: 14),
          const Divider(color: _kBorder, height: 1),
          const SizedBox(height: 12),

          // Check-in / Check-out Row
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'CHECK-IN',
                      style: GoogleFonts.montserrat(
                        color: _kTextFaint,
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.1,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '8 Sep 2026',
                      style: GoogleFonts.cormorantGaramond(
                        color: _kText,
                        fontSize: 16.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'From 2:00 PM',
                      style: GoogleFonts.montserrat(color: _kTextMuted, fontSize: 10.5),
                    ),
                  ],
                ),
              ),
              Container(width: 1, height: 36, color: _kBorder),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'CHECK-OUT',
                      style: GoogleFonts.montserrat(
                        color: _kTextFaint,
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.1,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '10 Sep 2026',
                      style: GoogleFonts.cormorantGaramond(
                        color: _kText,
                        fontSize: 16.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Until 12:00 PM',
                      style: GoogleFonts.montserrat(color: _kTextMuted, fontSize: 10.5),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Nights & Guests Pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: _kBg,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _kBorder.withValues(alpha: 0.6)),
            ),
            child: Row(
              children: [
                const Icon(Icons.nights_stay_outlined, color: _kPrimary, size: 15),
                const SizedBox(width: 6),
                Text(
                  '$_nights Nights',
                  style: GoogleFonts.montserrat(color: _kText, fontSize: 12, fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                const Icon(Icons.group_outlined, color: _kPrimary, size: 15),
                const SizedBox(width: 6),
                Text(
                  '${_guests.length} Adults • 1 Room',
                  style: GoogleFonts.montserrat(color: _kText, fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // 2. ALL GUESTS SECTION (Premium, Breathable, Structured)
  // ───────────────────────────────────────────────────────────────────────────
  Widget _buildAllGuestsSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _kBorder, width: 1),
        boxShadow: [
          BoxShadow(
            color: _kText.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Guest Information',
                style: GoogleFonts.cormorantGaramond(
                  color: _kText,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: _kPrimaryLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${_guests.length} Guests',
                  style: GoogleFonts.montserrat(
                    color: _kPrimary,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Government regulations require names of all staying guests at luxury check-in.',
            style: GoogleFonts.montserrat(
              color: _kTextMuted,
              fontSize: 11.5,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),

          // List of Guest Cards
          for (int i = 0; i < _guests.length; i++) ...[
            _buildGuestCard(i),
            if (i < _guests.length - 1) const SizedBox(height: 14),
          ],

          const SizedBox(height: 14),

          // Add Additional Guest Button (if within room capacity)
          InkWell(
            onTap: _addGuest,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 11),
              decoration: BoxDecoration(
                color: _kBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _kBorder, style: BorderStyle.solid),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.person_add_alt_1_rounded, color: _kPrimary, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'Add Another Guest (Companion)',
                    style: GoogleFonts.montserrat(
                      color: _kPrimary,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
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

  Widget _buildGuestCard(int index) {
    final guest = _guests[index];
    final isPrimary = guest.isPrimary;

    return Container(
      decoration: BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isPrimary ? _kPrimary.withValues(alpha: 0.45) : _kBorder,
          width: isPrimary ? 1.2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Guest Card Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isPrimary ? _kPrimaryLight.withValues(alpha: 0.6) : _kBg,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(13)),
            ),
            child: Row(
              children: [
                // Number Indicator
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isPrimary ? _kPrimary : _kTextFaint,
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: GoogleFonts.montserrat(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  isPrimary ? 'Primary Guest (Lead)' : 'Guest ${index + 1} (Adult Companion)',
                  style: GoogleFonts.montserrat(
                    color: _kText,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (isPrimary) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: _kAccentLight,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Main Contact',
                      style: GoogleFonts.montserrat(
                        color: _kAccent,
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
                const Spacer(),
                // Delete button for additional guests
                if (!isPrimary)
                  IconButton(
                    icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 18),
                    onPressed: () => _removeGuest(index),
                    splashRadius: 16,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
              ],
            ),
          ),

          // Guest Inputs Body
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title Salutation Selector (Mr / Ms / Mrs)
                Row(
                  children: [
                    Text(
                      'Title:',
                      style: GoogleFonts.montserrat(
                        color: _kTextMuted,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Wrap(
                      spacing: 6,
                      children: ['Mr.', 'Ms.', 'Mrs.'].map((t) {
                        final isSelected = guest.title == t;
                        return GestureDetector(
                          onTap: () => setState(() => guest.title = t),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: isSelected ? _kPrimary : _kBg,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: isSelected ? _kPrimary : _kBorder,
                              ),
                            ),
                            child: Text(
                              t,
                              style: GoogleFonts.montserrat(
                                color: isSelected ? Colors.white : _kText,
                                fontSize: 11,
                                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // First Name & Last Name in Clean Row
                Row(
                  children: [
                    Expanded(
                      child: _buildLuxuryInput(
                        label: 'First Name',
                        controller: guest.firstNameCtrl,
                        placeholder: 'e.g. Sahil',
                        leadingIcon: Icons.person_outline_rounded,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildLuxuryInput(
                        label: 'Last Name',
                        controller: guest.lastNameCtrl,
                        placeholder: 'e.g. Pandey',
                      ),
                    ),
                  ],
                ),

                // If Primary Guest: collect Email & Phone for booking vouchers
                if (isPrimary) ...[
                  const SizedBox(height: 12),
                  _buildLuxuryInput(
                    label: 'Email Address (for booking voucher & receipts)',
                    controller: guest.emailCtrl!,
                    placeholder: 'sahil@stayease.com',
                    leadingIcon: Icons.mail_outline_rounded,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 12),
                  _buildLuxuryInput(
                    label: 'Mobile Number (for hotel check-in SMS & concierge)',
                    controller: guest.phoneCtrl!,
                    placeholder: '+91 98200 12345',
                    leadingIcon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                  ),
                ] else ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.check_circle_outline, color: _kPrimary, size: 14),
                      const SizedBox(width: 6),
                      Text(
                        'Will share booking voucher with primary guest',
                        style: GoogleFonts.montserrat(
                          color: _kTextMuted,
                          fontSize: 10.5,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // 3. SPECIAL REQUESTS CARD WITH QUICK CHIPS
  // ───────────────────────────────────────────────────────────────────────────
  Widget _buildSpecialRequestsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _kBorder, width: 1),
        boxShadow: [
          BoxShadow(
            color: _kText.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Special Requests',
                style: GoogleFonts.cormorantGaramond(
                  color: _kText,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Text(
                'Optional',
                style: GoogleFonts.montserrat(
                  color: _kTextFaint,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Tap popular requests or write your personal preferences:',
            style: GoogleFonts.montserrat(
              color: _kTextMuted,
              fontSize: 11.5,
            ),
          ),
          const SizedBox(height: 10),

          // Quick tap pills
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: _quickRequests.map((req) {
              final isSelected = _selectedQuickRequests.contains(req);
              return GestureDetector(
                onTap: () => _toggleQuickRequest(req),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: isSelected ? _kPrimary : _kBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected ? _kPrimary : _kBorder,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isSelected ? Icons.check : Icons.add,
                        color: isSelected ? Colors.white : _kPrimary,
                        size: 13,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        req,
                        style: GoogleFonts.montserrat(
                          color: isSelected ? Colors.white : _kText,
                          fontSize: 11,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),

          // Crisp Text Area
          Container(
            decoration: BoxDecoration(
              color: _kBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _kBorder),
            ),
            child: TextField(
              controller: _specialRequestsController,
              maxLines: 2,
              style: GoogleFonts.montserrat(color: _kText, fontSize: 13),
              decoration: InputDecoration(
                hintText: 'e.g. Quiet room, high floor, anniversary setup...',
                hintStyle: GoogleFonts.montserrat(color: _kTextFaint, fontSize: 12),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // 4. PRICE BREAKDOWN CARD
  // ───────────────────────────────────────────────────────────────────────────
  Widget _buildPriceBreakdownCard(
      Room room, int roomTotal, int taxes, int serviceFee, int totalAmount) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _kBorder, width: 1),
        boxShadow: [
          BoxShadow(
            color: _kText.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Price Breakdown',
            style: GoogleFonts.cormorantGaramond(
              color: _kText,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          _priceRow('${room.name} × $_nights nights', '₹${_formatPrice(roomTotal)}'),
          const SizedBox(height: 8),
          _priceRow('Taxes & Luxury Hospitality Surcharges (18%)', '₹${_formatPrice(taxes)}'),
          const SizedBox(height: 8),
          _priceRow('StayEase Personal Concierge Fee', '₹${_formatPrice(serviceFee)}'),
          const SizedBox(height: 12),
          const Divider(color: _kBorder, height: 1),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Amount',
                style: GoogleFonts.montserrat(
                  color: _kText,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                '₹${_formatPrice(totalAmount)}',
                style: GoogleFonts.cormorantGaramond(
                  color: _kAccent,
                  fontSize: 25,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // INPUT BUILDER HELPER (Crisp, High-contrast, Never Muddy)
  // ───────────────────────────────────────────────────────────────────────────
  Widget _buildLuxuryInput({
    required String label,
    required TextEditingController controller,
    required String placeholder,
    IconData? leadingIcon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.montserrat(
            color: _kTextMuted,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 5),
        Container(
          height: 44,
          decoration: BoxDecoration(
            color: _kBg,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: _kBorder),
          ),
          child: Row(
            children: [
              if (leadingIcon != null) ...[
                const SizedBox(width: 10),
                Icon(leadingIcon, color: _kPrimary, size: 16),
                const SizedBox(width: 8),
              ] else ...[
                const SizedBox(width: 10),
              ],
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: keyboardType,
                  style: GoogleFonts.montserrat(
                    color: _kText,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: InputDecoration(
                    hintText: placeholder,
                    hintStyle: GoogleFonts.montserrat(color: _kTextFaint, fontSize: 12.5),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 8),
            ],
          ),
        ),
      ],
    );
  }

  Widget _priceRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.montserrat(color: _kTextMuted, fontSize: 12),
          ),
        ),
        Text(
          value,
          style: GoogleFonts.montserrat(color: _kText, fontSize: 12.5, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  String _formatPrice(int p) {
    return p.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }
}

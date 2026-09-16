import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

const _kCard = Color(0xFFFFFFFF);
const _kPrimary = Color(0xFF6F8068);
const _kAccent = Color(0xFFC98F65);
const _kText = Color(0xFF252923);
const _kTextMuted = Color(0xFF60675D);
const _kTextFaint = Color(0xFF8F988A);
const _kBorder = Color(0xFFE5E2D8);

String _formatInr(double amount) {
  return NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0)
      .format(amount);
}

// ─── Trip Plan Card ───────────────────────────────────────────────────────────
class TripPlanCard extends StatelessWidget {
  final String title;
  final String destination;
  final DateTime startDate;
  final DateTime endDate;
  final int travellers;
  final double totalBudget;
  final double actualSpent;
  final String? hotelName;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  const TripPlanCard({
    super.key,
    required this.title,
    required this.destination,
    required this.startDate,
    required this.endDate,
    required this.travellers,
    required this.totalBudget,
    required this.actualSpent,
    this.hotelName,
    required this.onTap,
    this.onDelete,
  });

  String _fmtDate(DateTime d) {
    return DateFormat('d MMM').format(d);
  }

  @override
  Widget build(BuildContext context) {
    final spentFraction =
        totalBudget > 0 ? (actualSpent / totalBudget).clamp(0.0, 1.0) : 0.0;
    final nights = endDate.difference(startDate).inDays;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: _kCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _kBorder),
          boxShadow: [
            BoxShadow(
                color: const Color(0xFF252923).withValues(alpha: 0.05),
                blurRadius: 12,
                offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _kPrimary.withValues(alpha: 0.06),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _kPrimary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.flight_takeoff_rounded,
                        color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title,
                            style: GoogleFonts.cormorantGaramond(
                                color: _kText,
                                fontSize: 18,
                                fontWeight: FontWeight.w700)),
                        Text(destination,
                            style: GoogleFonts.montserrat(
                                color: _kTextMuted, fontSize: 12)),
                      ],
                    ),
                  ),
                  if (onDelete != null)
                    GestureDetector(
                      onTap: onDelete,
                      child: const Icon(Icons.delete_outline,
                          color: _kTextFaint, size: 20),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date & Travellers
                  Row(
                    children: [
                      _chip(Icons.calendar_today_outlined,
                          '${_fmtDate(startDate)} – ${_fmtDate(endDate)} · $nights nights'),
                      const SizedBox(width: 12),
                      _chip(Icons.people_outline,
                          '$travellers Traveller${travellers > 1 ? 's' : ''}'),
                    ],
                  ),
                  if (hotelName != null) ...[
                    const SizedBox(height: 10),
                    _chip(Icons.hotel_outlined, hotelName!,
                        color: _kPrimary),
                  ],
                  const SizedBox(height: 14),
                  // Budget
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Budget',
                          style: GoogleFonts.montserrat(
                              color: _kTextFaint, fontSize: 11)),
                      Text(
                          '${_formatInr(actualSpent)} / ${_formatInr(totalBudget)}',
                          style: GoogleFonts.montserrat(
                              color: _kText,
                              fontSize: 12,
                              fontWeight: FontWeight.w700)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: spentFraction,
                      minHeight: 4,
                      backgroundColor: _kBorder,
                      valueColor: AlwaysStoppedAnimation(
                          spentFraction > 0.8 ? _kAccent : _kPrimary),
                    ),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: onTap,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _kPrimary,
                        side: const BorderSide(color: _kPrimary),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      child: Text('Open Trip',
                          style: GoogleFonts.montserrat(
                              fontSize: 13, fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(IconData icon, String text, {Color? color}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: color ?? _kTextFaint),
        const SizedBox(width: 4),
        Text(text,
            style: GoogleFonts.montserrat(
                color: color ?? _kTextMuted, fontSize: 12)),
      ],
    );
  }
}

// ─── Event Plan Card ──────────────────────────────────────────────────────────
class EventPlanCard extends StatelessWidget {
  final String eventName;
  final String eventType;
  final DateTime date;
  final String location;
  final int expectedGuests;
  final double totalBudget;
  final double actualSpent;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  const EventPlanCard({
    super.key,
    required this.eventName,
    required this.eventType,
    required this.date,
    required this.location,
    required this.expectedGuests,
    required this.totalBudget,
    required this.actualSpent,
    required this.onTap,
    this.onDelete,
  });

  int get _daysLeft => date.difference(DateTime.now()).inDays;

  @override
  Widget build(BuildContext context) {
    final spentFraction =
        totalBudget > 0 ? (actualSpent / totalBudget).clamp(0.0, 1.0) : 0.0;
    final days = _daysLeft;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: _kCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _kBorder),
          boxShadow: [
            BoxShadow(
                color: const Color(0xFF252923).withValues(alpha: 0.05),
                blurRadius: 12,
                offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _kAccent.withValues(alpha: 0.07),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _kAccent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.event_rounded,
                        color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(eventName,
                            style: GoogleFonts.cormorantGaramond(
                                color: _kText,
                                fontSize: 18,
                                fontWeight: FontWeight.w700)),
                        Text(eventType,
                            style: GoogleFonts.montserrat(
                                color: _kTextMuted, fontSize: 12)),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: days > 0
                          ? _kPrimary.withValues(alpha: 0.1)
                          : _kAccent.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      days > 0 ? '$days days' : 'Done',
                      style: GoogleFonts.montserrat(
                          color: days > 0 ? _kPrimary : _kAccent,
                          fontSize: 11,
                          fontWeight: FontWeight.w700),
                    ),
                  ),
                  if (onDelete != null) ...[
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: onDelete,
                      child: const Icon(Icons.delete_outline,
                          color: _kTextFaint, size: 20),
                    ),
                  ],
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _chip(Icons.calendar_today_outlined,
                          DateFormat('d MMM yyyy').format(date)),
                      const SizedBox(width: 12),
                      _chip(Icons.people_outline,
                          '$expectedGuests Guests'),
                    ],
                  ),
                  if (location.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    _chip(Icons.place_outlined, location),
                  ],
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Budget',
                          style: GoogleFonts.montserrat(
                              color: _kTextFaint, fontSize: 11)),
                      Text(
                          '${_formatInr(actualSpent)} / ${_formatInr(totalBudget)}',
                          style: GoogleFonts.montserrat(
                              color: _kText,
                              fontSize: 12,
                              fontWeight: FontWeight.w700)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: spentFraction,
                      minHeight: 4,
                      backgroundColor: _kBorder,
                      valueColor: AlwaysStoppedAnimation(
                          spentFraction > 0.8 ? _kAccent : _kPrimary),
                    ),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: onTap,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _kAccent,
                        side: const BorderSide(color: _kAccent),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      child: Text('Open Event',
                          style: GoogleFonts.montserrat(
                              fontSize: 13, fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(IconData icon, String text, {Color? color}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: color ?? _kTextFaint),
        const SizedBox(width: 4),
        Text(text,
            style: GoogleFonts.montserrat(
                color: color ?? _kTextMuted, fontSize: 12)),
      ],
    );
  }
}

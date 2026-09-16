import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../models/plan_model.dart';
import '../../models/budget_model.dart';
import '../../services/firestore_service.dart';
import '../../widgets/plans/budget_progress_bar.dart';
import 'trip_itinerary_screen.dart';
import 'trip_expenses_screen.dart';
import '../hotel_list_screen.dart';

const _kBg = Color(0xFFF7F5EF);
const _kCard = Color(0xFFFFFFFF);
const _kPrimary = Color(0xFF6F8068);
const _kAccent = Color(0xFFC98F65);
const _kText = Color(0xFF252923);
const _kTextMuted = Color(0xFF60675D);
const _kTextFaint = Color(0xFF8F988A);
const _kBorder = Color(0xFFE5E2D8);

class TripDashboardScreen extends StatelessWidget {
  final TripPlan trip;

  const TripDashboardScreen({super.key, required this.trip});

  int get _days => trip.endDate.difference(trip.startDate).inDays + 1;

  String _fmtDate(DateTime d) => DateFormat('d MMM').format(d);

  String _formatInr(double v) => NumberFormat.currency(
          locale: 'en_IN', symbol: '₹', decimalDigits: 0)
      .format(v);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildAppBar(context),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildOverviewCard(),
                  const SizedBox(height: 20),
                  if (trip.budgetId != null) _buildBudgetSection(),
                  const SizedBox(height: 20),
                  _buildQuickActions(context),
                  const SizedBox(height: 20),
                  _buildItineraryPreview(context),
                  const SizedBox(height: 20),
                  _buildAccommodationSection(context),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  SliverAppBar _buildAppBar(BuildContext context) {
    return SliverAppBar(
      backgroundColor: _kPrimary,
      expandedHeight: 160,
      pinned: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_rounded,
            color: Colors.white, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
      systemOverlayStyle: SystemUiOverlayStyle.light,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF4C5847), Color(0xFF6F8068)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 60, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(trip.title,
                      style: GoogleFonts.cormorantGaramond(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text(
                    '${_fmtDate(trip.startDate)} — ${_fmtDate(trip.endDate)} · ${trip.travellers} Travellers',
                    style: GoogleFonts.montserrat(
                        color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
            ),
          ),
        ),
        title: Text(trip.title,
            style: GoogleFonts.montserrat(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700)),
        titlePadding: const EdgeInsets.only(left: 56, bottom: 16),
      ),
    );
  }

  Widget _buildOverviewCard() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _cardTitle('Trip Overview'),
          const SizedBox(height: 16),
          Row(
            children: [
              _overviewItem(Icons.place_outlined, trip.destination),
              _overviewItem(
                  Icons.calendar_today_outlined, '$_days Days'),
              _overviewItem(
                  Icons.people_outline, '${trip.travellers} Travellers'),
            ],
          ),
          if (trip.travelStyle.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: _kPrimary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(trip.travelStyle,
                  style: GoogleFonts.montserrat(
                      color: _kPrimary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600)),
            ),
          ],
          if (trip.interests.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: trip.interests
                  .map((i) => Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: _kAccent.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(i,
                            style: GoogleFonts.montserrat(
                                color: _kAccent,
                                fontSize: 11,
                                fontWeight: FontWeight.w600)),
                      ))
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBudgetSection() {
    return StreamBuilder<BudgetPlan?>(
      stream: FirestoreService.instance.streamBudget(trip.budgetId!),
      builder: (_, snap) {
        final budget = snap.data;
        return _card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _cardTitle('Budget'),
              const SizedBox(height: 16),
              BudgetProgressBar(
                totalBudget: budget?.totalBudget ?? 0,
                actualSpent: budget?.actualSpent ?? 0,
                estimatedCost: budget?.estimatedCost ?? 0,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _cardTitle('Quick Actions'),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _actionChip(
                Icons.add_circle_outline,
                'Add Activity',
                _kPrimary,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => TripItineraryScreen(trip: trip)),
                ),
              ),
              _actionChip(
                Icons.receipt_long_outlined,
                'Add Expense',
                _kAccent,
                () => trip.budgetId != null
                    ? Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => TripExpensesScreen(trip: trip)),
                      )
                    : null,
              ),
              _actionChip(
                Icons.hotel_outlined,
                'Find Hotel',
                const Color(0xFF5D737E),
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => HotelListScreen(
                      city: trip.destination.split(',').first.trim(),
                      dateRange:
                          '${DateFormat('d MMM').format(trip.startDate)} – ${DateFormat('d MMM').format(trip.endDate)}',
                      guestInfo:
                          '${trip.travellers} Traveller${trip.travellers > 1 ? 's' : ''}',
                    ),
                  ),
                ),
              ),
              _actionChip(
                Icons.list_alt_outlined,
                'Full Itinerary',
                const Color(0xFF627357),
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => TripItineraryScreen(trip: trip)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildItineraryPreview(BuildContext context) {
    return StreamBuilder<List<TripItineraryItem>>(
      stream:
          FirestoreService.instance.streamTripItinerary(trip.planId),
      builder: (_, snap) {
        final items = snap.data ?? [];
        final preview = items.take(3).toList();

        return _card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _cardTitle('Itinerary'),
                  TextButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => TripItineraryScreen(trip: trip)),
                    ),
                    child: Text('View All',
                        style: GoogleFonts.montserrat(
                            color: _kPrimary, fontSize: 12)),
                  ),
                ],
              ),
              if (snap.connectionState == ConnectionState.waiting)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Center(
                      child: CircularProgressIndicator(
                          color: _kPrimary, strokeWidth: 2)),
                )
              else if (preview.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text('No activities planned yet.',
                      style: GoogleFonts.montserrat(
                          color: _kTextFaint, fontSize: 13)),
                )
              else
                ...preview.map((item) => _itineraryRow(item)),
            ],
          ),
        );
      },
    );
  }

  Widget _itineraryRow(TripItineraryItem item) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 40,
            decoration: BoxDecoration(
              color: item.completed ? _kPrimary : _kBorder,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title,
                    style: GoogleFonts.montserrat(
                        color: item.completed ? _kTextFaint : _kText,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        decoration: item.completed
                            ? TextDecoration.lineThrough
                            : null)),
                Text('${item.time} · ${item.category}',
                    style: GoogleFonts.montserrat(
                        color: _kTextFaint, fontSize: 11)),
              ],
            ),
          ),
          if (item.estimatedCost > 0)
            Text(_formatInr(item.estimatedCost),
                style: GoogleFonts.montserrat(
                    color: _kTextMuted,
                    fontSize: 12,
                    fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildAccommodationSection(BuildContext context) {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _cardTitle('Accommodation'),
          const SizedBox(height: 12),
          if (trip.hotelBookingId != null) ...[
            Row(
              children: [
                const Icon(Icons.check_circle_rounded,
                    color: _kPrimary, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text('Hotel booking attached',
                      style: GoogleFonts.montserrat(
                          color: _kText,
                          fontSize: 13,
                          fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ] else ...[
            Text('No accommodation added yet.',
                style: GoogleFonts.montserrat(
                    color: _kTextFaint, fontSize: 13)),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => HotelListScreen(
                    city: trip.destination.split(',').first.trim(),
                    dateRange:
                        '${DateFormat('d MMM').format(trip.startDate)} – ${DateFormat('d MMM').format(trip.endDate)}',
                    guestInfo:
                        '${trip.travellers} Traveller${trip.travellers > 1 ? 's' : ''}',
                  ),
                ),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: _kPrimary,
                side: const BorderSide(color: _kPrimary),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              icon: const Icon(Icons.search_rounded, size: 18),
              label: Text('Find a Hotel',
                  style: GoogleFonts.montserrat(
                      fontSize: 13, fontWeight: FontWeight.w700)),
            ),
          ],
        ],
      ),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _kBorder),
        boxShadow: [
          BoxShadow(
              color: const Color(0xFF252923).withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 3)),
        ],
      ),
      child: child,
    );
  }

  Widget _cardTitle(String t) => Text(t,
      style: GoogleFonts.montserrat(
          color: _kText, fontSize: 14, fontWeight: FontWeight.w700));

  Widget _overviewItem(IconData icon, String text) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: _kPrimary, size: 22),
          const SizedBox(height: 4),
          Text(text,
              style: GoogleFonts.montserrat(
                  color: _kTextMuted, fontSize: 11),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  Widget _actionChip(
      IconData icon, String label, Color color, VoidCallback? onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 6),
            Text(label,
                style: GoogleFonts.montserrat(
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}

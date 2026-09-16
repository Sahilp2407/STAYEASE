import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../models/plan_model.dart';
import '../../models/budget_model.dart';
import '../../services/firestore_service.dart';
import '../../widgets/plans/budget_progress_bar.dart';
import 'event_tasks_screen.dart';
import 'event_guests_screen.dart';
import 'event_vendors_screen.dart';
import 'event_expenses_screen.dart';

const _kBg = Color(0xFFF7F5EF);
const _kCard = Color(0xFFFFFFFF);
const _kPrimary = Color(0xFF6F8068);
const _kAccent = Color(0xFFC98F65);
const _kText = Color(0xFF252923);
const _kTextMuted = Color(0xFF60675D);
const _kTextFaint = Color(0xFF8F988A);
const _kBorder = Color(0xFFE5E2D8);

class EventDashboardScreen extends StatelessWidget {
  final EventPlan event;

  const EventDashboardScreen({super.key, required this.event});

  int get _daysLeft => event.date.difference(DateTime.now()).inDays;
  String _formatInr(double v) =>
      NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0)
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
                  _buildCountdownCard(),
                  const SizedBox(height: 16),
                  if (event.budgetId != null) _buildBudgetSection(),
                  const SizedBox(height: 16),
                  _buildQuickActions(context),
                  const SizedBox(height: 16),
                  _buildTaskProgress(),
                  const SizedBox(height: 16),
                  _buildGuestSummary(),
                  const SizedBox(height: 16),
                  _buildVendorSummary(),
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
      backgroundColor: _kAccent,
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
              colors: [Color(0xFF8B5E3C), Color(0xFFC98F65)],
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
                  Text(event.eventName,
                      style: GoogleFonts.cormorantGaramond(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text(
                    '${event.eventType} · ${DateFormat('d MMM yyyy').format(event.date)}',
                    style: GoogleFonts.montserrat(
                        color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
            ),
          ),
        ),
        title: Text(event.eventName,
            style: GoogleFonts.montserrat(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700)),
        titlePadding: const EdgeInsets.only(left: 56, bottom: 16),
      ),
    );
  }

  Widget _buildCountdownCard() {
    final days = _daysLeft;
    return _card(
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  days > 0 ? '$days Days to Go' : 'Event Completed',
                  style: GoogleFonts.cormorantGaramond(
                      color: days > 0 ? _kAccent : _kPrimary,
                      fontSize: 24,
                      fontWeight: FontWeight.w700),
                ),
                Text(
                  DateFormat('EEEE, d MMMM yyyy').format(event.date),
                  style: GoogleFonts.montserrat(
                      color: _kTextMuted, fontSize: 13),
                ),
                if (event.time.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(event.time,
                      style: GoogleFonts.montserrat(
                          color: _kTextFaint, fontSize: 12)),
                ],
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _kAccent.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              days > 0 ? Icons.hourglass_empty_rounded : Icons.celebration_rounded,
              color: _kAccent,
              size: 28,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetSection() {
    return StreamBuilder<BudgetPlan?>(
      stream: FirestoreService.instance.streamBudget(event.budgetId!),
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
              _actionChip(Icons.task_alt_rounded, 'Tasks', _kPrimary, () =>
                  Navigator.push(context, MaterialPageRoute(
                      builder: (_) => EventTasksScreen(event: event)))),
              _actionChip(Icons.people_outline, 'Guests', _kAccent, () =>
                  Navigator.push(context, MaterialPageRoute(
                      builder: (_) => EventGuestsScreen(event: event)))),
              _actionChip(Icons.storefront_outlined, 'Vendors',
                  const Color(0xFF5D737E), () => Navigator.push(context,
                      MaterialPageRoute(
                          builder: (_) => EventVendorsScreen(event: event)))),
              _actionChip(Icons.receipt_long_outlined, 'Expenses',
                  const Color(0xFF627357), () => event.budgetId != null
                      ? Navigator.push(context, MaterialPageRoute(
                          builder: (_) => EventExpensesScreen(event: event)))
                      : null),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTaskProgress() {
    return StreamBuilder<List<PlanTask>>(
      stream: FirestoreService.instance.streamTasks(event.planId),
      builder: (context, snap) {
        final tasks = snap.data ?? [];
        final completed = tasks.where((t) => t.completed).length;
        final total = tasks.length;
        final fraction = total > 0 ? completed / total : 0.0;

        return _card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _cardTitle('Tasks'),
                  TextButton(
                    onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => EventTasksScreen(event: event))),
                    child: Text('Manage',
                        style: GoogleFonts.montserrat(
                            color: _kPrimary, fontSize: 12)),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                total == 0
                    ? 'No tasks yet'
                    : '$completed of $total completed · ${(fraction * 100).toStringAsFixed(0)}%',
                style: GoogleFonts.montserrat(
                    color: _kTextMuted, fontSize: 13),
              ),
              if (total > 0) ...[
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: fraction),
                    duration: const Duration(milliseconds: 700),
                    builder: (_, v, __) => LinearProgressIndicator(
                      value: v,
                      minHeight: 6,
                      backgroundColor: _kBorder,
                      valueColor: AlwaysStoppedAnimation(
                          fraction >= 1.0 ? _kPrimary : _kAccent),
                    ),
                  ),
                ),
                if (total - completed > 0) ...[
                  const SizedBox(height: 8),
                  Text('${total - completed} task${total - completed > 1 ? 's' : ''} still need your attention.',
                      style: GoogleFonts.montserrat(
                          color: _kAccent, fontSize: 11)),
                ],
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildGuestSummary() {
    return StreamBuilder<List<PlanGuest>>(
      stream: FirestoreService.instance.streamGuests(event.planId),
      builder: (context, snap) {
        final guests = snap.data ?? [];
        final confirmed = guests.where((g) => g.rsvpStatus == 'Confirmed').length;
        final pending = guests.where((g) => g.rsvpStatus == 'Pending').length;
        final declined = guests.where((g) => g.rsvpStatus == 'Declined').length;

        return _card(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _cardTitle('Guests'),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _guestStat('Total', '${guests.length}', _kText),
                        const SizedBox(width: 16),
                        _guestStat('Confirmed', '$confirmed', _kPrimary),
                        const SizedBox(width: 16),
                        _guestStat('Pending', '$pending', _kAccent),
                        const SizedBox(width: 16),
                        _guestStat('Declined', '$declined', Colors.red),
                      ],
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => EventGuestsScreen(event: event))),
                child: Text('Manage',
                    style: GoogleFonts.montserrat(
                        color: _kPrimary, fontSize: 12)),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _guestStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(value,
            style: GoogleFonts.montserrat(
                color: color, fontSize: 16, fontWeight: FontWeight.w700)),
        Text(label,
            style: GoogleFonts.montserrat(
                color: _kTextFaint, fontSize: 10)),
      ],
    );
  }

  Widget _buildVendorSummary() {
    return StreamBuilder<List<PlanVendor>>(
      stream: FirestoreService.instance.streamVendors(event.planId),
      builder: (context, snap) {
        final vendors = snap.data ?? [];
        final confirmed = vendors.where((v) => v.status == 'Confirmed').length;
        final totalEst =
            vendors.fold<double>(0, (s, v) => s + v.estimatedCost);

        return _card(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _cardTitle('Vendors'),
                    const SizedBox(height: 8),
                    Text(
                      vendors.isEmpty
                          ? 'No vendors added'
                          : '${vendors.length} vendors · $confirmed confirmed · Est. ${_formatInr(totalEst)}',
                      style: GoogleFonts.montserrat(
                          color: _kTextMuted, fontSize: 12),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => EventVendorsScreen(event: event))),
                child: Text('Manage',
                    style: GoogleFonts.montserrat(
                        color: _kPrimary, fontSize: 12)),
              ),
            ],
          ),
        );
      },
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

  Widget _actionChip(
      IconData icon, String label, Color color, VoidCallback? onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
                    color: color, fontSize: 12, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}

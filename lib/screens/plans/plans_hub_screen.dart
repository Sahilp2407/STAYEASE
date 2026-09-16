import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/plan_model.dart';
import '../../models/budget_model.dart';
import '../../services/firestore_service.dart';
import '../../widgets/plans/plan_card.dart';
import '../../widgets/plans/empty_plan_state.dart';
import 'trip_creation_screen.dart';
import 'trip_dashboard_screen.dart';
import 'event_creation_screen.dart';
import 'event_dashboard_screen.dart';
import '../auth_screen.dart';

const _kBg = Color(0xFFF7F5EF);
const _kCard = Color(0xFFFFFFFF);
const _kPrimary = Color(0xFF6F8068);
const _kAccent = Color(0xFFC98F65);
const _kText = Color(0xFF252923);
const _kTextMuted = Color(0xFF60675D);
const _kTextFaint = Color(0xFF8F988A);
const _kBorder = Color(0xFFE5E2D8);

class PlansHubScreen extends StatefulWidget {
  const PlansHubScreen({super.key});

  @override
  State<PlansHubScreen> createState() => _PlansHubScreenState();
}

class _PlansHubScreenState extends State<PlansHubScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  User? get _user => FirebaseAuth.instance.currentUser;

  void _pushTrip(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const TripCreationScreen()),
    );
  }

  void _pushEvent(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const EventCreationScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_user == null) {
      return Scaffold(
        backgroundColor: _kBg,
        body: EmptyPlanState(
          icon: Icons.lock_outline,
          title: 'Sign in to manage your plans',
          subtitle:
              'Create and track your trips and events with your StayEase account.',
          primaryLabel: 'Sign In',
          onPrimary: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AuthScreen()),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: _kBg,
      body: NestedScrollView(
        headerSliverBuilder: (_, __) => [
          SliverToBoxAdapter(child: _buildHeader()),
          SliverToBoxAdapter(child: _buildTabBar()),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            _TripsTab(
              uid: _user!.uid,
              onCreate: () => _pushTrip(context),
            ),
            _EventsTab(
              uid: _user!.uid,
              onCreate: () => _pushEvent(context),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateSheet(context),
        backgroundColor: _kPrimary,
        foregroundColor: Colors.white,
        elevation: 4,
        icon: const Icon(Icons.add),
        label: Text('Create Plan',
            style: GoogleFonts.montserrat(
                fontWeight: FontWeight.w700, fontSize: 13)),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      color: _kBg,
      padding: EdgeInsets.fromLTRB(
          20, MediaQuery.of(context).padding.top + 20, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'My Plans',
            style: GoogleFonts.cormorantGaramond(
              color: _kText,
              fontSize: 32,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Organise your stays, trips and events in one place.',
            style:
                GoogleFonts.montserrat(color: _kTextMuted, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: _kBg,
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
      child: Container(
        decoration: BoxDecoration(
          color: _kCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _kBorder),
        ),
        child: TabBar(
          controller: _tabController,
          labelColor: _kPrimary,
          unselectedLabelColor: _kTextFaint,
          indicator: BoxDecoration(
            color: _kPrimary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          labelStyle: GoogleFonts.montserrat(
              fontWeight: FontWeight.w700, fontSize: 13),
          unselectedLabelStyle:
              GoogleFonts.montserrat(fontWeight: FontWeight.w500, fontSize: 13),
          tabs: const [
            Tab(text: 'Trip Plans'),
            Tab(text: 'Event Plans'),
          ],
        ),
      ),
    );
  }

  void _showCreateSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: _kCard,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: _kBorder, borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 20),
            Text('What would you like to plan?',
                style: GoogleFonts.cormorantGaramond(
                    color: _kText,
                    fontSize: 22,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 24),
            _createOption(
              icon: Icons.flight_takeoff_rounded,
              color: _kPrimary,
              title: 'Trip Plan',
              subtitle: 'Hotels, itinerary, budget & activities',
              onTap: () {
                Navigator.pop(context);
                _pushTrip(context);
              },
            ),
            const SizedBox(height: 12),
            _createOption(
              icon: Icons.event_rounded,
              color: _kAccent,
              title: 'Event Plan',
              subtitle: 'Wedding, conference, party & more',
              onTap: () {
                Navigator.pop(context);
                _pushEvent(context);
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _createOption({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration:
                  BoxDecoration(color: color, borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: Colors.white, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: GoogleFonts.montserrat(
                          color: _kText,
                          fontSize: 14,
                          fontWeight: FontWeight.w700)),
                  Text(subtitle,
                      style: GoogleFonts.montserrat(
                          color: _kTextMuted, fontSize: 12)),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, color: color, size: 16),
          ],
        ),
      ),
    );
  }
}

// ─── Trips Tab ────────────────────────────────────────────────────────────────
class _TripsTab extends StatelessWidget {
  final String uid;
  final VoidCallback onCreate;

  const _TripsTab({required this.uid, required this.onCreate});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<TripPlan>>(
      stream: FirestoreService.instance.streamUserTrips(uid),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: _kPrimary));
        }
        if (snap.hasError) {
          return Center(
              child: Text('Something went wrong. Please try again.',
                  style: GoogleFonts.montserrat(color: _kTextMuted)));
        }
        final trips = snap.data ?? [];
        if (trips.isEmpty) {
          return EmptyPlanState(
            icon: Icons.flight_takeoff_rounded,
            title: 'No trips planned yet',
            subtitle: 'Start planning your next adventure.',
            primaryLabel: 'Create Trip',
            onPrimary: onCreate,
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
          itemCount: trips.length,
          itemBuilder: (_, i) => _TripCardLoader(
            trip: trips[i],
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => TripDashboardScreen(trip: trips[i])),
            ),
            onDelete: () async {
              final confirmed = await _confirmDelete(context, 'trip');
              if (confirmed) {
                await FirestoreService.instance.deletePlan(trips[i].planId);
                if (trips[i].budgetId != null) {
                  // Budget deletion best-effort
                }
              }
            },
          ),
        );
      },
    );
  }
}

class _TripCardLoader extends StatelessWidget {
  final TripPlan trip;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _TripCardLoader(
      {required this.trip, required this.onTap, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    if (trip.budgetId == null) {
      return TripPlanCard(
        title: trip.title,
        destination: trip.destination,
        startDate: trip.startDate,
        endDate: trip.endDate,
        travellers: trip.travellers,
        totalBudget: 0,
        actualSpent: 0,
        onTap: onTap,
        onDelete: onDelete,
      );
    }
    return StreamBuilder<BudgetPlan?>(
      stream: FirestoreService.instance.streamBudget(trip.budgetId!),
      builder: (_, bs) {
        final budget = bs.data;
        return TripPlanCard(
          title: trip.title,
          destination: trip.destination,
          startDate: trip.startDate,
          endDate: trip.endDate,
          travellers: trip.travellers,
          totalBudget: budget?.totalBudget ?? 0,
          actualSpent: budget?.actualSpent ?? 0,
          onTap: onTap,
          onDelete: onDelete,
        );
      },
    );
  }
}

// ─── Events Tab ───────────────────────────────────────────────────────────────
class _EventsTab extends StatelessWidget {
  final String uid;
  final VoidCallback onCreate;

  const _EventsTab({required this.uid, required this.onCreate});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<EventPlan>>(
      stream: FirestoreService.instance.streamUserEvents(uid),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: _kPrimary));
        }
        if (snap.hasError) {
          return Center(
              child: Text('Something went wrong. Please try again.',
                  style: GoogleFonts.montserrat(color: _kTextMuted)));
        }
        final events = snap.data ?? [];
        if (events.isEmpty) {
          return EmptyPlanState(
            icon: Icons.event_rounded,
            title: 'No events planned yet',
            subtitle: 'Plan your next wedding, party or conference.',
            primaryLabel: 'Create Event',
            onPrimary: onCreate,
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
          itemCount: events.length,
          itemBuilder: (_, i) => _EventCardLoader(
            event: events[i],
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => EventDashboardScreen(event: events[i])),
            ),
            onDelete: () async {
              final confirmed = await _confirmDelete(context, 'event');
              if (confirmed) {
                await FirestoreService.instance.deletePlan(events[i].planId);
              }
            },
          ),
        );
      },
    );
  }
}

class _EventCardLoader extends StatelessWidget {
  final EventPlan event;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _EventCardLoader(
      {required this.event, required this.onTap, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    if (event.budgetId == null) {
      return EventPlanCard(
        eventName: event.eventName,
        eventType: event.eventType,
        date: event.date,
        location: event.location,
        expectedGuests: event.expectedGuests,
        totalBudget: 0,
        actualSpent: 0,
        onTap: onTap,
        onDelete: onDelete,
      );
    }
    return StreamBuilder<BudgetPlan?>(
      stream: FirestoreService.instance.streamBudget(event.budgetId!),
      builder: (_, bs) {
        final budget = bs.data;
        return EventPlanCard(
          eventName: event.eventName,
          eventType: event.eventType,
          date: event.date,
          location: event.location,
          expectedGuests: event.expectedGuests,
          totalBudget: budget?.totalBudget ?? 0,
          actualSpent: budget?.actualSpent ?? 0,
          onTap: onTap,
          onDelete: onDelete,
        );
      },
    );
  }
}

Future<bool> _confirmDelete(BuildContext context, String type) async {
  return await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: const Color(0xFFFFFFFF),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('Delete $type?',
              style: GoogleFonts.montserrat(fontWeight: FontWeight.w700)),
          content: Text(
              'This will permanently delete this $type and all its data.',
              style: GoogleFonts.montserrat(fontSize: 13)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('Cancel',
                  style: GoogleFonts.montserrat(
                      color: const Color(0xFF6F8068))),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text('Delete',
                  style: GoogleFonts.montserrat(
                      color: Colors.red, fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ) ??
      false;
}

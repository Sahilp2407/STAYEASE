import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/plan_model.dart';
import '../../models/budget_model.dart';
import '../../services/firestore_service.dart';
import 'event_dashboard_screen.dart';

const _kBg = Color(0xFFF7F5EF);
const _kCard = Color(0xFFFFFFFF);
const _kPrimary = Color(0xFF6F8068);
const _kAccent = Color(0xFFC98F65);
const _kText = Color(0xFF252923);
const _kTextMuted = Color(0xFF60675D);
const _kTextFaint = Color(0xFF8F988A);
const _kBorder = Color(0xFFE5E2D8);

const _eventTypes = [
  'Wedding', 'Birthday', 'Conference', 'College Event',
  'Party', 'Corporate', 'Other'
];

class EventCreationScreen extends StatefulWidget {
  const EventCreationScreen({super.key});

  @override
  State<EventCreationScreen> createState() => _EventCreationScreenState();
}

class _EventCreationScreenState extends State<EventCreationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _venueCtrl = TextEditingController();
  final _organizerCtrl = TextEditingController();
  final _contactCtrl = TextEditingController();
  final _budgetCtrl = TextEditingController();
  final _guestsCtrl = TextEditingController(text: '50');
  final _notesCtrl = TextEditingController();
  final _timeCtrl = TextEditingController();

  String _eventType = 'Wedding';
  DateTime? _date;
  bool _loading = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _venueCtrl.dispose();
    _organizerCtrl.dispose();
    _contactCtrl.dispose();
    _budgetCtrl.dispose();
    _guestsCtrl.dispose();
    _notesCtrl.dispose();
    _timeCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date ?? DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 730)),
      builder: (ctx, child) => Theme(
        data: ThemeData.light().copyWith(
          colorScheme: const ColorScheme.light(
              primary: _kAccent, onPrimary: Colors.white, surface: _kCard),
        ),
        child: child!,
      ),
    );
    if (picked != null && mounted) setState(() => _date = picked);
  }

  String _fmtDate(DateTime d) {
    const months = ['Jan','Feb','Mar','Apr','May','Jun',
        'Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }

  Future<void> _createEvent() async {
    if (!_formKey.currentState!.validate()) return;
    if (_date == null) {
      _showSnack('Please select an event date');
      return;
    }
    final guests = int.tryParse(_guestsCtrl.text.trim()) ?? 0;
    if (guests < 0) {
      _showSnack('Guests cannot be negative');
      return;
    }

    setState(() => _loading = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      final uid = user?.uid ?? 'guest_user';
      final planId = FirebaseFirestore.instance.collection('plans').doc().id;
      final budgetId = FirebaseFirestore.instance.collection('budgets').doc().id;
      final now = DateTime.now();
      final budget = double.tryParse(_budgetCtrl.text.trim()) ?? 0;

      final event = EventPlan(
        planId: planId,
        userId: uid,
        eventName: _nameCtrl.text.trim(),
        eventType: _eventType,
        date: _date!,
        time: _timeCtrl.text.trim(),
        location: _venueCtrl.text.trim(),
        expectedGuests: guests,
        budgetId: budgetId,
        notes: _notesCtrl.text.trim(),
        createdAt: now,
        updatedAt: now,
      );

      final budgetPlan = BudgetPlan(
        budgetId: budgetId,
        userId: uid,
        planId: planId,
        title: '${_nameCtrl.text.trim()} Budget',
        totalBudget: budget,
        remainingAmount: budget,
        createdAt: now,
        updatedAt: now,
      );

      try {
        await FirestoreService.instance
            .createEventPlan(event)
            .timeout(const Duration(seconds: 3));
      } catch (e) {
        debugPrint('createEventPlan sync note: $e');
      }

      try {
        await FirestoreService.instance
            .createBudgetPlan(budgetPlan)
            .timeout(const Duration(seconds: 3));
      } catch (e) {
        debugPrint('createBudgetPlan sync note: $e');
      }

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (_) => EventDashboardScreen(event: event)),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        _showSnack('Note: $e');
      }
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: GoogleFonts.montserrat(color: _kBg)),
      backgroundColor: _kText,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      appBar: AppBar(
        backgroundColor: _kBg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: _kText, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Plan an Event',
            style: GoogleFonts.cormorantGaramond(
                color: _kText, fontSize: 22, fontWeight: FontWeight.w700)),
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _section('Event Details'),
            _field(_nameCtrl, 'Event Name', hint: 'e.g. College Fest 2026',
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Event name required' : null),
            const SizedBox(height: 14),
            _dropdownField(),
            const SizedBox(height: 20),
            _section('Date & Time'),
            Row(children: [
              Expanded(child: _dateTile()),
              const SizedBox(width: 12),
              Expanded(
                child: _field(_timeCtrl, 'Time', hint: 'e.g. 5:00 PM'),
              ),
            ]),
            const SizedBox(height: 20),
            _section('Venue & Organiser'),
            _field(_venueCtrl, 'Venue / Location', hint: 'e.g. Grand Ballroom, Mumbai',
                prefixIcon: Icons.place_outlined),
            const SizedBox(height: 14),
            _field(_organizerCtrl, 'Organizer Name', hint: 'Your name or company'),
            const SizedBox(height: 14),
            _field(_contactCtrl, 'Contact Number',
                keyboardType: TextInputType.phone,
                prefixIcon: Icons.phone_outlined),
            const SizedBox(height: 20),
            _section('Guests & Budget'),
            _field(_guestsCtrl, 'Expected Guests',
                keyboardType: TextInputType.number,
                prefixIcon: Icons.people_outline,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return null;
                  final n = int.tryParse(v.trim());
                  if (n == null || n < 0) return 'Invalid number';
                  return null;
                }),
            const SizedBox(height: 14),
            _field(_budgetCtrl, 'Event Budget (₹)',
                keyboardType: TextInputType.number,
                prefixIcon: Icons.currency_rupee_rounded,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return null;
                  final n = double.tryParse(v.trim());
                  if (n == null || n < 0) return 'Invalid budget';
                  return null;
                }),
            const SizedBox(height: 20),
            _section('Notes'),
            _field(_notesCtrl, 'Additional Notes', maxLines: 3),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _loading ? null : _createEvent,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _kAccent,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: _loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text('Create Event',
                        style: GoogleFonts.montserrat(
                            fontSize: 15, fontWeight: FontWeight.w700)),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _section(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(title,
          style: GoogleFonts.montserrat(
              color: _kText, fontSize: 14, fontWeight: FontWeight.w700)),
    );
  }

  Widget _dateTile() {
    return GestureDetector(
      onTap: _pickDate,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: _kCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _kBorder),
        ),
        child: Row(children: [
          const Icon(Icons.calendar_today_outlined,
              color: _kTextFaint, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Event Date',
                    style: GoogleFonts.montserrat(
                        color: _kTextFaint, fontSize: 10)),
                Text(
                  _date != null ? _fmtDate(_date!) : 'Select Date',
                  style: GoogleFonts.montserrat(
                      color: _kText,
                      fontSize: 13,
                      fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ]),
      ),
    );
  }

  Widget _dropdownField() {
    return DropdownButtonFormField<String>(
      value: _eventType,
      decoration: _dec('Event Type'),
      style: GoogleFonts.montserrat(color: _kText, fontSize: 14),
      dropdownColor: _kCard,
      items: _eventTypes
          .map((t) => DropdownMenuItem(value: t, child: Text(t)))
          .toList(),
      onChanged: (v) => setState(() => _eventType = v!),
    );
  }

  Widget _field(
    TextEditingController ctrl,
    String label, {
    String? hint,
    TextInputType? keyboardType,
    IconData? prefixIcon,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: ctrl,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: GoogleFonts.montserrat(color: _kText, fontSize: 14),
      validator: validator,
      decoration: _dec(label, hint: hint, prefixIcon: prefixIcon),
    );
  }

  InputDecoration _dec(String label,
      {String? hint, IconData? prefixIcon}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: GoogleFonts.montserrat(color: _kTextFaint, fontSize: 13),
      hintStyle: GoogleFonts.montserrat(color: _kTextFaint, fontSize: 13),
      prefixIcon: prefixIcon != null
          ? Icon(prefixIcon, color: _kTextFaint, size: 20)
          : null,
      filled: true,
      fillColor: _kCard,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _kBorder)),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _kBorder)),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _kAccent, width: 1.5)),
      errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red)),
    );
  }
}

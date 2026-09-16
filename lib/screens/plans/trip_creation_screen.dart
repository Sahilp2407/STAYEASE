import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/plan_model.dart';
import '../../models/budget_model.dart';
import '../../services/firestore_service.dart';
import 'trip_dashboard_screen.dart';

const _kBg = Color(0xFFF7F5EF);
const _kCard = Color(0xFFFFFFFF);
const _kPrimary = Color(0xFF6F8068);
const _kAccent = Color(0xFFC98F65);
const _kText = Color(0xFF252923);
const _kTextMuted = Color(0xFF60675D);
const _kTextFaint = Color(0xFF8F988A);
const _kBorder = Color(0xFFE5E2D8);

class TripCreationScreen extends StatefulWidget {
  const TripCreationScreen({super.key});

  @override
  State<TripCreationScreen> createState() => _TripCreationScreenState();
}

class _TripCreationScreenState extends State<TripCreationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _destCtrl = TextEditingController();
  final _budgetCtrl = TextEditingController();

  DateTime? _startDate;
  DateTime? _endDate;
  int _travellers = 2;
  String _travelStyle = 'Balanced';
  final Set<String> _interests = {};
  bool _loading = false;

  static const _styles = ['Budget', 'Balanced', 'Premium'];
  static const _interestOptions = [
    'Food', 'Nature', 'Shopping', 'Culture',
    'Adventure', 'Nightlife', 'History', 'Photography',
  ];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _destCtrl.dispose();
    _budgetCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate(bool isStart) async {
    final now = DateTime.now();
    final initial = isStart
        ? (_startDate ?? now.add(const Duration(days: 1)))
        : (_endDate ?? (_startDate ?? now).add(const Duration(days: 2)));
    final first = isStart ? now : (_startDate ?? now);
    final last = now.add(const Duration(days: 730));

    final picked = await showDatePicker(
      context: context,
      initialDate: initial.isAfter(first) ? initial : first,
      firstDate: first,
      lastDate: last,
      builder: (ctx, child) => Theme(
        data: ThemeData.light().copyWith(
          colorScheme: const ColorScheme.light(
              primary: _kPrimary, onPrimary: Colors.white, surface: _kCard),
          dialogTheme: const DialogThemeData(backgroundColor: _kBg),
        ),
        child: child!,
      ),
    );
    if (picked != null && mounted) {
      setState(() {
        if (isStart) {
          _startDate = picked;
          if (_endDate != null && _endDate!.isBefore(picked)) {
            _endDate = picked.add(const Duration(days: 1));
          }
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _createTrip() async {
    if (!_formKey.currentState!.validate()) return;
    if (_startDate == null) {
      _showSnack('Please select a start date');
      return;
    }
    if (_endDate == null) {
      _showSnack('Please select an end date');
      return;
    }

    setState(() => _loading = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      final uid = user?.uid ?? 'guest_user';
      final planId = FirebaseFirestore.instance.collection('plans').doc().id;
      final budgetId =
          FirebaseFirestore.instance.collection('budgets').doc().id;
      final now = DateTime.now();
      final budget = double.tryParse(_budgetCtrl.text.trim()) ?? 0;

      final trip = TripPlan(
        planId: planId,
        userId: uid,
        title: _nameCtrl.text.trim(),
        destination: _destCtrl.text.trim(),
        startDate: _startDate!,
        endDate: _endDate!,
        travellers: _travellers,
        travelStyle: _travelStyle,
        interests: _interests.toList(),
        budgetId: budgetId,
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
            .createTripPlan(trip)
            .timeout(const Duration(seconds: 3));
      } catch (e) {
        debugPrint('createTripPlan sync note: $e');
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
          MaterialPageRoute(builder: (_) => TripDashboardScreen(trip: trip)),
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: GoogleFonts.montserrat(color: _kBg)),
        backgroundColor: _kText,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  String _fmtDate(DateTime d) {
    const months = ['Jan','Feb','Mar','Apr','May','Jun',
        'Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
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
        title: Text('Plan a New Trip',
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
            _sectionTitle('Trip Details'),
            _inputField(
              controller: _nameCtrl,
              label: 'Trip Name',
              hint: 'e.g. Mumbai Weekend',
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Trip name is required' : null,
            ),
            const SizedBox(height: 16),
            _inputField(
              controller: _destCtrl,
              label: 'Destination',
              hint: 'e.g. Mumbai, Maharashtra',
              prefixIcon: Icons.place_outlined,
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Destination is required' : null,
            ),
            const SizedBox(height: 20),
            _sectionTitle('Dates'),
            Row(
              children: [
                Expanded(
                    child: _datePicker(
                  label: 'Start Date',
                  value: _startDate != null ? _fmtDate(_startDate!) : 'Select',
                  onTap: () => _pickDate(true),
                )),
                const SizedBox(width: 12),
                Expanded(
                    child: _datePicker(
                  label: 'End Date',
                  value: _endDate != null ? _fmtDate(_endDate!) : 'Select',
                  onTap: () => _pickDate(false),
                )),
              ],
            ),
            const SizedBox(height: 20),
            _sectionTitle('Travellers'),
            _counterRow(
              label: 'Number of Travellers',
              value: _travellers,
              min: 1,
              max: 20,
              onChanged: (v) => setState(() => _travellers = v),
            ),
            const SizedBox(height: 20),
            _sectionTitle('Travel Style'),
            Wrap(
              spacing: 10,
              children: _styles.map((s) {
                final selected = s == _travelStyle;
                return GestureDetector(
                  onTap: () => setState(() => _travelStyle = s),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 10),
                    decoration: BoxDecoration(
                      color: selected ? _kPrimary : _kCard,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                          color: selected ? _kPrimary : _kBorder),
                    ),
                    child: Text(s,
                        style: GoogleFonts.montserrat(
                            color: selected ? Colors.white : _kTextMuted,
                            fontSize: 13,
                            fontWeight: FontWeight.w600)),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            _sectionTitle('Interests'),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _interestOptions.map((interest) {
                final selected = _interests.contains(interest);
                return GestureDetector(
                  onTap: () => setState(() {
                    if (selected) {
                      _interests.remove(interest);
                    } else {
                      _interests.add(interest);
                    }
                  }),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: selected
                          ? _kPrimary.withValues(alpha: 0.1)
                          : _kCard,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: selected ? _kPrimary : _kBorder),
                    ),
                    child: Text(interest,
                        style: GoogleFonts.montserrat(
                            color: selected ? _kPrimary : _kTextMuted,
                            fontSize: 12,
                            fontWeight: FontWeight.w600)),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            _sectionTitle('Trip Budget'),
            _inputField(
              controller: _budgetCtrl,
              label: 'Total Budget (₹)',
              hint: 'e.g. 30000',
              keyboardType: TextInputType.number,
              prefixIcon: Icons.currency_rupee_rounded,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return null;
                final n = double.tryParse(v.trim());
                if (n == null || n < 0) return 'Enter a valid budget amount';
                return null;
              },
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _loading ? null : _createTrip,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _kPrimary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: _loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text('Create Trip',
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

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(title,
          style: GoogleFonts.montserrat(
              color: _kText, fontSize: 14, fontWeight: FontWeight.w700)),
    );
  }

  Widget _inputField({
    required TextEditingController controller,
    required String label,
    String? hint,
    IconData? prefixIcon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: GoogleFonts.montserrat(color: _kText, fontSize: 14),
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: GoogleFonts.montserrat(color: _kTextFaint, fontSize: 13),
        hintStyle: GoogleFonts.montserrat(color: _kTextFaint, fontSize: 13),
        prefixIcon:
            prefixIcon != null ? Icon(prefixIcon, color: _kTextFaint, size: 20) : null,
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
            borderSide: const BorderSide(color: _kPrimary, width: 1.5)),
        errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red)),
      ),
    );
  }

  Widget _datePicker({
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: _kCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _kBorder),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today_outlined,
                color: _kTextFaint, size: 16),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: GoogleFonts.montserrat(
                          color: _kTextFaint, fontSize: 10)),
                  Text(value,
                      style: GoogleFonts.montserrat(
                          color: _kText,
                          fontSize: 13,
                          fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _counterRow({
    required String label,
    required int value,
    required int min,
    required int max,
    required ValueChanged<int> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _kBorder),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: GoogleFonts.montserrat(color: _kText, fontSize: 14)),
          Row(
            children: [
              _counterBtn(Icons.remove, () {
                if (value > min) onChanged(value - 1);
              }),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text('$value',
                    style: GoogleFonts.montserrat(
                        color: _kText,
                        fontSize: 16,
                        fontWeight: FontWeight.w700)),
              ),
              _counterBtn(Icons.add, () {
                if (value < max) onChanged(value + 1);
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _counterBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: _kPrimary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: _kPrimary, size: 18),
      ),
    );
  }
}

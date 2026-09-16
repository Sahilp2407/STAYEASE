import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../models/plan_model.dart';
import '../../services/firestore_service.dart';
import '../../widgets/plans/empty_plan_state.dart';

const _kBg = Color(0xFFF7F5EF);
const _kCard = Color(0xFFFFFFFF);
const _kPrimary = Color(0xFF6F8068);
const _kAccent = Color(0xFFC98F65);
const _kText = Color(0xFF252923);
const _kTextMuted = Color(0xFF60675D);
const _kTextFaint = Color(0xFF8F988A);
const _kBorder = Color(0xFFE5E2D8);

const _categories = [
  'Sightseeing', 'Food', 'Shopping', 'Transport', 'Activity', 'Other'
];

class TripItineraryScreen extends StatelessWidget {
  final TripPlan trip;

  const TripItineraryScreen({super.key, required this.trip});

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
        title: Text('Itinerary',
            style: GoogleFonts.cormorantGaramond(
                color: _kText, fontSize: 22, fontWeight: FontWeight.w700)),
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddItemSheet(context),
        backgroundColor: _kPrimary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: Text('Add Item',
            style: GoogleFonts.montserrat(fontWeight: FontWeight.w700)),
      ),
      body: StreamBuilder<List<TripItineraryItem>>(
        stream: FirestoreService.instance.streamTripItinerary(trip.planId),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: _kPrimary));
          }
          if (snap.hasError) {
            return Center(
                child: Text('Something went wrong.',
                    style: GoogleFonts.montserrat(color: _kTextMuted)));
          }
          final items = snap.data ?? [];
          if (items.isEmpty) {
            return EmptyPlanState(
              icon: Icons.calendar_month_outlined,
              title: 'No activities yet',
              subtitle: 'Add your first itinerary item.',
              primaryLabel: 'Add Item',
              onPrimary: () => _showAddItemSheet(context),
            );
          }

          // Group by date
          final Map<String, List<TripItineraryItem>> grouped = {};
          for (final item in items) {
            final key = DateFormat('yyyy-MM-dd').format(item.date);
            grouped.putIfAbsent(key, () => []).add(item);
          }
          final sortedKeys = grouped.keys.toList()..sort();

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            itemCount: sortedKeys.length,
            itemBuilder: (_, i) {
              final dateKey = sortedKeys[i];
              final dayItems = grouped[dateKey]!;
              final date = DateTime.parse(dateKey);
              final dayNum = date.difference(trip.startDate).inDays + 1;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: _kPrimary,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text('Day $dayNum',
                              style: GoogleFonts.montserrat(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700)),
                        ),
                        const SizedBox(width: 10),
                        Text(DateFormat('EEEE, d MMM').format(date),
                            style: GoogleFonts.montserrat(
                                color: _kTextMuted, fontSize: 13)),
                      ],
                    ),
                  ),
                  ...dayItems.map((item) =>
                      _ItineraryItemCard(item: item, planId: trip.planId)),
                ],
              );
            },
          );
        },
      ),
    );
  }

  void _showAddItemSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddItineraryItemSheet(planId: trip.planId),
    );
  }
}

// ─── Itinerary Item Card ──────────────────────────────────────────────────────
class _ItineraryItemCard extends StatelessWidget {
  final TripItineraryItem item;
  final String planId;

  const _ItineraryItemCard({required this.item, required this.planId});

  String _formatInr(double v) =>
      NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0)
          .format(v);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: item.completed
                ? _kPrimary.withValues(alpha: 0.3)
                : _kBorder),
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: GestureDetector(
          onTap: () => FirestoreService.instance.updateItineraryItem(
            planId: planId,
            itemId: item.itemId,
            data: {'completed': !item.completed},
          ),
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: item.completed
                  ? _kPrimary
                  : _kPrimary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              item.completed ? Icons.check_rounded : null,
              color: Colors.white,
              size: 18,
            ),
          ),
        ),
        title: Text(
          item.title,
          style: GoogleFonts.montserrat(
              color: item.completed ? _kTextFaint : _kText,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              decoration:
                  item.completed ? TextDecoration.lineThrough : null),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (item.time.isNotEmpty)
              Text('${item.time}${item.location.isNotEmpty ? ' · ${item.location}' : ''}',
                  style: GoogleFonts.montserrat(
                      color: _kTextFaint, fontSize: 11)),
            Container(
              margin: const EdgeInsets.only(top: 4),
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: _kPrimary.withValues(alpha: 0.07),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(item.category,
                  style: GoogleFonts.montserrat(
                      color: _kPrimary,
                      fontSize: 10,
                      fontWeight: FontWeight.w600)),
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (item.estimatedCost > 0)
              Text(_formatInr(item.estimatedCost),
                  style: GoogleFonts.montserrat(
                      color: _kTextMuted,
                      fontSize: 12,
                      fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            GestureDetector(
              onTap: () => FirestoreService.instance.deleteItineraryItem(
                planId: planId,
                itemId: item.itemId,
              ),
              child: const Icon(Icons.delete_outline,
                  color: _kTextFaint, size: 18),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Add Itinerary Item Sheet ─────────────────────────────────────────────────
class _AddItineraryItemSheet extends StatefulWidget {
  final String planId;

  const _AddItineraryItemSheet({required this.planId});

  @override
  State<_AddItineraryItemSheet> createState() => _AddItineraryItemSheetState();
}

class _AddItineraryItemSheetState extends State<_AddItineraryItemSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _timeCtrl = TextEditingController();
  final _costCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  DateTime _date = DateTime.now();
  String _category = 'Sightseeing';
  bool _loading = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _locationCtrl.dispose();
    _timeCtrl.dispose();
    _costCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final itemId =
          FirebaseFirestore.instance.collection('tmp').doc().id;
      final item = TripItineraryItem(
        itemId: itemId,
        date: _date,
        time: _timeCtrl.text.trim(),
        title: _titleCtrl.text.trim(),
        location: _locationCtrl.text.trim(),
        category: _category,
        notes: _notesCtrl.text.trim(),
        estimatedCost:
            double.tryParse(_costCtrl.text.trim()) ?? 0,
      );
      await FirestoreService.instance.addTripItineraryItem(
        planId: widget.planId,
        item: item,
      );
      if (mounted) Navigator.pop(context);
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 730)),
      builder: (ctx, child) => Theme(
        data: ThemeData.light().copyWith(
          colorScheme: const ColorScheme.light(
              primary: _kPrimary, onPrimary: Colors.white, surface: _kCard),
        ),
        child: child!,
      ),
    );
    if (picked != null && mounted) setState(() => _date = picked);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: _kCard,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                        color: _kBorder,
                        borderRadius: BorderRadius.circular(2)),
                  ),
                ),
                const SizedBox(height: 16),
                Text('Add Activity',
                    style: GoogleFonts.cormorantGaramond(
                        color: _kText,
                        fontSize: 22,
                        fontWeight: FontWeight.w700)),
                const SizedBox(height: 16),
                _field(controller: _titleCtrl, label: 'Activity Name',
                    validator: (v) => v == null || v.trim().isEmpty
                        ? 'Name required'
                        : null),
                const SizedBox(height: 12),
                _field(controller: _locationCtrl, label: 'Location'),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: _pickDate,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 14),
                          decoration: BoxDecoration(
                              color: _kBg,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: _kBorder)),
                          child: Row(children: [
                            const Icon(Icons.calendar_today_outlined,
                                color: _kTextFaint, size: 16),
                            const SizedBox(width: 8),
                            Text(DateFormat('d MMM yyyy').format(_date),
                                style: GoogleFonts.montserrat(
                                    color: _kText, fontSize: 13)),
                          ]),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _field(controller: _timeCtrl, label: 'Time (e.g. 10:00)'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _category,
                  decoration: _inputDec('Category'),
                  style: GoogleFonts.montserrat(color: _kText, fontSize: 14),
                  dropdownColor: _kCard,
                  items: _categories
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (v) => setState(() => _category = v!),
                ),
                const SizedBox(height: 12),
                _field(
                    controller: _costCtrl,
                    label: 'Estimated Cost (₹)',
                    keyboardType: TextInputType.number),
                const SizedBox(height: 12),
                _field(controller: _notesCtrl, label: 'Notes', maxLines: 2),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _kPrimary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _loading
                        ? const CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2)
                        : Text('Add Activity',
                            style: GoogleFonts.montserrat(
                                fontSize: 14, fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDec(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.montserrat(color: _kTextFaint, fontSize: 13),
      filled: true,
      fillColor: _kBg,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _kBorder)),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _kBorder)),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _kPrimary, width: 1.5)),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: GoogleFonts.montserrat(color: _kText, fontSize: 14),
      validator: validator,
      decoration: _inputDec(label),
    );
  }
}

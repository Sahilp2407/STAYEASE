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

const _vendorCategories = [
  'Catering', 'Photography', 'Videography', 'Decoration', 'Music & DJ',
  'Venue', 'Transport', 'Florist', 'Makeup', 'Other'
];
const _vendorStatuses = ['Pending', 'Contacted', 'Confirmed', 'Cancelled'];

class EventVendorsScreen extends StatelessWidget {
  final EventPlan event;
  const EventVendorsScreen({super.key, required this.event});

  Color _statusColor(String status) {
    switch (status) {
      case 'Confirmed': return _kPrimary;
      case 'Contacted': return _kAccent;
      case 'Cancelled': return Colors.red;
      default: return _kTextFaint;
    }
  }

  String _formatInr(double v) =>
      NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0)
          .format(v);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      appBar: AppBar(
        backgroundColor: _kBg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded,
              color: _kText, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Vendors',
            style: GoogleFonts.cormorantGaramond(
                color: _kText, fontSize: 22, fontWeight: FontWeight.w700)),
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddVendorSheet(context),
        backgroundColor: const Color(0xFF5D737E),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.storefront_outlined),
        label: Text('Add Vendor',
            style: GoogleFonts.montserrat(fontWeight: FontWeight.w700)),
      ),
      body: StreamBuilder<List<PlanVendor>>(
        stream: FirestoreService.instance.streamVendors(event.planId),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: _kPrimary));
          }
          final vendors = snap.data ?? [];
          if (vendors.isEmpty) {
            return EmptyPlanState(
              icon: Icons.storefront_outlined,
              title: 'No vendors yet',
              subtitle: 'Add caterers, decorators, photographers and more.',
              primaryLabel: 'Add Vendor',
              onPrimary: () => _showAddVendorSheet(context),
            );
          }

          final totalEst =
              vendors.fold<double>(0, (s, v) => s + v.estimatedCost);
          final totalActual =
              vendors.fold<double>(0, (s, v) => s + v.actualCost);

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: _kCard,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: _kBorder),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _statItem('Total', '${vendors.length}', _kText),
                    _statItem('Est.',
                        _formatInr(totalEst), _kTextMuted),
                    _statItem('Actual',
                        _formatInr(totalActual), _kAccent),
                    _statItem('Confirmed',
                        '${vendors.where((v) => v.status == 'Confirmed').length}',
                        _kPrimary),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              ...vendors.map((v) => _VendorCard(
                    vendor: v,
                    planId: event.planId,
                    statusColor: _statusColor(v.status),
                    onDelete: () => FirestoreService.instance.deleteVendor(
                      planId: event.planId,
                      vendorId: v.vendorId,
                    ),
                    onStatusChange: (status) =>
                        FirestoreService.instance.updateVendor(
                          planId: event.planId,
                          vendorId: v.vendorId,
                          data: {'status': status},
                        ),
                  )),
            ],
          );
        },
      ),
    );
  }

  Widget _statItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(value,
            style: GoogleFonts.montserrat(
                color: color, fontSize: 14, fontWeight: FontWeight.w700)),
        Text(label,
            style: GoogleFonts.montserrat(
                color: _kTextFaint, fontSize: 10)),
      ],
    );
  }

  void _showAddVendorSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddVendorSheet(planId: event.planId),
    );
  }
}

class _VendorCard extends StatelessWidget {
  final PlanVendor vendor;
  final String planId;
  final Color statusColor;
  final VoidCallback onDelete;
  final ValueChanged<String> onStatusChange;

  const _VendorCard({
    required this.vendor,
    required this.planId,
    required this.statusColor,
    required this.onDelete,
    required this.onStatusChange,
  });

  String _fmt(double v) =>
      NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0)
          .format(v);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _kBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.storefront_outlined,
                      color: statusColor, size: 18),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(vendor.vendorName,
                          style: GoogleFonts.montserrat(
                              color: _kText,
                              fontSize: 14,
                              fontWeight: FontWeight.w700)),
                      Text(vendor.category,
                          style: GoogleFonts.montserrat(
                              color: _kTextFaint, fontSize: 11)),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  color: _kCard,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  onSelected: onStatusChange,
                  itemBuilder: (_) => _vendorStatuses
                      .map((s) => PopupMenuItem(
                          value: s,
                          child: Text(s,
                              style: GoogleFonts.montserrat(fontSize: 13))))
                      .toList(),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(vendor.status,
                        style: GoogleFonts.montserrat(
                            color: statusColor,
                            fontSize: 11,
                            fontWeight: FontWeight.w700)),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: onDelete,
                  child: const Icon(Icons.delete_outline,
                      color: _kTextFaint, size: 18),
                ),
              ],
            ),
            if (vendor.contact.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.phone_outlined,
                      color: _kTextFaint, size: 14),
                  const SizedBox(width: 4),
                  Text(vendor.contact,
                      style: GoogleFonts.montserrat(
                          color: _kTextMuted, fontSize: 12)),
                ],
              ),
            ],
            if (vendor.estimatedCost > 0 || vendor.actualCost > 0) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Text('Est: ${_fmt(vendor.estimatedCost)}',
                      style: GoogleFonts.montserrat(
                          color: _kTextMuted, fontSize: 12)),
                  const SizedBox(width: 12),
                  if (vendor.actualCost > 0)
                    Text('Actual: ${_fmt(vendor.actualCost)}',
                        style: GoogleFonts.montserrat(
                            color: _kAccent,
                            fontSize: 12,
                            fontWeight: FontWeight.w600)),
                ],
              ),
            ],
            if (vendor.notes.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(vendor.notes,
                  style: GoogleFonts.montserrat(
                      color: _kTextFaint, fontSize: 11)),
            ],
          ],
        ),
      ),
    );
  }
}

class _AddVendorSheet extends StatefulWidget {
  final String planId;
  const _AddVendorSheet({required this.planId});

  @override
  State<_AddVendorSheet> createState() => _AddVendorSheetState();
}

class _AddVendorSheetState extends State<_AddVendorSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _contactCtrl = TextEditingController();
  final _estCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  String _category = 'Catering';
  String _status = 'Pending';
  bool _loading = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _contactCtrl.dispose();
    _estCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final vendorId = FirebaseFirestore.instance.collection('tmp').doc().id;
      final vendor = PlanVendor(
        vendorId: vendorId,
        category: _category,
        vendorName: _nameCtrl.text.trim(),
        contact: _contactCtrl.text.trim(),
        estimatedCost: double.tryParse(_estCtrl.text.trim()) ?? 0,
        status: _status,
        notes: _notesCtrl.text.trim(),
      );
      await FirestoreService.instance.addPlanVendor(
          planId: widget.planId, vendor: vendor);
      if (mounted) Navigator.pop(context);
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
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
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                          color: _kBorder,
                          borderRadius: BorderRadius.circular(2))),
                ),
                const SizedBox(height: 16),
                Text('Add Vendor',
                    style: GoogleFonts.cormorantGaramond(
                        color: _kText,
                        fontSize: 22,
                        fontWeight: FontWeight.w700)),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _category,
                  decoration: _dec('Category'),
                  style: GoogleFonts.montserrat(color: _kText, fontSize: 14),
                  dropdownColor: _kCard,
                  items: _vendorCategories
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (v) => setState(() => _category = v!),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _nameCtrl,
                  style: GoogleFonts.montserrat(color: _kText, fontSize: 14),
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Name required' : null,
                  decoration: _dec('Vendor Name / Company'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _contactCtrl,
                  keyboardType: TextInputType.phone,
                  style: GoogleFonts.montserrat(color: _kText, fontSize: 14),
                  decoration: _dec('Contact Number'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _estCtrl,
                  keyboardType: TextInputType.number,
                  style: GoogleFonts.montserrat(color: _kText, fontSize: 14),
                  decoration: _dec('Estimated Cost (₹)'),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _status,
                  decoration: _dec('Status'),
                  style: GoogleFonts.montserrat(color: _kText, fontSize: 14),
                  dropdownColor: _kCard,
                  items: _vendorStatuses
                      .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                      .toList(),
                  onChanged: (v) => setState(() => _status = v!),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _notesCtrl,
                  maxLines: 2,
                  style: GoogleFonts.montserrat(color: _kText, fontSize: 14),
                  decoration: _dec('Notes'),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5D737E),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _loading
                        ? const CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2)
                        : Text('Add Vendor',
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

  InputDecoration _dec(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.montserrat(color: _kTextFaint, fontSize: 13),
      filled: true,
      fillColor: _kBg,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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

const _rsvpStatuses = ['Pending', 'Confirmed', 'Declined', 'Maybe'];

class EventGuestsScreen extends StatelessWidget {
  final EventPlan event;
  const EventGuestsScreen({super.key, required this.event});

  Color _rsvpColor(String status) {
    switch (status) {
      case 'Confirmed': return _kPrimary;
      case 'Declined': return Colors.red;
      case 'Maybe': return _kAccent;
      default: return _kTextFaint;
    }
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
        title: Text('Guests',
            style: GoogleFonts.cormorantGaramond(
                color: _kText, fontSize: 22, fontWeight: FontWeight.w700)),
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddGuestSheet(context),
        backgroundColor: _kAccent,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.person_add_outlined),
        label: Text('Add Guest',
            style: GoogleFonts.montserrat(fontWeight: FontWeight.w700)),
      ),
      body: StreamBuilder<List<PlanGuest>>(
        stream: FirestoreService.instance.streamGuests(event.planId),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: _kPrimary));
          }
          final guests = snap.data ?? [];
          if (guests.isEmpty) {
            return EmptyPlanState(
              icon: Icons.people_outline,
              title: 'No guests yet',
              subtitle: 'Add your guests and track their RSVPs.',
              primaryLabel: 'Add Guest',
              onPrimary: () => _showAddGuestSheet(context),
            );
          }

          final confirmed = guests.where((g) => g.rsvpStatus == 'Confirmed').length;
          final pending = guests.where((g) => g.rsvpStatus == 'Pending').length;
          final declined = guests.where((g) => g.rsvpStatus == 'Declined').length;

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            children: [
              // Summary row
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _kCard,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: _kBorder),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _statItem('Total', '${guests.length}', _kText),
                    _statItem('Confirmed', '$confirmed', _kPrimary),
                    _statItem('Pending', '$pending', _kAccent),
                    _statItem('Declined', '$declined', Colors.red),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              ...guests.map((g) => _GuestCard(
                    guest: g,
                    planId: event.planId,
                    rsvpColor: _rsvpColor(g.rsvpStatus),
                    onDelete: () => FirestoreService.instance.deleteGuest(
                      planId: event.planId,
                      guestId: g.guestId,
                    ),
                    onRsvpChange: (status) =>
                        FirestoreService.instance.updateGuest(
                          planId: event.planId,
                          guestId: g.guestId,
                          data: {'rsvpStatus': status},
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
                color: color, fontSize: 20, fontWeight: FontWeight.w700)),
        Text(label,
            style: GoogleFonts.montserrat(
                color: _kTextFaint, fontSize: 11)),
      ],
    );
  }

  void _showAddGuestSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddGuestSheet(planId: event.planId),
    );
  }
}

class _GuestCard extends StatelessWidget {
  final PlanGuest guest;
  final String planId;
  final Color rsvpColor;
  final VoidCallback onDelete;
  final ValueChanged<String> onRsvpChange;

  const _GuestCard({
    required this.guest,
    required this.planId,
    required this.rsvpColor,
    required this.onDelete,
    required this.onRsvpChange,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _kBorder),
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: CircleAvatar(
          backgroundColor: rsvpColor.withValues(alpha: 0.15),
          child: Text(
            guest.name.isNotEmpty ? guest.name[0].toUpperCase() : '?',
            style: GoogleFonts.montserrat(
                color: rsvpColor, fontWeight: FontWeight.w700),
          ),
        ),
        title: Text(guest.name,
            style: GoogleFonts.montserrat(
                color: _kText, fontSize: 13, fontWeight: FontWeight.w600)),
        subtitle: guest.contact.isNotEmpty
            ? Text(guest.contact,
                style: GoogleFonts.montserrat(
                    color: _kTextFaint, fontSize: 11))
            : null,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            PopupMenuButton<String>(
              color: _kCard,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              onSelected: onRsvpChange,
              itemBuilder: (_) => _rsvpStatuses
                  .map((s) =>
                      PopupMenuItem(value: s, child: Text(s,
                          style: GoogleFonts.montserrat(fontSize: 13))))
                  .toList(),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: rsvpColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: rsvpColor.withValues(alpha: 0.3)),
                ),
                child: Text(guest.rsvpStatus,
                    style: GoogleFonts.montserrat(
                        color: rsvpColor,
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
      ),
    );
  }
}

class _AddGuestSheet extends StatefulWidget {
  final String planId;
  const _AddGuestSheet({required this.planId});

  @override
  State<_AddGuestSheet> createState() => _AddGuestSheetState();
}

class _AddGuestSheetState extends State<_AddGuestSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  String _rsvp = 'Pending';
  bool _loading = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final guestId = FirebaseFirestore.instance.collection('tmp').doc().id;
      final guest = PlanGuest(
        guestId: guestId,
        name: _nameCtrl.text.trim(),
        contact: '${_emailCtrl.text.trim()} ${_phoneCtrl.text.trim()}'.trim(),
        rsvpStatus: _rsvp,
      );
      await FirestoreService.instance.addPlanGuest(
          planId: widget.planId, guest: guest);
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
                Text('Add Guest',
                    style: GoogleFonts.cormorantGaramond(
                        color: _kText,
                        fontSize: 22,
                        fontWeight: FontWeight.w700)),
                const SizedBox(height: 16),
                _field(_nameCtrl, 'Full Name',
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Name required' : null),
                const SizedBox(height: 12),
                _field(_emailCtrl, 'Email',
                    keyboardType: TextInputType.emailAddress),
                const SizedBox(height: 12),
                _field(_phoneCtrl, 'Phone',
                    keyboardType: TextInputType.phone),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _rsvp,
                  decoration: _dec('RSVP Status'),
                  style: GoogleFonts.montserrat(color: _kText, fontSize: 14),
                  dropdownColor: _kCard,
                  items: _rsvpStatuses
                      .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                      .toList(),
                  onChanged: (v) => setState(() => _rsvp = v!),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _kAccent,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _loading
                        ? const CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2)
                        : Text('Add Guest',
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

  Widget _field(TextEditingController ctrl, String label,
      {TextInputType? keyboardType,
      String? Function(String?)? validator}) {
    return TextFormField(
      controller: ctrl,
      keyboardType: keyboardType,
      style: GoogleFonts.montserrat(color: _kText, fontSize: 14),
      validator: validator,
      decoration: _dec(label),
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

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

const _priorities = ['Low', 'Medium', 'High'];

class EventTasksScreen extends StatelessWidget {
  final EventPlan event;
  const EventTasksScreen({super.key, required this.event});

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
        title: Text('Tasks',
            style: GoogleFonts.cormorantGaramond(
                color: _kText, fontSize: 22, fontWeight: FontWeight.w700)),
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddTaskSheet(context),
        backgroundColor: _kPrimary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: Text('Add Task',
            style: GoogleFonts.montserrat(fontWeight: FontWeight.w700)),
      ),
      body: StreamBuilder<List<PlanTask>>(
        stream: FirestoreService.instance.streamTasks(event.planId),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: _kPrimary));
          }
          final tasks = snap.data ?? [];
          if (tasks.isEmpty) {
            return EmptyPlanState(
              icon: Icons.task_alt_rounded,
              title: 'No tasks yet',
              subtitle: 'Break your event into manageable tasks.',
              primaryLabel: 'Add Task',
              onPrimary: () => _showAddTaskSheet(context),
            );
          }
          final pending = tasks.where((t) => !t.completed).toList();
          final done = tasks.where((t) => t.completed).toList();
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            children: [
              if (pending.isNotEmpty) ...[
                _groupHeader('Pending', pending.length),
                ...pending.map((t) => _TaskCard(task: t, planId: event.planId)),
              ],
              if (done.isNotEmpty) ...[
                _groupHeader('Completed', done.length),
                ...done.map((t) => _TaskCard(task: t, planId: event.planId)),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _groupHeader(String label, int count) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Text('$label ($count)',
          style: GoogleFonts.montserrat(
              color: _kTextFaint, fontSize: 12, fontWeight: FontWeight.w700)),
    );
  }

  void _showAddTaskSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddTaskSheet(planId: event.planId),
    );
  }
}

class _TaskCard extends StatelessWidget {
  final PlanTask task;
  final String planId;
  const _TaskCard({required this.task, required this.planId});

  Color _priorityColor(String p) {
    if (p == 'High') return Colors.red;
    if (p == 'Medium') return _kAccent;
    return _kPrimary;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: task.completed ? _kPrimary.withValues(alpha: 0.3) : _kBorder),
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: GestureDetector(
          onTap: () => FirestoreService.instance.updateTask(
            planId: planId,
            taskId: task.taskId,
            data: {'completed': !task.completed},
          ),
          child: Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: task.completed
                  ? _kPrimary
                  : _kPrimary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: task.completed
                ? const Icon(Icons.check_rounded,
                    color: Colors.white, size: 16)
                : null,
          ),
        ),
        title: Text(
          task.title,
          style: GoogleFonts.montserrat(
              color: task.completed ? _kTextFaint : _kText,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              decoration:
                  task.completed ? TextDecoration.lineThrough : null),
        ),
        subtitle: Row(
          children: [
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: _priorityColor(task.priority).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(task.priority,
                  style: GoogleFonts.montserrat(
                      color: _priorityColor(task.priority),
                      fontSize: 10,
                      fontWeight: FontWeight.w700)),
            ),
            if (task.dueDate != null) ...[
              const SizedBox(width: 6),
              Text(
                DateFormat('d MMM').format(task.dueDate!),
                style:
                    GoogleFonts.montserrat(color: _kTextFaint, fontSize: 10),
              ),
            ],
          ],
        ),
        trailing: GestureDetector(
          onTap: () => FirestoreService.instance.deleteTask(
            planId: planId,
            taskId: task.taskId,
          ),
          child: const Icon(Icons.delete_outline,
              color: _kTextFaint, size: 18),
        ),
      ),
    );
  }
}

class _AddTaskSheet extends StatefulWidget {
  final String planId;
  const _AddTaskSheet({required this.planId});

  @override
  State<_AddTaskSheet> createState() => _AddTaskSheetState();
}

class _AddTaskSheetState extends State<_AddTaskSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  String _priority = 'Medium';
  DateTime? _dueDate;
  bool _loading = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final taskId = FirebaseFirestore.instance.collection('tmp').doc().id;
      final task = PlanTask(
        taskId: taskId,
        title: _titleCtrl.text.trim(),
        priority: _priority,
        dueDate: _dueDate,
      );
      await FirestoreService.instance.addPlanTask(
          planId: widget.planId, task: task);
      if (mounted) Navigator.pop(context);
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 730)),
      builder: (ctx, child) => Theme(
        data: ThemeData.light().copyWith(
          colorScheme: const ColorScheme.light(
              primary: _kPrimary, onPrimary: Colors.white, surface: _kCard),
        ),
        child: child!,
      ),
    );
    if (picked != null && mounted) setState(() => _dueDate = picked);
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
                Text('Add Task',
                    style: GoogleFonts.cormorantGaramond(
                        color: _kText,
                        fontSize: 22,
                        fontWeight: FontWeight.w700)),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _titleCtrl,
                  style: GoogleFonts.montserrat(color: _kText, fontSize: 14),
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Title required' : null,
                  decoration: _dec('Task Title'),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _priority,
                  decoration: _dec('Priority'),
                  style: GoogleFonts.montserrat(color: _kText, fontSize: 14),
                  dropdownColor: _kCard,
                  items: _priorities
                      .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                      .toList(),
                  onChanged: (v) => setState(() => _priority = v!),
                ),
                const SizedBox(height: 12),
                GestureDetector(
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
                      Text(
                        _dueDate != null
                            ? DateFormat('d MMM yyyy').format(_dueDate!)
                            : 'Due Date (optional)',
                        style: GoogleFonts.montserrat(
                            color: _dueDate != null ? _kText : _kTextFaint,
                            fontSize: 13),
                      ),
                    ]),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _notesCtrl,
                  maxLines: 2,
                  style: GoogleFonts.montserrat(color: _kText, fontSize: 14),
                  decoration: _dec('Notes (optional)'),
                ),
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
                        : Text('Add Task',
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

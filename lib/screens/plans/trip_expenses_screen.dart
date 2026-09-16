import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../models/plan_model.dart';
import '../../models/budget_model.dart';
import '../../services/firestore_service.dart';
import '../../widgets/plans/budget_progress_bar.dart';
import '../../widgets/plans/empty_plan_state.dart';
import '../../widgets/plans/add_expense_sheet.dart';

const _kBg = Color(0xFFF7F5EF);
const _kCard = Color(0xFFFFFFFF);
const _kPrimary = Color(0xFF6F8068);
const _kAccent = Color(0xFFC98F65);
const _kText = Color(0xFF252923);
const _kTextFaint = Color(0xFF8F988A);
const _kBorder = Color(0xFFE5E2D8);

const _tripCategories = [
  'Hotel', 'Transport', 'Food', 'Activities', 'Shopping', 'Other'
];

class TripExpensesScreen extends StatelessWidget {
  final TripPlan trip;

  const TripExpensesScreen({super.key, required this.trip});

  @override
  Widget build(BuildContext context) {
    final budgetId = trip.budgetId;
    if (budgetId == null) {
      return Scaffold(
        backgroundColor: _kBg,
        appBar: _appBar(context),
        body: const EmptyPlanState(
          icon: Icons.receipt_long_outlined,
          title: 'No budget linked',
          subtitle: 'Create a trip with a budget to track expenses.',
        ),
      );
    }

    return Scaffold(
      backgroundColor: _kBg,
      appBar: _appBar(context),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddExpenseSheet(context, budgetId),
        backgroundColor: _kAccent,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: Text('Add Expense',
            style: GoogleFonts.montserrat(fontWeight: FontWeight.w700)),
      ),
      body: StreamBuilder<BudgetPlan?>(
        stream: FirestoreService.instance.streamBudget(budgetId),
        builder: (_, budgetSnap) {
          final budget = budgetSnap.data;
          return StreamBuilder<List<ExpenseItem>>(
            stream:
                FirestoreService.instance.streamBudgetExpenses(budgetId),
            builder: (context, expSnap) {
              final expenses = expSnap.data ?? [];
              return ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                children: [
                  // Budget summary
                  if (budget != null) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _kCard,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: _kBorder),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Budget Overview',
                              style: GoogleFonts.montserrat(
                                  color: _kText,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700)),
                          const SizedBox(height: 16),
                          BudgetProgressBar(
                            totalBudget: budget.totalBudget,
                            actualSpent: budget.actualSpent,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                  if (expenses.isEmpty &&
                      expSnap.connectionState != ConnectionState.waiting)
                    const EmptyPlanState(
                      icon: Icons.receipt_long_outlined,
                      title: 'No expenses yet',
                      subtitle: 'Track your spending by adding expenses.',
                    )
                  else ...[
                    Text('Expenses',
                        style: GoogleFonts.montserrat(
                            color: _kText,
                            fontSize: 14,
                            fontWeight: FontWeight.w700)),
                    const SizedBox(height: 12),
                    ...expenses.map((exp) => _ExpenseCard(
                          expense: exp,
                          budgetId: budgetId,
                        )),
                  ],
                ],
              );
            },
          );
        },
      ),
    );
  }

  AppBar _appBar(BuildContext context) {
    return AppBar(
      backgroundColor: _kBg,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_rounded,
            color: _kText, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text('Expenses',
          style: GoogleFonts.cormorantGaramond(
              color: _kText, fontSize: 22, fontWeight: FontWeight.w700)),
      centerTitle: true,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
    );
  }

  void _showAddExpenseSheet(BuildContext context, String budgetId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddExpenseSheet(
        budgetId: budgetId,
        categories: _tripCategories,
      ),
    );
  }
}

class _ExpenseCard extends StatelessWidget {
  final ExpenseItem expense;
  final String budgetId;

  const _ExpenseCard({required this.expense, required this.budgetId});

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
        border: Border.all(color: _kBorder),
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: _kAccent.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.receipt_outlined,
              color: _kAccent, size: 20),
        ),
        title: Text(expense.description,
            style: GoogleFonts.montserrat(
                color: _kText,
                fontSize: 13,
                fontWeight: FontWeight.w600)),
        subtitle: Text(
            '${expense.categoryId} · ${DateFormat('d MMM').format(expense.date)}',
            style: GoogleFonts.montserrat(
                color: _kTextFaint, fontSize: 11)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_formatInr(expense.amount),
                style: GoogleFonts.montserrat(
                    color: _kText,
                    fontSize: 14,
                    fontWeight: FontWeight.w700)),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => FirestoreService.instance.deleteExpense(
                budgetId: budgetId,
                expenseId: expense.expenseId,
                amount: expense.amount,
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

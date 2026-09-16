import 'package:cloud_firestore/cloud_firestore.dart';

// ── BUDGET PLAN: Trip aur Event ke budget aur kharche track karne ka model ──
class BudgetPlan {
  final String budgetId;
  final String userId;
  final String? planId;
  final String title;
  final String currency;
  final double totalBudget;
  final double estimatedCost;
  final double actualSpent;
  final double remainingAmount;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Constructor: BudgetPlan instance initialize karne ke liye
  const BudgetPlan({
    required this.budgetId,
    required this.userId,
    this.planId,
    required this.title,
    this.currency = 'INR',
    required this.totalBudget,
    this.estimatedCost = 0.0,
    this.actualSpent = 0.0,
    required this.remainingAmount,
    required this.createdAt,
    required this.updatedAt,
  });

  // BudgetPlan object ko Firestore JSON Map me convert karna
  Map<String, dynamic> toFirestore() {
    return {
      'budgetId': budgetId,
      'userId': userId,
      'planId': planId,
      'title': title,
      'currency': currency,
      'totalBudget': totalBudget,
      'estimatedCost': estimatedCost,
      'actualSpent': actualSpent,
      'remainingAmount': totalBudget - actualSpent,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  // Firestore DocumentSnapshot se BudgetPlan object parse karna
  factory BudgetPlan.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    final total = (data['totalBudget'] as num?)?.toDouble() ?? 0.0;
    final spent = (data['actualSpent'] as num?)?.toDouble() ?? 0.0;
    return BudgetPlan(
      budgetId: doc.id,
      userId: data['userId'] as String? ?? '',
      planId: data['planId'] as String?,
      title: data['title'] as String? ?? 'Trip Budget',
      currency: data['currency'] as String? ?? 'INR',
      totalBudget: total,
      estimatedCost: (data['estimatedCost'] as num?)?.toDouble() ?? 0.0,
      actualSpent: spent,
      remainingAmount: (data['remainingAmount'] as num?)?.toDouble() ?? (total - spent),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}

// ── BUDGET CATEGORY: Hotel, Food, Travel ityadi category-wise allocation model ──
class BudgetCategoryItem {
  final String categoryId;
  final String name; // Hotel, Transport, Food, Activities, Shopping, Venue, Decoration, Photography, Entertainment, Misc
  final double allocatedAmount;
  final double spentAmount;

  // Constructor: Category allocation item initialize karne ke liye
  const BudgetCategoryItem({
    required this.categoryId,
    required this.name,
    required this.allocatedAmount,
    this.spentAmount = 0.0,
  });

  // Category item ko Firestore JSON Map me convert karna
  Map<String, dynamic> toFirestore() {
    return {
      'categoryId': categoryId,
      'name': name,
      'allocatedAmount': allocatedAmount,
      'spentAmount': spentAmount,
    };
  }

  // Firestore Document se Category allocation item parse karna
  factory BudgetCategoryItem.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return BudgetCategoryItem(
      categoryId: doc.id,
      name: data['name'] as String? ?? 'General',
      allocatedAmount: (data['allocatedAmount'] as num?)?.toDouble() ?? 0.0,
      spentAmount: (data['spentAmount'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

// ── EXPENSE ITEM: Individual kharche ka record (amount, date, note) model ──
class ExpenseItem {
  final String expenseId;
  final String categoryId;
  final String description;
  final double amount;
  final DateTime date;
  final String notes;
  final DateTime createdAt;

  // Constructor: Expense entry initialize karne ke liye
  const ExpenseItem({
    required this.expenseId,
    required this.categoryId,
    required this.description,
    required this.amount,
    required this.date,
    this.notes = '',
    required this.createdAt,
  });

  // Expense entry ko Firestore JSON Map me convert karna
  Map<String, dynamic> toFirestore() {
    return {
      'expenseId': expenseId,
      'categoryId': categoryId,
      'description': description,
      'amount': amount,
      'date': Timestamp.fromDate(date),
      'notes': notes,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  // Firestore Document se Expense entry parse karna
  factory ExpenseItem.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return ExpenseItem(
      expenseId: doc.id,
      categoryId: data['categoryId'] as String? ?? 'General',
      description: data['description'] as String? ?? '',
      amount: (data['amount'] as num?)?.toDouble() ?? 0.0,
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      notes: data['notes'] as String? ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}

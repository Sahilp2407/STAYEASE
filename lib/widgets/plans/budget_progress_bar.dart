import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

// ─── StayEase color palette ──────────────────────────────────────────────────
const _kBg = Color(0xFFF7F5EF);
const _kCard = Color(0xFFFFFFFF);
const _kPrimary = Color(0xFF6F8068);
const _kAccent = Color(0xFFC98F65);
const _kText = Color(0xFF252923);
const _kTextMuted = Color(0xFF60675D);
const _kTextFaint = Color(0xFF8F988A);
const _kBorder = Color(0xFFE5E2D8);
const _kWarning = Color(0xFFC98F65);
const _kDanger = Color(0xFFB05252);

class BudgetProgressBar extends StatelessWidget {
  final double totalBudget;
  final double actualSpent;
  final double estimatedCost;
  final bool showWarnings;

  const BudgetProgressBar({
    super.key,
    required this.totalBudget,
    required this.actualSpent,
    this.estimatedCost = 0,
    this.showWarnings = true,
  });

  String _formatInr(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }

  @override
  Widget build(BuildContext context) {
    final safeTotal = totalBudget <= 0 ? 1.0 : totalBudget;
    final spentFraction = (actualSpent / safeTotal).clamp(0.0, 1.0);
    final remaining = totalBudget - actualSpent;
    final isOverBudget = actualSpent > totalBudget;
    final isNearBudget = !isOverBudget && spentFraction >= 0.8;

    Color barColor = _kPrimary;
    if (isOverBudget) barColor = _kDanger;
    else if (isNearBudget) barColor = _kWarning;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Numbers row
        Row(
          children: [
            _budgetChip('Total', _formatInr(totalBudget), _kTextFaint),
            const SizedBox(width: 12),
            _budgetChip('Spent', _formatInr(actualSpent),
                isOverBudget ? _kDanger : isNearBudget ? _kWarning : _kText),
            const SizedBox(width: 12),
            _budgetChip(
                'Left',
                _formatInr(remaining.abs()),
                isOverBudget ? _kDanger : _kPrimary),
          ],
        ),
        const SizedBox(height: 10),
        // Progress bar
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: spentFraction),
            duration: const Duration(milliseconds: 700),
            curve: Curves.easeOutCubic,
            builder: (_, value, __) {
              return LinearProgressIndicator(
                value: value,
                minHeight: 8,
                backgroundColor: _kBorder,
                valueColor: AlwaysStoppedAnimation(barColor),
              );
            },
          ),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${(spentFraction * 100).toStringAsFixed(0)}% used',
              style: GoogleFonts.montserrat(
                  color: barColor, fontSize: 11, fontWeight: FontWeight.w600),
            ),
            Text(
              isOverBudget
                  ? 'Over budget by ${_formatInr(actualSpent - totalBudget)}'
                  : '${_formatInr(remaining)} remaining',
              style: GoogleFonts.montserrat(
                  color: isOverBudget ? _kDanger : _kTextFaint, fontSize: 11),
            ),
          ],
        ),
        if (showWarnings) ...[
          if (isOverBudget) _warningBanner('You\'re over budget by ${_formatInr(actualSpent - totalBudget)}', _kDanger),
          if (isNearBudget) _warningBanner('You\'re close to your budget.', _kWarning),
        ],
      ],
    );
  }

  Widget _budgetChip(String label, String value, Color valueColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: GoogleFonts.montserrat(
                color: _kTextFaint,
                fontSize: 10,
                fontWeight: FontWeight.w500)),
        Text(value,
            style: GoogleFonts.montserrat(
                color: valueColor,
                fontSize: 13,
                fontWeight: FontWeight.w700)),
      ],
    );
  }

  Widget _warningBanner(String msg, Color color) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: color, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(msg,
                style: GoogleFonts.montserrat(
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

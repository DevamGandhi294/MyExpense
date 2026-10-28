import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../app/theme/app_colors.dart';
import '../../data/models/debt_model.dart';
import '../../shared/widgets/app_add_button.dart';
import '../../shared/widgets/app_loader.dart';
import 'debts_controller.dart';

String _fmt(double amount) => NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 0,
    ).format(amount);

String _fmtDate(DateTime d) => DateFormat('dd MMM yyyy').format(d);

class DebtsView extends GetView<DebtsController> {
  const DebtsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutral50,
      appBar: AppBar(
        backgroundColor: AppColors.neutral50,
        elevation: 0,
        foregroundColor: const Color(0xFF1A1A2E),
        title: const Text(
          'Lend & Borrow',
          style: TextStyle(
            color: AppColors.accentPurple,
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
      ),
      floatingActionButton: AppAddButton(
        tooltip: 'Add entry',
        onPressed: () => _showAddSheet(context),
      ),
      body: RefreshIndicator(
        color: AppColors.accentPurple,
        onRefresh: controller.loadDebts,
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: AppLoader(size: 80));
          }
          final list = controller.visibleDebts;
          return ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
            children: [
              Row(
                children: [
                  _SummaryTile(
                    label: 'You will get',
                    amount: controller.toReceive,
                    color: AppColors.incomeGreen,
                  ),
                  const SizedBox(width: 12),
                  _SummaryTile(
                    label: 'You have to give',
                    amount: controller.toPay,
                    color: AppColors.expenseRed,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _TypeToggle(
                selected: controller.selectedTab.value,
                onChanged: (t) => controller.selectedTab.value = t,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Text('Show settled', style: TextStyle(fontSize: 13)),
                  Switch(
                    value: controller.showSettled.value,
                    activeColor: AppColors.accentPurple,
                    onChanged: (v) => controller.showSettled.value = v,
                  ),
                ],
              ),
              if (list.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Center(
                    child: Text(
                      controller.selectedTab.value == DebtModel.lent
                          ? 'Nobody owes you money'
                          : 'You don\'t owe anyone',
                      style: TextStyle(fontSize: 15, color: Colors.grey.shade400),
                    ),
                  ),
                )
              else
                ...list.map((d) => _DebtTile(debt: d)),
            ],
          );
        }),
      ),
    );
  }

  void _showAddSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _AddDebtSheet(initialType: controller.selectedTab.value),
    );
  }
}

class _SummaryTile extends StatelessWidget {
  final String label;
  final double amount;
  final Color color;

  const _SummaryTile({
    required this.label,
    required this.amount,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0x0F000000)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
            const SizedBox(height: 6),
            Text(
              _fmt(amount),
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: color),
            ),
          ],
        ),
      ),
    );
  }
}

class _TypeToggle extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onChanged;

  const _TypeToggle({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    Widget option(String type, String label) {
      final active = selected == type;
      return Expanded(
        child: GestureDetector(
          onTap: () => onChanged(type),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: active ? AppColors.accentPurple : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: active ? Colors.white : AppColors.neutral600,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          option(DebtModel.lent, 'I Gave (To Get)'),
          option(DebtModel.borrowed, 'I Took (To Give)'),
        ],
      ),
    );
  }
}

class _DebtTile extends GetView<DebtsController> {
  final DebtModel debt;

  const _DebtTile({required this.debt});

  @override
  Widget build(BuildContext context) {
    final color = debt.isLent ? AppColors.incomeGreen : AppColors.expenseRed;
    final verb = debt.isLent ? 'Given on' : 'Taken on';
    final overdue = !debt.isSettled &&
        debt.dueDate != null &&
        debt.dueDate!.isBefore(DateTime.now());

    return Dismissible(
      key: Key(debt.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Colors.red.shade600,
          borderRadius: BorderRadius.circular(14),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete_outline_rounded, color: Colors.white),
      ),
      confirmDismiss: (_) => showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Delete Entry'),
          content: Text('Delete entry for ${debt.personName}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      ),
      onDismissed: (_) => controller.deleteDebt(debt),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0x0F000000)),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: color.withOpacity(0.12),
              child: Text(
                debt.personName.isNotEmpty ? debt.personName[0].toUpperCase() : '?',
                style: TextStyle(color: color, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    debt.personName,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1A1A2E),
                      decoration: debt.isSettled ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text('$verb ${_fmtDate(debt.date)}',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                  if (debt.dueDate != null && !debt.isSettled)
                    Text(
                      'Return by ${_fmtDate(debt.dueDate!)}${overdue ? ' · Overdue' : ''}',
                      style: TextStyle(
                        fontSize: 12,
                        color: overdue ? AppColors.expenseRed : Colors.grey.shade600,
                      ),
                    ),
                  if (debt.isSettled && debt.settledDate != null)
                    Text('Settled on ${_fmtDate(debt.settledDate!)}',
                        style: const TextStyle(fontSize: 12, color: AppColors.incomeGreen)),
                  if (debt.note.isNotEmpty)
                    Text(debt.note,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _fmt(debt.amount),
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: color),
                ),
                TextButton(
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(0, 30),
                  ),
                  onPressed: () => controller.toggleSettled(debt),
                  child: Text(
                    debt.isSettled ? 'Undo' : 'Mark settled',
                    style: const TextStyle(fontSize: 12, color: AppColors.accentPurple),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AddDebtSheet extends StatefulWidget {
  final String initialType;

  const _AddDebtSheet({required this.initialType});

  @override
  State<_AddDebtSheet> createState() => _AddDebtSheetState();
}

class _AddDebtSheetState extends State<_AddDebtSheet> {
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  late String _type = widget.initialType;
  DateTime _date = DateTime.now();
  DateTime? _dueDate;
  bool _saving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<DateTime?> _pick(DateTime initial) => showDatePicker(
        context: context,
        initialDate: initial,
        firstDate: DateTime(2000),
        lastDate: DateTime(2100),
      );

  Future<void> _save() async {
    final name = _nameController.text.trim();
    final amount = double.tryParse(_amountController.text.trim()) ?? 0;
    if (name.isEmpty || amount <= 0) {
      Get.snackbar('Missing details', 'Enter a name and an amount greater than zero.');
      return;
    }
    setState(() => _saving = true);
    await Get.find<DebtsController>().addDebt(DebtModel(
      id: '',
      type: _type,
      personName: name,
      amount: amount,
      date: _date,
      dueDate: _dueDate,
      note: _noteController.text.trim(),
      isSettled: false,
      createdAt: DateTime.now(),
    ));
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isLent = _type == DebtModel.lent;
    return Padding(
      padding: EdgeInsets.fromLTRB(
          20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _TypeToggle(selected: _type, onChanged: (t) => setState(() => _type = t)),
          const SizedBox(height: 16),
          TextField(
            controller: _nameController,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(
              labelText: isLent ? 'Given to (name)' : 'Taken from (name)',
            ),
          ),
          TextField(
            controller: _amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(labelText: 'Amount', prefixText: '₹ '),
          ),
          TextField(
            controller: _noteController,
            decoration: const InputDecoration(labelText: 'Note (optional)'),
          ),
          const SizedBox(height: 8),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.event),
            title: Text(isLent ? 'Date I gave' : 'Date I took'),
            subtitle: Text(_fmtDate(_date)),
            onTap: () async {
              final d = await _pick(_date);
              if (d != null) setState(() => _date = d);
            },
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.event_available),
            title: const Text('Return by (optional)'),
            subtitle: Text(_dueDate != null ? _fmtDate(_dueDate!) : 'Not set'),
            trailing: _dueDate != null
                ? IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => setState(() => _dueDate = null),
                  )
                : null,
            onTap: () async {
              final d = await _pick(_dueDate ?? _date);
              if (d != null) setState(() => _dueDate = d);
            },
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accentPurple,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            onPressed: _saving ? null : _save,
            child: Text(_saving ? 'Saving...' : 'Save'),
          ),
        ],
      ),
    );
  }
}

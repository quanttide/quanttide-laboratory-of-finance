import 'package:flutter_test/flutter_test.dart';
import 'package:qtbudget/models/account_code.dart';
import 'package:qtbudget/models/budget.dart';
import 'package:qtbudget/models/transaction.dart';
import 'package:qtbudget/services/storage_service.dart';
import 'shared/fake_storage.dart';

/// 演示一个完整的使用场景：研发部门 2026 年 6 月预算编制与执行
void main() {
  late StorageService storage;

  setUp(() {
    StorageService.useBackend(InMemoryStorageBackend());
    storage = StorageService();

    // 加载默认科目（覆盖 _defaultAccountCodes 的初始化）
    // 但我们需要自定义科目来匹配场景
  });

  test('完整场景：研发部 2026 年 6 月预算', () {
    // ===== 第一阶段：初始设置 =====
    // 预算科目（模拟研发部门的科目体系）
    final codes = [
      AccountCode(id: 'c1', code: 'R01', name: '人力成本', type: AccountType.expense),
      AccountCode(id: 'c2', code: 'R02', name: '办公费用', type: AccountType.expense),
      AccountCode(id: 'c3', code: 'R03', name: '设备采购', type: AccountType.expense),
      AccountCode(id: 'c4', code: 'R04', name: '差旅费用', type: AccountType.expense),
      AccountCode(id: 'c5', code: 'I01', name: '项目收入', type: AccountType.income),
    ];
    storage.saveAccountCodes(codes);
    print('✓ 预算科目已配置：${codes.map((c) => '${c.code} ${c.name}').join('、')}');

    // ===== 第二阶段：预算编制 =====
    final budget = Budget(
      id: 'b_202606',
      name: '研发部 2026 年 6 月预算',
      year: 2026,
      month: 6,
      items: [
        BudgetItem(accountCodeId: 'c1', accountName: '人力成本', plannedAmount: 80000),
        BudgetItem(accountCodeId: 'c2', accountName: '办公费用', plannedAmount: 5000),
        BudgetItem(accountCodeId: 'c3', accountName: '设备采购', plannedAmount: 20000),
        BudgetItem(accountCodeId: 'c4', accountName: '差旅费用', plannedAmount: 8000),
      ],
    );
    storage.saveBudgets([budget]);
    print('\n✓ 预算编制完成：${budget.name}');
    print('  总预算：¥${budget.totalPlanned}');
    for (final item in budget.items) {
      print('  - ${item.accountName}：¥${item.plannedAmount}');
    }

    // ===== 第三阶段：日常收支录入 =====
    final txns = [
      Transaction(
        id: 'tx_01', budgetId: budget.id, accountCodeId: 'c1',
        description: '6 月第一周工资', amount: 40000,
        date: DateTime(2026, 6, 5), type: TransactionType.expense,
      ),
      Transaction(
        id: 'tx_02', budgetId: budget.id, accountCodeId: 'c2',
        description: '打印纸和耗材', amount: 800,
        date: DateTime(2026, 6, 8), type: TransactionType.expense,
      ),
      Transaction(
        id: 'tx_03', budgetId: budget.id, accountCodeId: 'c4',
        description: '上海出差机票+住宿', amount: 3500,
        date: DateTime(2026, 6, 12), type: TransactionType.expense,
      ),
      Transaction(
        id: 'tx_04', budgetId: budget.id, accountCodeId: 'c3',
        description: 'GPU 服务器租赁（6月）', amount: 20000,
        date: DateTime(2026, 6, 15), type: TransactionType.expense,
      ),
      Transaction(
        id: 'tx_05', budgetId: budget.id, accountCodeId: 'c1',
        description: '6 月第三周工资', amount: 40000,
        date: DateTime(2026, 6, 20), type: TransactionType.expense,
      ),
      Transaction(
        id: 'tx_06', budgetId: budget.id, accountCodeId: 'c2',
        description: '团队下午茶', amount: 350,
        date: DateTime(2026, 6, 22), type: TransactionType.expense,
      ),
      Transaction(
        id: 'tx_07', budgetId: budget.id, accountCodeId: 'c4',
        description: '北京出差高铁票', amount: 1200,
        date: DateTime(2026, 6, 25), type: TransactionType.expense,
      ),
      // 一笔项目收入
      Transaction(
        id: 'tx_08', budgetId: budget.id, accountCodeId: 'c5',
        description: '大数据平台项目首期款', amount: 50000,
        date: DateTime(2026, 6, 18), type: TransactionType.income,
      ),
    ];
    storage.saveTransactions(txns);
    print('\n✓ 收支录入完成（共 ${txns.length} 笔）：');
    for (final t in txns) {
      final sign = t.type == TransactionType.expense ? '-' : '+';
      print('  ${t.date.toString().substring(0, 10)} ${sign}¥${t.amount}  ${t.description}');
    }

    // ===== 第四阶段：更新预算实际金额 =====
    for (final txn in txns) {
      final item = budget.items.firstWhere(
        (i) => i.accountCodeId == txn.accountCodeId,
        orElse: () {
          // 如果是收入科目（不在预算中），跳过
          final item2 = BudgetItem(
            accountCodeId: txn.accountCodeId,
            accountName: codes.firstWhere((c) => c.id == txn.accountCodeId).name,
          );
          budget.items.add(item2);
          return item2;
        },
      );
      if (txn.type == TransactionType.expense) {
        item.actualAmount += txn.amount;
      } else {
        item.actualAmount -= txn.amount; // 收入减少实际支出（负支出）
      }
    }
    storage.saveBudgets([budget]);

    // ===== 第五阶段：执行率概览 =====
    print('\n========== 执行率概览 ==========');
    print('预算：${budget.name}');
    print('科目'.padRight(12) + '计划'.padLeft(10) + '实际'.padLeft(10) + '执行率'.padLeft(8));
    print('----------------------------------------');
    for (final item in budget.items) {
      final rate = item.plannedAmount > 0
          ? (item.actualAmount / item.plannedAmount * 100).toStringAsFixed(1) + '%'
          : 'N/A';
      print('${item.accountName.padRight(8)} ¥${item.plannedAmount.toStringAsFixed(0).padLeft(7)} ¥${item.actualAmount.toStringAsFixed(0).padLeft(7)} ${rate.padLeft(7)}');
    }
    print('----------------------------------------');
    print('合计：¥${budget.totalPlanned.toStringAsFixed(0).padLeft(9)}  ¥${budget.totalActual.toStringAsFixed(0).padLeft(9)}  ${(budget.executionRate * 100).toStringAsFixed(1)}%');

    // ===== 验证关键指标 =====
    // 总计划支出 113000，实际支出（扣除收入后净支出）55850
    expect(budget.totalPlanned, 113000);
    expect(budget.totalActual, 55850);
    expect(budget.executionRate, closeTo(0.494, 0.001));
    print('\n✓ 预算执行率 ${(budget.executionRate * 100).toStringAsFixed(1)}%（收入 ¥50000 已抵扣）✓');
  });
}

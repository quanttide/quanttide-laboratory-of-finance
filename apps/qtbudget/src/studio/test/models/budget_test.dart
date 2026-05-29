import 'package:flutter_test/flutter_test.dart';
import 'package:qtbudget/models/budget.dart';

void main() {
  group('BudgetItem', () {
    test('toJson / fromJson round-trip', () {
      final item = BudgetItem(
        accountCodeId: '1',
        accountName: '办公费用',
        plannedAmount: 10000,
        actualAmount: 5000,
      );
      final json = item.toJson();
      final restored = BudgetItem.fromJson(json);

      expect(restored.accountCodeId, item.accountCodeId);
      expect(restored.accountName, item.accountName);
      expect(restored.plannedAmount, item.plannedAmount);
      expect(restored.actualAmount, item.actualAmount);
    });

    test('executionRate returns ratio when plannedAmount > 0', () {
      final item = BudgetItem(
        accountCodeId: '1',
        accountName: '办公费用',
        plannedAmount: 1000,
        actualAmount: 500,
      );
      expect(item.executionRate, 0.5);
    });

    test('executionRate returns 0 when plannedAmount is 0', () {
      final item = BudgetItem(
        accountCodeId: '1',
        accountName: '办公费用',
        plannedAmount: 0,
        actualAmount: 500,
      );
      expect(item.executionRate, 0);
    });

    test('executionRate handles full execution', () {
      final item = BudgetItem(
        accountCodeId: '1',
        accountName: '办公费用',
        plannedAmount: 1000,
        actualAmount: 1000,
      );
      expect(item.executionRate, 1.0);
    });

    test('executionRate handles overspend', () {
      final item = BudgetItem(
        accountCodeId: '1',
        accountName: '办公费用',
        plannedAmount: 1000,
        actualAmount: 2000,
      );
      expect(item.executionRate, 2.0);
    });

    test('fromJson defaults missing fields', () {
      final json = {
        'accountCodeId': '1',
        'plannedAmount': 0,
        'actualAmount': 0,
      };
      final item = BudgetItem.fromJson(json);
      expect(item.accountCodeId, '1');
      expect(item.accountName, '');
      expect(item.plannedAmount, 0);
      expect(item.actualAmount, 0);
    });
  });

  group('Budget', () {
    final now = DateTime(2026, 5, 29);

    Budget createSampleBudget({
      String id = 'b1',
      String name = '五月预算',
      int year = 2026,
      int? month = 5,
      BudgetStatus status = BudgetStatus.draft,
      List<BudgetItem>? items,
    }) {
      return Budget(
        id: id,
        name: name,
        year: year,
        month: month,
        status: status,
        items: items,
        createdAt: now,
        updatedAt: now,
      );
    }

    test('isYearly returns true when month is null', () {
      final b = createSampleBudget(month: null);
      expect(b.isYearly, isTrue);
    });

    test('isYearly returns false when month is set', () {
      final b = createSampleBudget();
      expect(b.isYearly, isFalse);
    });

    test('type returns yearly when month is null', () {
      final b = createSampleBudget(month: null);
      expect(b.type, BudgetType.yearly);
    });

    test('type returns monthly when month is set', () {
      final b = createSampleBudget();
      expect(b.type, BudgetType.monthly);
    });

    test('totalPlanned sums all items', () {
      final b = createSampleBudget(items: [
        BudgetItem(accountCodeId: '1', accountName: 'a', plannedAmount: 100, actualAmount: 0),
        BudgetItem(accountCodeId: '2', accountName: 'b', plannedAmount: 200, actualAmount: 0),
        BudgetItem(accountCodeId: '3', accountName: 'c', plannedAmount: 300, actualAmount: 0),
      ]);
      expect(b.totalPlanned, 600);
    });

    test('totalActual sums all items', () {
      final b = createSampleBudget(items: [
        BudgetItem(accountCodeId: '1', accountName: 'a', plannedAmount: 100, actualAmount: 10),
        BudgetItem(accountCodeId: '2', accountName: 'b', plannedAmount: 200, actualAmount: 20),
        BudgetItem(accountCodeId: '3', accountName: 'c', plannedAmount: 300, actualAmount: 30),
      ]);
      expect(b.totalActual, 60);
    });

    test('executionRate is 0 when totalPlanned is 0', () {
      final b = createSampleBudget(items: []);
      expect(b.executionRate, 0);
    });

    test('executionRate computes correct ratio', () {
      final b = createSampleBudget(items: [
        BudgetItem(accountCodeId: '1', accountName: 'a', plannedAmount: 1000, actualAmount: 250),
      ]);
      expect(b.executionRate, 0.25);
    });

    test('toJson / fromJson round-trip', () {
      final b = createSampleBudget(
        items: [
          BudgetItem(accountCodeId: '1', accountName: '办公费用', plannedAmount: 5000, actualAmount: 3000),
          BudgetItem(accountCodeId: '2', accountName: '差旅费用', plannedAmount: 3000, actualAmount: 1500),
        ],
      );
      final json = b.toJson();
      final restored = Budget.fromJson(json);

      expect(restored.id, b.id);
      expect(restored.name, b.name);
      expect(restored.year, b.year);
      expect(restored.month, b.month);
      expect(restored.status, b.status);
      expect(restored.createdAt.toIso8601String(), b.createdAt.toIso8601String());
      expect(restored.updatedAt.toIso8601String(), b.updatedAt.toIso8601String());
      expect(restored.items.length, b.items.length);
      expect(restored.items[0].accountCodeId, b.items[0].accountCodeId);
      expect(restored.items[0].plannedAmount, b.items[0].plannedAmount);
      expect(restored.items[0].actualAmount, b.items[0].actualAmount);
    });

    test('fromJson handles null items', () {
      final json = {
        'id': 'b1',
        'name': 'test',
        'year': 2026,
        'month': 5,
        'status': 'draft',
        'createdAt': now.toIso8601String(),
        'updatedAt': now.toIso8601String(),
      };
      final b = Budget.fromJson(json);
      expect(b.items, isEmpty);
    });

    test('fromJson defaults status to draft', () {
      final json = {
        'id': 'b1',
        'name': 'test',
        'year': 2026,
        'items': [],
        'createdAt': now.toIso8601String(),
        'updatedAt': now.toIso8601String(),
      };
      expect(Budget.fromJson(json).status, BudgetStatus.draft);
    });

    test('enum BudgetStatus has draft/active/closed', () {
      expect(BudgetStatus.values, hasLength(3));
      expect(BudgetStatus.draft, isA<BudgetStatus>());
      expect(BudgetStatus.active, isA<BudgetStatus>());
      expect(BudgetStatus.closed, isA<BudgetStatus>());
    });

    test('enum BudgetType has yearly/monthly', () {
      expect(BudgetType.values, hasLength(2));
      expect(BudgetType.yearly, isA<BudgetType>());
      expect(BudgetType.monthly, isA<BudgetType>());
    });
  });
}

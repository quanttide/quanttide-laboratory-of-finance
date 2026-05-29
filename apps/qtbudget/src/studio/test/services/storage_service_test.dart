import 'package:flutter_test/flutter_test.dart';
import 'package:qtbudget/models/account_code.dart';
import 'package:qtbudget/models/budget.dart';
import 'package:qtbudget/models/transaction.dart';
import 'package:qtbudget/services/storage_service.dart';
import '../shared/fake_storage.dart';

void main() {
  late InMemoryStorageBackend backend;
  late StorageService service;

  setUp(() {
    backend = InMemoryStorageBackend();
    StorageService.useBackend(backend);
    service = StorageService();
  });

  group('AccountCodes', () {
    test('load returns empty list when none saved', () {
      expect(service.loadAccountCodes(), isEmpty);
    });

    test('save and load round-trip', () {
      final codes = [
        AccountCode(id: '10', code: 'Z01', name: '自定义科目', type: AccountType.expense),
      ];
      service.saveAccountCodes(codes);
      final loaded = service.loadAccountCodes();
      expect(loaded.length, 1);
      expect(loaded[0].name, '自定义科目');
    });
  });

  group('Budgets', () {
    test('load returns empty list when none saved', () {
      expect(service.loadBudgets(), isEmpty);
    });

    test('save and load round-trip', () {
      final budgets = [
        Budget(
          id: 'b1',
          name: '测试预算',
          year: 2026,
          month: 6,
          items: [
            BudgetItem(accountCodeId: '1', accountName: '办公费用', plannedAmount: 5000),
          ],
        ),
      ];
      service.saveBudgets(budgets);
      final loaded = service.loadBudgets();
      expect(loaded.length, 1);
      expect(loaded[0].name, '测试预算');
      expect(loaded[0].items.length, 1);
      expect(loaded[0].items[0].plannedAmount, 5000);
    });

    test('multiple budgets are persisted', () {
      service.saveBudgets([
        Budget(id: 'b1', name: '预算一', year: 2026),
        Budget(id: 'b2', name: '预算二', year: 2026),
      ]);
      expect(service.loadBudgets().length, 2);
    });
  });

  group('Transactions', () {
    test('load returns empty list when none saved', () {
      expect(service.loadTransactions(), isEmpty);
    });

    test('save and load round-trip', () {
      final txns = [
        Transaction(
          id: 'tx1',
          budgetId: 'b1',
          accountCodeId: '1',
          description: '测试支出',
          amount: 500,
          date: DateTime(2026, 5, 29),
          type: TransactionType.expense,
        ),
      ];
      service.saveTransactions(txns);
      final loaded = service.loadTransactions();
      expect(loaded.length, 1);
      expect(loaded[0].description, '测试支出');
      expect(loaded[0].type, TransactionType.expense);
    });
  });

  group('Cross-entity isolation', () {
    test('saving budgets does not affect transactions', () {
      service.saveBudgets([Budget(id: 'b1', name: '预算', year: 2026)]);
      service.saveTransactions([
        Transaction(
          id: 'tx1', budgetId: 'b1', accountCodeId: '1',
          description: 'test', amount: 100,
          date: DateTime(2026, 5, 29), type: TransactionType.expense,
        ),
      ]);

      expect(service.loadBudgets().length, 1);
      expect(service.loadTransactions().length, 1);

      service.saveBudgets([]);
      expect(service.loadBudgets(), isEmpty);
      expect(service.loadTransactions().length, 1);
    });
  });
}

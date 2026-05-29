import 'package:flutter_test/flutter_test.dart';
import 'package:qtbudget/models/transaction.dart';

void main() {
  group('Transaction', () {
    final now = DateTime(2026, 5, 29, 10, 30);

    Transaction createSampleTransaction({
      String id = 'tx1',
      String budgetId = 'b1',
      String accountCodeId = '1',
      String description = '购买办公用品',
      double amount = 500,
      TransactionType type = TransactionType.expense,
    }) {
      return Transaction(
        id: id,
        budgetId: budgetId,
        accountCodeId: accountCodeId,
        description: description,
        amount: amount,
        date: now,
        type: type,
      );
    }

    test('toJson / fromJson round-trip for expense', () {
      final txn = createSampleTransaction();
      final json = txn.toJson();
      final restored = Transaction.fromJson(json);

      expect(restored.id, txn.id);
      expect(restored.budgetId, txn.budgetId);
      expect(restored.accountCodeId, txn.accountCodeId);
      expect(restored.description, txn.description);
      expect(restored.amount, txn.amount);
      expect(restored.date.toIso8601String(), txn.date.toIso8601String());
      expect(restored.type, txn.type);
    });

    test('toJson / fromJson round-trip for income', () {
      final txn = createSampleTransaction(
        description: '销售收入',
        amount: 10000,
        type: TransactionType.income,
      );
      final json = txn.toJson();
      final restored = Transaction.fromJson(json);
      expect(restored.type, TransactionType.income);
      expect(restored.amount, 10000);
    });

    test('fromJson handles amount as int', () {
      final json = {
        'id': 'tx2',
        'budgetId': 'b1',
        'accountCodeId': '2',
        'description': 'test',
        'amount': 1000,
        'date': now.toIso8601String(),
        'type': 'expense',
      };
      final txn = Transaction.fromJson(json);
      expect(txn.amount, 1000.0);
    });

    test('fromJson defaults type to expense', () {
      final json = {
        'id': 'tx3',
        'budgetId': 'b1',
        'accountCodeId': '1',
        'description': 'test',
        'amount': 100,
        'date': now.toIso8601String(),
      };
      final txn = Transaction.fromJson(json);
      expect(txn.type, TransactionType.expense);
    });

    test('TransactionType has income and expense', () {
      expect(TransactionType.values, hasLength(2));
      expect(TransactionType.income, isA<TransactionType>());
      expect(TransactionType.expense, isA<TransactionType>());
    });
  });
}

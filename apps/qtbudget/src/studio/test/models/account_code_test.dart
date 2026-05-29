import 'package:flutter_test/flutter_test.dart';
import 'package:qtbudget/models/account_code.dart';

void main() {
  group('AccountCode', () {
    test('toJson / fromJson round-trip', () {
      final code = AccountCode(
        id: '1',
        code: 'A01',
        name: '办公费用',
        parentId: null,
        level: 1,
        type: AccountType.expense,
      );
      final json = code.toJson();
      final restored = AccountCode.fromJson(json);

      expect(restored.id, code.id);
      expect(restored.code, code.code);
      expect(restored.name, code.name);
      expect(restored.parentId, code.parentId);
      expect(restored.level, code.level);
      expect(restored.type, code.type);
    });

    test('fromJson handles missing optional fields', () {
      final json = {
        'id': '2',
        'code': 'B01',
        'name': '销售收入',
      };
      final code = AccountCode.fromJson(json);
      expect(code.id, '2');
      expect(code.code, 'B01');
      expect(code.name, '销售收入');
      expect(code.parentId, isNull);
      expect(code.level, 1);
      expect(code.type, AccountType.expense);
    });

    test('fromJson preserves all AccountType values', () {
      for (final type in AccountType.values) {
        final json = {
          'id': 'x',
          'code': 'X',
          'name': 'test',
          'type': type.name,
        };
        final code = AccountCode.fromJson(json);
        expect(code.type, type);
      }
    });

    test('income type serialization', () {
      final code = AccountCode(
        id: '5',
        code: 'B01',
        name: '销售收入',
        type: AccountType.income,
      );
      final json = code.toJson();
      expect(json['type'], 'income');
      final restored = AccountCode.fromJson(json);
      expect(restored.type, AccountType.income);
    });

    test('fromJson defaults type to expense when null', () {
      final json = {'id': 'x', 'code': 'X', 'name': 'test'};
      expect(AccountCode.fromJson(json).type, AccountType.expense);
    });
  });
}

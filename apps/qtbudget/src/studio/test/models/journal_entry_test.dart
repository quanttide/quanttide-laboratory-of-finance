import 'package:flutter_test/flutter_test.dart';
import 'package:qtbudget/models/journal_entry.dart';

void main() {
  group('JournalEntry', () {
    final now = DateTime(2026, 5, 29);

    test('toJson / fromJson round-trip for credit', () {
      final e = JournalEntry(
        id: 'e1', journalId: 'j1', description: '买书',
        debit: 0, credit: 200, date: now,
      );
      final json = e.toJson();
      final restored = JournalEntry.fromJson(json);

      expect(restored.id, e.id);
      expect(restored.journalId, e.journalId);
      expect(restored.description, e.description);
      expect(restored.debit, e.debit);
      expect(restored.credit, e.credit);
      expect(restored.date.toIso8601String(), e.date.toIso8601String());
      expect(restored.amount, -200);
    });

    test('toJson / fromJson round-trip for debit', () {
      final e = JournalEntry(
        id: 'e2', journalId: 'j1', description: '回款',
        debit: 5000, credit: 0, date: now,
      );
      expect(JournalEntry.fromJson(e.toJson()).amount, 5000);
    });

    test('fromJson defaults missing numeric fields to 0', () {
      final json = {
        'id': 'e3', 'journalId': 'j1',
        'description': 'test',
        'date': now.toIso8601String(),
      };
      final e = JournalEntry.fromJson(json);
      expect(e.debit, 0);
      expect(e.credit, 0);
      expect(e.description, 'test');
    });

    test('amount returns debit - credit', () {
      expect(JournalEntry(id: 'e1', journalId: 'j1', description: 'a', debit: 100, credit: 30, date: now).amount, 70);
      expect(JournalEntry(id: 'e2', journalId: 'j1', description: 'a', debit: 0, credit: 50, date: now).amount, -50);
    });

    test('assert rejects negative values', () {
      expect(
        () => JournalEntry(id: 'e1', journalId: 'j1', description: 'a', debit: -1, credit: 0, date: now),
        throwsAssertionError,
      );
    });
  });
}

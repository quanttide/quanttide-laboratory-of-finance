/// 日记账中的一笔流水。
///
/// debit = 借（资金流入），credit = 贷（资金流出）。不同时 > 0。
class JournalEntry {
  final String id;
  final String journalId;
  String description;
  double debit;
  double credit;
  DateTime date;

  JournalEntry({
    required this.id,
    required this.journalId,
    required this.description,
    this.debit = 0,
    this.credit = 0,
    required this.date,
  }) : assert(debit >= 0 && credit >= 0);

  double get amount => debit - credit;

  Map<String, dynamic> toJson() => {
    'id': id,
    'journalId': journalId,
    'description': description,
    'debit': debit,
    'credit': credit,
    'date': date.toIso8601String(),
  };

  factory JournalEntry.fromJson(Map<String, dynamic> json) => JournalEntry(
    id: json['id'] as String,
    journalId: json['journalId'] as String,
    description: json['description'] as String? ?? '',
    debit: (json['debit'] as num?)?.toDouble() ?? 0,
    credit: (json['credit'] as num?)?.toDouble() ?? 0,
    date: DateTime.parse(json['date'] as String),
  );
}

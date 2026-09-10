import 'deadline_category.dart';

enum DeadlineStatus { unset, overdue, soon, ok }

/// Una voce di manutenzione per un veicolo.
///
/// L'utente può compilarla in due modi:
///  - inserendo direttamente la data di [expiryDate] (tipico di bollo e
///    assicurazione, che riportano la scadenza sul documento);
///  - inserendo [lastDoneDate], la data in cui la manutenzione è stata fatta:
///    in questo caso la scadenza viene calcolata aggiungendo
///    [intervalMonths] mesi.
///
/// Se sono presenti entrambe, [expiryDate] ha la precedenza: è un dato
/// certo, mentre quella calcolata è una stima.
class DeadlineEntry {
  final String categoryKey;
  DateTime? expiryDate;
  DateTime? lastDoneDate;
  int intervalMonths;

  DeadlineEntry({
    required this.categoryKey,
    this.expiryDate,
    this.lastDoneDate,
    int? intervalMonths,
  }) : intervalMonths = intervalMonths ??
            DeadlineCategory.byKey(categoryKey).defaultIntervalMonths;

  DeadlineCategory get category => DeadlineCategory.byKey(categoryKey);

  /// True se la scadenza mostrata è stata calcolata e non inserita a mano.
  bool get isEstimated => expiryDate == null && lastDoneDate != null;

  /// La scadenza effettiva: quella inserita, oppure quella calcolata
  /// dall'ultima manutenzione.
  DateTime? get effectiveExpiry {
    if (expiryDate != null) return expiryDate;
    if (lastDoneDate != null) return addMonths(lastDoneDate!, intervalMonths);
    return null;
  }

  int? get daysLeft {
    final expiry = effectiveExpiry;
    if (expiry == null) return null;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return DateTime(expiry.year, expiry.month, expiry.day)
        .difference(today)
        .inDays;
  }

  DeadlineStatus get status {
    final days = daysLeft;
    if (days == null) return DeadlineStatus.unset;
    if (days < 0) return DeadlineStatus.overdue;
    if (days <= 30) return DeadlineStatus.soon;
    return DeadlineStatus.ok;
  }

  String get statusLabel {
    final days = daysLeft;
    switch (status) {
      case DeadlineStatus.unset:
        return 'da impostare';
      case DeadlineStatus.overdue:
        return days == -1 ? 'scaduto ieri' : 'scaduto da ${days!.abs()}g';
      case DeadlineStatus.soon:
        return days == 0 ? 'scade oggi' : 'tra ${days}g';
      case DeadlineStatus.ok:
        return 'tra ${days}g';
    }
  }

  /// Registra che la manutenzione è appena stata fatta: azzera la scadenza
  /// inserita a mano e fa ripartire il conteggio da [date].
  void markAsDone(DateTime date) {
    lastDoneDate = date;
    expiryDate = null;
  }

  Map<String, dynamic> toJson() => {
        'categoryKey': categoryKey,
        'expiryDate': expiryDate?.toIso8601String(),
        'lastDoneDate': lastDoneDate?.toIso8601String(),
        'intervalMonths': intervalMonths,
      };

  factory DeadlineEntry.fromJson(Map<String, dynamic> json) => DeadlineEntry(
        categoryKey: json['categoryKey'] as String,
        expiryDate: json['expiryDate'] != null
            ? DateTime.parse(json['expiryDate'] as String)
            : null,
        lastDoneDate: json['lastDoneDate'] != null
            ? DateTime.parse(json['lastDoneDate'] as String)
            : null,
        intervalMonths: json['intervalMonths'] as int?,
      );
}

/// Aggiunge [months] mesi a [date] gestendo i mesi più corti: il 31 gennaio
/// più un mese diventa il 28 (o 29) febbraio, non il 3 marzo.
DateTime addMonths(DateTime date, int months) {
  final totalMonths = date.month - 1 + months;
  final year = date.year + totalMonths ~/ 12;
  final month = totalMonths % 12 + 1;
  final lastDayOfMonth = DateTime(year, month + 1, 0).day;
  final day = date.day > lastDayOfMonth ? lastDayOfMonth : date.day;
  return DateTime(year, month, day);
}

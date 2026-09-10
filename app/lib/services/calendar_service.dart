import 'package:add_2_calendar/add_2_calendar.dart';
import '../models/vehicle.dart';
import '../models/deadline_entry.dart';

/// Apre direttamente l'app calendario del telefono (Google Calendar su
/// Android, Calendario su iOS) con l'evento già compilato: all'utente resta
/// solo da confermare. Non viene scaricato nessun file.
class CalendarService {
  /// Aggiunge la scadenza al calendario con un promemoria [reminderDays]
  /// giorni prima.
  void addDeadline({
    required Vehicle vehicle,
    required DeadlineEntry entry,
    int reminderDays = 7,
  }) {
    final expiry = entry.effectiveExpiry;
    if (expiry == null) return;

    final label = entry.category.label;
    final plate = vehicle.plate.isNotEmpty ? ' (${vehicle.plate})' : '';
    final estimated = entry.isEstimated
        ? '\n\nData stimata in base all\'ultima manutenzione.'
        : '';

    final event = Event(
      title: '$label — ${vehicle.name}',
      description: 'Scadenza $label per ${vehicle.name}$plate.$estimated',
      startDate: DateTime(expiry.year, expiry.month, expiry.day, 9),
      endDate: DateTime(expiry.year, expiry.month, expiry.day, 9, 30),
      reminders: [Duration(days: reminderDays)],
    );

    Add2Calendar.addEvent2Cal(event);
  }
}

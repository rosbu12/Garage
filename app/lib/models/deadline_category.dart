import 'package:flutter/material.dart';

/// Le quattro categorie di manutenzione tracciate dall'app.
///
/// [defaultIntervalMonths] è ogni quanti mesi la scadenza si ripete: serve a
/// calcolare la prossima scadenza a partire dalla data in cui la manutenzione
/// è stata fatta l'ultima volta. L'utente può modificarlo per ogni veicolo.
///
/// [knownExpiry] indica se di norma la data di scadenza è già nota all'utente
/// (bollo e assicurazione sono scritti sul certificato) oppure va calcolata a
/// partire dall'ultima volta che si è fatta (tagliando, gomme). Serve solo a
/// decidere quale campo mostrare per primo nel form.
class DeadlineCategory {
  final String key;
  final String label;
  final IconData icon;
  final int defaultIntervalMonths;
  final bool knownExpiry;

  const DeadlineCategory({
    required this.key,
    required this.label,
    required this.icon,
    required this.defaultIntervalMonths,
    required this.knownExpiry,
  });

  static const bollo = DeadlineCategory(
    key: 'bollo',
    label: 'Bollo',
    icon: Icons.receipt_long_outlined,
    defaultIntervalMonths: 12,
    knownExpiry: true,
  );

  static const assicurazione = DeadlineCategory(
    key: 'assicurazione',
    label: 'Assicurazione',
    icon: Icons.verified_user_outlined,
    defaultIntervalMonths: 12,
    knownExpiry: true,
  );

  static const tagliando = DeadlineCategory(
    key: 'tagliando',
    label: 'Tagliando',
    icon: Icons.build_outlined,
    defaultIntervalMonths: 12,
    knownExpiry: false,
  );

  static const gomme = DeadlineCategory(
    key: 'gomme',
    label: 'Inversione gomme',
    icon: Icons.trip_origin,
    defaultIntervalMonths: 6,
    knownExpiry: false,
  );

  static const List<DeadlineCategory> all = [
    bollo,
    assicurazione,
    tagliando,
    gomme,
  ];

  static DeadlineCategory byKey(String key) =>
      all.firstWhere((c) => c.key == key, orElse: () => bollo);
}

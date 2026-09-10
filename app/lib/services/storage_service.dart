import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/vehicle.dart';
import '../models/deadline_entry.dart';

/// Salva veicoli e scadenze sul dispositivo.
///
/// Le scadenze sono indicizzate per id del veicolo e poi per categoria:
/// { vehicleId: { categoryKey: DeadlineEntry } }
class StorageService {
  static const _vehiclesKey = 'vehicles';
  static const _deadlinesKey = 'deadlines_v2';

  Future<List<Vehicle>> loadVehicles() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_vehiclesKey);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List;
    return list
        .map((e) => Vehicle.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveVehicles(List<Vehicle> vehicles) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _vehiclesKey,
      jsonEncode(vehicles.map((v) => v.toJson()).toList()),
    );
  }

  Future<Map<String, Map<String, DeadlineEntry>>> loadDeadlines() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_deadlinesKey);
    if (raw == null) return {};
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    return decoded.map((vehicleId, categories) {
      final entries = (categories as Map<String, dynamic>).map(
        (categoryKey, entry) => MapEntry(
          categoryKey,
          DeadlineEntry.fromJson(entry as Map<String, dynamic>),
        ),
      );
      return MapEntry(vehicleId, entries);
    });
  }

  Future<void> saveDeadlines(
    Map<String, Map<String, DeadlineEntry>> deadlines,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final encodable = deadlines.map(
      (vehicleId, categories) => MapEntry(
        vehicleId,
        categories.map((key, entry) => MapEntry(key, entry.toJson())),
      ),
    );
    await prefs.setString(_deadlinesKey, jsonEncode(encodable));
  }
}

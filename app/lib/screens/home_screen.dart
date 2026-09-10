import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/vehicle.dart';
import '../models/deadline_category.dart';
import '../models/deadline_entry.dart';
import '../services/storage_service.dart';
import '../services/calendar_service.dart';
import '../theme/app_theme.dart';
import '../widgets/vehicle_selector.dart';
import '../widgets/deadline_card.dart';
import '../widgets/deadline_editor_sheet.dart';
import '../widgets/vehicle_editor_sheet.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _storage = StorageService();
  final _calendar = CalendarService();
  final _uuid = const Uuid();

  List<Vehicle> _vehicles = [];
  Map<String, Map<String, DeadlineEntry>> _deadlines = {};
  String? _activeVehicleId;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final vehicles = await _storage.loadVehicles();
    final deadlines = await _storage.loadDeadlines();
    setState(() {
      _vehicles = vehicles;
      _deadlines = deadlines;
      _activeVehicleId = vehicles.isNotEmpty ? vehicles.first.id : null;
      _loading = false;
    });
  }

  Map<String, DeadlineEntry> _entriesFor(String vehicleId) {
    final existing = _deadlines[vehicleId] ?? {};
    for (final category in DeadlineCategory.all) {
      existing.putIfAbsent(
        category.key,
        () => DeadlineEntry(categoryKey: category.key),
      );
    }
    _deadlines[vehicleId] = existing;
    return existing;
  }

  Future<void> _persist() async {
    await _storage.saveVehicles(_vehicles);
    await _storage.saveDeadlines(_deadlines);
  }

  Future<void> _openVehicleEditor({Vehicle? existing}) async {
    final result = await showModalBottomSheet<VehicleEditorResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => VehicleEditorSheet(
        existing: existing,
        canDelete: _vehicles.length > 1,
      ),
    );
    if (result == null) return;

    if (result.deleted && existing != null) {
      setState(() {
        _vehicles.removeWhere((v) => v.id == existing.id);
        _deadlines.remove(existing.id);
        if (_activeVehicleId == existing.id) {
          _activeVehicleId = _vehicles.isNotEmpty ? _vehicles.first.id : null;
        }
      });
      await _persist();
      return;
    }

    final vehicle = result.vehicle;
    if (vehicle == null) return;

    if (existing == null) {
      final created =
          Vehicle(id: _uuid.v4(), name: vehicle.name, plate: vehicle.plate);
      setState(() {
        _vehicles.add(created);
        _activeVehicleId = created.id;
      });
    } else {
      setState(() {});
    }
    await _persist();
  }

  Future<void> _openDeadlineEditor(DeadlineEntry entry) async {
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => DeadlineEditorSheet(entry: entry),
    );
    if (saved == true) {
      setState(() {});
      await _persist();
    }
  }

  Future<void> _markDone(DeadlineEntry entry) async {
    final now = DateTime.now();
    setState(() => entry.markAsDone(DateTime(now.year, now.month, now.day)));
    await _persist();
    if (!mounted) return;
    final next = entry.effectiveExpiry;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.ink,
        behavior: SnackBarBehavior.floating,
        content: Text(
          next != null
              ? '${entry.category.label} aggiornato. Prossima scadenza calcolata.'
              : '${entry.category.label} aggiornato.',
          style: const TextStyle(fontSize: 13.5),
        ),
      ),
    );
  }

  int get _urgentCount {
    if (_activeVehicleId == null) return 0;
    return _entriesFor(_activeVehicleId!)
        .values
        .where((e) =>
            e.status == DeadlineStatus.overdue || e.status == DeadlineStatus.soon)
        .length;
  }

  String get _subtitle {
    final count = _vehicles.length;
    final vehicleLabel = count == 1 ? '1 veicolo' : '$count veicoli';
    final urgent = _urgentCount;
    if (urgent == 0) return '$vehicleLabel · tutto in regola';
    return '$vehicleLabel · $urgent ${urgent == 1 ? "scadenza" : "scadenze"} da seguire';
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 20, 18, 40),
          children: [
            Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: AppColors.brand,
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: const Icon(Icons.garage_outlined,
                      size: 21, color: Colors.white),
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Garage',
                        style: TextStyle(
                            fontSize: 22, fontWeight: FontWeight.w600),
                      ),
                      Text(
                        _subtitle,
                        style: const TextStyle(
                            fontSize: 12.5, color: AppColors.inkSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            VehicleSelector(
              vehicles: _vehicles,
              activeVehicleId: _activeVehicleId,
              onSelect: (id) => setState(() => _activeVehicleId = id),
              onEdit: (vehicle) => _openVehicleEditor(existing: vehicle),
              onAdd: () => _openVehicleEditor(),
            ),
            const SizedBox(height: 18),
            if (_activeVehicleId == null)
              _EmptyState(onAdd: () => _openVehicleEditor())
            else
              ..._entriesFor(_activeVehicleId!).values.map(
                    (entry) => DeadlineCard(
                      entry: entry,
                      onEdit: () => _openDeadlineEditor(entry),
                      onAddToCalendar: () {
                        final vehicle = _vehicles
                            .firstWhere((v) => v.id == _activeVehicleId);
                        _calendar.addDeadline(vehicle: vehicle, entry: entry);
                      },
                      onMarkDone: () => _markDone(entry),
                    ),
                  ),
            if (_activeVehicleId != null) ...[
              const SizedBox(height: 6),
              const Text(
                'Tocca una scheda per impostarla. Tieni premuto su un veicolo per modificarlo.',
                style: TextStyle(fontSize: 12, color: AppColors.inkMuted),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onAdd;

  const _EmptyState({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 44, horizontal: 24),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.hairline),
      ),
      child: Column(
        children: [
          const Icon(Icons.directions_car_outlined,
              size: 34, color: AppColors.inkMuted),
          const SizedBox(height: 14),
          const Text(
            'Aggiungi il primo veicolo',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          const Text(
            'Da qui terrai traccia di bollo, assicurazione, tagliando e gomme.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: AppColors.inkSecondary),
          ),
          const SizedBox(height: 18),
          FilledButton(
            onPressed: onAdd,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.ink,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 13),
            ),
            child: const Text('Aggiungi veicolo'),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../models/vehicle.dart';
import '../theme/app_theme.dart';

/// Riga orizzontale di chip, uno per veicolo, più il pulsante di aggiunta.
/// Un tocco seleziona il veicolo, un tocco prolungato ne apre la modifica.
class VehicleSelector extends StatelessWidget {
  final List<Vehicle> vehicles;
  final String? activeVehicleId;
  final ValueChanged<String> onSelect;
  final ValueChanged<Vehicle> onEdit;
  final VoidCallback onAdd;

  const VehicleSelector({
    super.key,
    required this.vehicles,
    required this.activeVehicleId,
    required this.onSelect,
    required this.onEdit,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 42,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          for (final vehicle in vehicles) ...[
            _VehicleChip(
              vehicle: vehicle,
              selected: vehicle.id == activeVehicleId,
              onTap: () => onSelect(vehicle.id),
              onLongPress: () => onEdit(vehicle),
            ),
            const SizedBox(width: 8),
          ],
          _AddChip(onTap: onAdd),
        ],
      ),
    );
  }
}

class _VehicleChip extends StatelessWidget {
  final Vehicle vehicle;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const _VehicleChip({
    required this.vehicle,
    required this.selected,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? AppColors.card : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? AppColors.ink : AppColors.hairline,
            width: selected ? 1.2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.directions_car_outlined,
              size: 16,
              color: selected ? AppColors.ink : AppColors.inkSecondary,
            ),
            const SizedBox(width: 7),
            Text(
              vehicle.name,
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                color: selected ? AppColors.ink : AppColors.inkSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddChip extends StatelessWidget {
  final VoidCallback onTap;

  const _AddChip({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        width: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: AppColors.hairline),
        ),
        child: const Icon(Icons.add, size: 18, color: AppColors.inkSecondary),
      ),
    );
  }
}

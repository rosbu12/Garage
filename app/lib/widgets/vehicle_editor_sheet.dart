import 'package:flutter/material.dart';
import '../models/vehicle.dart';
import '../theme/app_theme.dart';

/// Risultato restituito dal pannello veicolo.
class VehicleEditorResult {
  final Vehicle? vehicle;
  final bool deleted;

  const VehicleEditorResult({this.vehicle, this.deleted = false});
}

/// Pannello per creare un nuovo veicolo o modificarne uno esistente.
/// Passando [existing] il form si apre precompilato e compare l'opzione
/// di eliminazione.
class VehicleEditorSheet extends StatefulWidget {
  final Vehicle? existing;
  final bool canDelete;

  const VehicleEditorSheet({super.key, this.existing, this.canDelete = true});

  @override
  State<VehicleEditorSheet> createState() => _VehicleEditorSheetState();
}

class _VehicleEditorSheetState extends State<VehicleEditorSheet> {
  late final TextEditingController _nameController;
  late final TextEditingController _plateController;
  String? _error;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.existing?.name ?? '');
    _plateController = TextEditingController(text: widget.existing?.plate ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _plateController.dispose();
    super.dispose();
  }

  void _save() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _error = 'Inserisci un nome per il veicolo');
      return;
    }
    final plate = _plateController.text.trim();
    final vehicle = widget.existing;
    if (vehicle != null) {
      vehicle.name = name;
      vehicle.plate = plate;
      Navigator.of(context).pop(VehicleEditorResult(vehicle: vehicle));
    } else {
      Navigator.of(context).pop(
        VehicleEditorResult(
          vehicle: Vehicle(id: '', name: name, plate: plate),
        ),
      );
    }
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.card,
        title: const Text('Eliminare il veicolo?'),
        content: const Text(
          'Verranno rimosse anche tutte le sue scadenze.',
          style: TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annulla'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: const Color(0xFFB3261E)),
            child: const Text('Elimina'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      Navigator.of(context).pop(const VehicleEditorResult(deleted: true));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _isEditing ? 'Modifica veicolo' : 'Nuovo veicolo',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 18),
          const Text('Nome',
              style: TextStyle(fontSize: 13, color: AppColors.inkSecondary)),
          const SizedBox(height: 8),
          TextField(
            controller: _nameController,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(hintText: 'es. Citroen C1'),
            onChanged: (_) {
              if (_error != null) setState(() => _error = null);
            },
          ),
          const SizedBox(height: 16),
          const Text('Targa (facoltativa)',
              style: TextStyle(fontSize: 13, color: AppColors.inkSecondary)),
          const SizedBox(height: 8),
          TextField(
            controller: _plateController,
            textCapitalization: TextCapitalization.characters,
            decoration: const InputDecoration(hintText: 'es. AB123CD'),
          ),
          if (_error != null) ...[
            const SizedBox(height: 10),
            Text(
              _error!,
              style: const TextStyle(fontSize: 13, color: Color(0xFFB3261E)),
            ),
          ],
          const SizedBox(height: 24),
          Row(
            children: [
              if (_isEditing && widget.canDelete)
                TextButton.icon(
                  onPressed: _confirmDelete,
                  icon: const Icon(Icons.delete_outline, size: 18),
                  label: const Text('Elimina'),
                  style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFFB3261E)),
                ),
              const Spacer(),
              FilledButton(
                onPressed: _save,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.ink,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 26, vertical: 13),
                ),
                child: const Text('Salva'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

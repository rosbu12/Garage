import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/deadline_entry.dart';
import '../theme/app_theme.dart';

/// Pannello che si apre dal basso per compilare una scadenza.
///
/// Due modi alternativi di inserimento:
///  - "So la scadenza": si inserisce direttamente la data.
///  - "L'ho fatto il...": si inserisce la data dell'ultima manutenzione e
///    l'app calcola la prossima scadenza aggiungendo l'intervallo scelto.
class DeadlineEditorSheet extends StatefulWidget {
  final DeadlineEntry entry;

  const DeadlineEditorSheet({super.key, required this.entry});

  @override
  State<DeadlineEditorSheet> createState() => _DeadlineEditorSheetState();
}

class _DeadlineEditorSheetState extends State<DeadlineEditorSheet> {
  late bool _byExpiry;
  late DateTime? _expiryDate;
  late DateTime? _lastDoneDate;
  late int _intervalMonths;

  static const _intervalOptions = [3, 6, 12, 24];

  @override
  void initState() {
    super.initState();
    final entry = widget.entry;
    _expiryDate = entry.expiryDate;
    _lastDoneDate = entry.lastDoneDate;
    _intervalMonths = entry.intervalMonths;
    // Se l'utente ha già compilato qualcosa, riapri nella stessa modalità;
    // altrimenti scegli quella più naturale per la categoria.
    if (entry.expiryDate != null) {
      _byExpiry = true;
    } else if (entry.lastDoneDate != null) {
      _byExpiry = false;
    } else {
      _byExpiry = entry.category.knownExpiry;
    }
  }

  DateTime? get _computedExpiry {
    if (_byExpiry) return _expiryDate;
    if (_lastDoneDate == null) return null;
    return addMonths(_lastDoneDate!, _intervalMonths);
  }

  Future<void> _pickDate({required bool isExpiry}) async {
    final now = DateTime.now();
    final initial = (isExpiry ? _expiryDate : _lastDoneDate) ?? now;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(now.year - 10),
      lastDate: DateTime(now.year + 10),
      locale: const Locale('it', 'IT'),
    );
    if (picked == null) return;
    setState(() {
      if (isExpiry) {
        _expiryDate = picked;
      } else {
        _lastDoneDate = picked;
      }
    });
  }

  void _save() {
    final entry = widget.entry;
    if (_byExpiry) {
      entry.expiryDate = _expiryDate;
      entry.lastDoneDate = null;
    } else {
      entry.expiryDate = null;
      entry.lastDoneDate = _lastDoneDate;
      entry.intervalMonths = _intervalMonths;
    }
    Navigator.of(context).pop(true);
  }

  void _clear() {
    final entry = widget.entry;
    entry.expiryDate = null;
    entry.lastDoneDate = null;
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('d MMMM yyyy', 'it_IT');
    final computed = _computedExpiry;

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
          Row(
            children: [
              Icon(widget.entry.category.icon, size: 20, color: AppColors.ink),
              const SizedBox(width: 10),
              Text(
                widget.entry.category.label,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 18),
          SegmentedButton<bool>(
            segments: const [
              ButtonSegment(value: true, label: Text('So la scadenza')),
              ButtonSegment(value: false, label: Text("L'ho fatto il…")),
            ],
            selected: {_byExpiry},
            onSelectionChanged: (s) => setState(() => _byExpiry = s.first),
            style: ButtonStyle(
              textStyle: WidgetStateProperty.all(const TextStyle(fontSize: 13)),
            ),
          ),
          const SizedBox(height: 18),
          if (_byExpiry) ...[
            _DateRow(
              label: 'Data di scadenza',
              value: _expiryDate != null
                  ? dateFormat.format(_expiryDate!)
                  : 'tocca per scegliere',
              isSet: _expiryDate != null,
              onTap: () => _pickDate(isExpiry: true),
            ),
          ] else ...[
            _DateRow(
              label: 'Fatto il',
              value: _lastDoneDate != null
                  ? dateFormat.format(_lastDoneDate!)
                  : 'tocca per scegliere',
              isSet: _lastDoneDate != null,
              onTap: () => _pickDate(isExpiry: false),
            ),
            const SizedBox(height: 16),
            const Text(
              'Si ripete ogni',
              style: TextStyle(fontSize: 13, color: AppColors.inkSecondary),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                for (final months in _intervalOptions)
                  ChoiceChip(
                    label: Text(
                      months == 12
                          ? '1 anno'
                          : months == 24
                              ? '2 anni'
                              : '$months mesi',
                      style: const TextStyle(fontSize: 13),
                    ),
                    selected: _intervalMonths == months,
                    onSelected: (_) => setState(() => _intervalMonths = months),
                  ),
              ],
            ),
            if (computed != null) ...[
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(13),
                decoration: BoxDecoration(
                  color: AppColors.unsetTint,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.auto_awesome_outlined,
                        size: 16, color: AppColors.inkSecondary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Prossima scadenza: ${dateFormat.format(computed)}',
                        style: const TextStyle(
                            fontSize: 13, color: AppColors.inkSecondary),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
          const SizedBox(height: 24),
          Row(
            children: [
              TextButton(
                onPressed: _clear,
                style: TextButton.styleFrom(foregroundColor: AppColors.inkMuted),
                child: const Text('Svuota'),
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

class _DateRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isSet;
  final VoidCallback onTap;

  const _DateRow({
    required this.label,
    required this.value,
    required this.isSet,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 13, color: AppColors.inkSecondary)),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.hairline),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today_outlined,
                    size: 17, color: AppColors.inkSecondary),
                const SizedBox(width: 10),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14.5,
                    color: isSet ? AppColors.ink : AppColors.inkMuted,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

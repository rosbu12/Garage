import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/deadline_entry.dart';
import '../theme/app_theme.dart';

/// Scheda di una scadenza. Il colore di fondo comunica lo stato; il testo
/// resta scuro per restare leggibile su qualsiasi tinta.
class DeadlineCard extends StatelessWidget {
  final DeadlineEntry entry;
  final VoidCallback onEdit;
  final VoidCallback onAddToCalendar;
  final VoidCallback onMarkDone;

  const DeadlineCard({
    super.key,
    required this.entry,
    required this.onEdit,
    required this.onAddToCalendar,
    required this.onMarkDone,
  });

  @override
  Widget build(BuildContext context) {
    final status = entry.status;
    final expiry = entry.effectiveExpiry;
    final dateFormat = DateFormat('d MMM yyyy', 'it_IT');
    final hasDate = expiry != null;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.tintFor(status),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onEdit,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 13, 14, 13),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppColors.strongFor(status),
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: Icon(entry.category.icon,
                          size: 17, color: AppColors.ink),
                    ),
                    const SizedBox(width: 11),
                    Expanded(
                      child: Text(
                        entry.category.label,
                        style: const TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.ink,
                        ),
                      ),
                    ),
                    Text(
                      entry.statusLabel,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: status == DeadlineStatus.unset
                            ? FontWeight.w400
                            : FontWeight.w600,
                        color: status == DeadlineStatus.unset
                            ? AppColors.inkMuted
                            : AppColors.ink,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 11),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Flexible(
                            child: Text(
                              hasDate ? dateFormat.format(expiry) : 'imposta data',
                              style: TextStyle(
                                fontSize: 12.5,
                                color: hasDate
                                    ? AppColors.inkSecondary
                                    : AppColors.inkMuted,
                              ),
                            ),
                          ),
                          if (entry.isEstimated) ...[
                            const SizedBox(width: 6),
                            const Icon(Icons.auto_awesome_outlined,
                                size: 13, color: AppColors.inkMuted),
                            const SizedBox(width: 3),
                            const Text(
                              'stimata',
                              style: TextStyle(
                                  fontSize: 11.5, color: AppColors.inkMuted),
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (hasDate) ...[
                      _IconAction(
                        icon: Icons.check_circle_outline,
                        tooltip: 'Segna come fatto oggi',
                        onTap: onMarkDone,
                      ),
                      const SizedBox(width: 4),
                      _IconAction(
                        icon: Icons.event_available_outlined,
                        tooltip: 'Aggiungi al calendario',
                        onTap: onAddToCalendar,
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _IconAction extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  const _IconAction({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(icon, size: 19, color: AppColors.ink),
        ),
      ),
    );
  }
}

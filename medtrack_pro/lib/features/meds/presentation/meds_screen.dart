import 'package:flutter/material.dart';

import '../../../core/models/prescription.dart';
import '../application/meds_controller.dart';
import '../application/meds_state.dart';

class MedsScreen extends StatefulWidget {
  const MedsScreen({super.key, this.controller});

  final MedsController? controller;

  @override
  State<MedsScreen> createState() => _MedsScreenState();
}

class _MedsScreenState extends State<MedsScreen> {
  late final MedsController _controller;
  late final bool _ownsController;

  @override
  void initState() {
    super.initState();
    _ownsController = widget.controller == null;
    _controller = widget.controller ?? MedsController();
  }

  @override
  void dispose() {
    if (_ownsController) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (BuildContext context, Widget? child) {
        final MedsState state = _controller.state;

        return ListView(
          padding: const EdgeInsets.all(20),
          children: <Widget>[
            _ScreenHeader(state: state),
            const SizedBox(height: 20),
            ...state.sortedPrescriptions.map(
              (Prescription prescription) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _PrescriptionCard(
                  prescription: prescription,
                  onChanged: (bool value) =>
                      _controller.setPrescriptionActive(prescription.id, value),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ScreenHeader extends StatelessWidget {
  const _ScreenHeader({required this.state});

  final MedsState state;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('Meds', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 12),
        Text(
          'Local prescription list for the demo. Switching a prescription to inactive hides its doses from the Home timeline without regenerating the schedule.',
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(color: colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: <Widget>[
            _SummaryChip(
              label: '${state.activeCount} active',
              color: colorScheme.primaryContainer,
              foregroundColor: colorScheme.onPrimaryContainer,
            ),
            _SummaryChip(
              label: '${state.inactiveCount} inactive',
              color: colorScheme.surfaceContainerHighest,
              foregroundColor: colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ],
    );
  }
}

class _SummaryChip extends StatelessWidget {
  const _SummaryChip({
    required this.label,
    required this.color,
    required this.foregroundColor,
  });

  final String label;
  final Color color;
  final Color foregroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: foregroundColor,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _PrescriptionCard extends StatelessWidget {
  const _PrescriptionCard({
    required this.prescription,
    required this.onChanged,
  });

  final Prescription prescription;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final bool active = prescription.active;

    return Card(
      key: Key('prescription-card-${prescription.id}'),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        prescription.drugName,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        prescription.dose,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        prescription.commonFrequency,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                _StatusBadge(active: active),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    active
                        ? 'Included on Home today'
                        : 'Hidden from Home today',
                    key: Key('prescription-status-${prescription.id}'),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                Switch(
                  key: Key('prescription-toggle-${prescription.id}'),
                  value: active,
                  onChanged: onChanged,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.active});

  final bool active;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final Color backgroundColor = active
        ? colorScheme.primaryContainer
        : colorScheme.surfaceContainerHighest;
    final Color foregroundColor = active
        ? colorScheme.onPrimaryContainer
        : colorScheme.onSurfaceVariant;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        active ? 'Active' : 'Inactive',
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: foregroundColor,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

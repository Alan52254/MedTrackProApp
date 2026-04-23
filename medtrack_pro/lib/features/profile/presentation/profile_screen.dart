import 'package:flutter/material.dart';

import '../application/profile_controller.dart';
import '../application/profile_state.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, this.controller});

  final ProfileController? controller;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final ProfileController _controller;
  late final bool _ownsController;

  late final TextEditingController _fullNameController;
  late final TextEditingController _patientCodeController;
  late final TextEditingController _ageController;
  late final TextEditingController _occupationController;
  late final TextEditingController _comorbidityCountController;
  late final TextEditingController _diseaseListController;
  late final TextEditingController _caregiverNameController;
  late final TextEditingController _caregiverPhoneController;

  @override
  void initState() {
    super.initState();
    _ownsController = widget.controller == null;
    _controller = widget.controller ?? ProfileController();
    final ProfileFormData form = _controller.state.form;
    _fullNameController = TextEditingController(text: form.fullName);
    _patientCodeController = TextEditingController(text: form.patientCode);
    _ageController = TextEditingController(text: form.age);
    _occupationController = TextEditingController(text: form.occupation);
    _comorbidityCountController = TextEditingController(
      text: form.comorbidityCount,
    );
    _diseaseListController = TextEditingController(text: form.diseaseList);
    _caregiverNameController = TextEditingController(text: form.caregiverName);
    _caregiverPhoneController = TextEditingController(
      text: form.caregiverPhone,
    );
    _controller.addListener(_syncControllers);
  }

  @override
  void dispose() {
    _controller.removeListener(_syncControllers);
    _fullNameController.dispose();
    _patientCodeController.dispose();
    _ageController.dispose();
    _occupationController.dispose();
    _comorbidityCountController.dispose();
    _diseaseListController.dispose();
    _caregiverNameController.dispose();
    _caregiverPhoneController.dispose();
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
        final ProfileState state = _controller.state;

        return ListView(
          padding: const EdgeInsets.all(20),
          children: <Widget>[
            _ProfileHeader(state: state),
            const SizedBox(height: 20),
            _SectionCard(
              title: 'Basic Information',
              children: <Widget>[
                _LabeledField(
                  label: 'Full name',
                  child: TextField(
                    key: const Key('profile-full-name-field'),
                    controller: _fullNameController,
                    onChanged: _controller.updateFullName,
                    decoration: const InputDecoration(
                      hintText: 'Enter full name',
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _LabeledField(
                  label: 'Patient code',
                  child: TextField(
                    key: const Key('profile-patient-code-field'),
                    controller: _patientCodeController,
                    onChanged: _controller.updatePatientCode,
                    decoration: const InputDecoration(
                      hintText: 'Enter patient code',
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _LabeledField(
                  label: 'Gender',
                  child: DropdownButtonFormField<String>(
                    key: const Key('profile-gender-field'),
                    initialValue: state.form.gender,
                    items: const <DropdownMenuItem<String>>[
                      DropdownMenuItem<String>(
                        value: 'Male',
                        child: Text('Male'),
                      ),
                      DropdownMenuItem<String>(
                        value: 'Female',
                        child: Text('Female'),
                      ),
                      DropdownMenuItem<String>(
                        value: 'Other',
                        child: Text('Other'),
                      ),
                    ],
                    onChanged: (String? value) {
                      if (value != null) {
                        _controller.updateGender(value);
                      }
                    },
                  ),
                ),
                const SizedBox(height: 16),
                _LabeledField(
                  label: 'Age',
                  child: TextField(
                    key: const Key('profile-age-field'),
                    controller: _ageController,
                    keyboardType: TextInputType.number,
                    onChanged: _controller.updateAge,
                    decoration: const InputDecoration(hintText: 'Enter age'),
                  ),
                ),
                const SizedBox(height: 16),
                _LabeledField(
                  label: 'Occupation',
                  child: TextField(
                    key: const Key('profile-occupation-field'),
                    controller: _occupationController,
                    onChanged: _controller.updateOccupation,
                    decoration: const InputDecoration(
                      hintText: 'Enter occupation',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _SectionCard(
              title: 'Medical and Routine',
              children: <Widget>[
                _LabeledField(
                  label: 'Comorbidity count',
                  child: TextField(
                    key: const Key('profile-comorbidity-count-field'),
                    controller: _comorbidityCountController,
                    keyboardType: TextInputType.number,
                    onChanged: _controller.updateComorbidityCount,
                    decoration: const InputDecoration(
                      hintText: 'Enter comorbidity count',
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  key: const Key('profile-has-comorbidity-switch'),
                  value: state.form.hasComorbidity,
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Has comorbidity'),
                  subtitle: const Text(
                    'Enable disease list editing for the local demo.',
                  ),
                  onChanged: _controller.updateHasComorbidity,
                ),
                if (state.form.hasComorbidity) ...<Widget>[
                  _LabeledField(
                    label: 'Disease list',
                    child: TextField(
                      key: const Key('profile-disease-list-field'),
                      controller: _diseaseListController,
                      onChanged: _controller.updateDiseaseList,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        hintText: 'Comma-separated conditions',
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                _TimeFieldRow(
                  label: 'Wake time',
                  value: state.form.wakeTime,
                  fieldKey: const Key('profile-wake-time-field'),
                  onTap: () => _pickTime(
                    initialValue: state.form.wakeTime,
                    onSelected: _controller.updateWakeTime,
                  ),
                ),
                const SizedBox(height: 12),
                _TimeFieldRow(
                  label: 'Breakfast time',
                  value: state.form.breakfastTime,
                  fieldKey: const Key('profile-breakfast-time-field'),
                  onTap: () => _pickTime(
                    initialValue: state.form.breakfastTime,
                    onSelected: _controller.updateBreakfastTime,
                  ),
                ),
                const SizedBox(height: 12),
                _TimeFieldRow(
                  label: 'Lunch time',
                  value: state.form.lunchTime,
                  fieldKey: const Key('profile-lunch-time-field'),
                  onTap: () => _pickTime(
                    initialValue: state.form.lunchTime,
                    onSelected: _controller.updateLunchTime,
                  ),
                ),
                const SizedBox(height: 12),
                _TimeFieldRow(
                  label: 'Dinner time',
                  value: state.form.dinnerTime,
                  fieldKey: const Key('profile-dinner-time-field'),
                  onTap: () => _pickTime(
                    initialValue: state.form.dinnerTime,
                    onSelected: _controller.updateDinnerTime,
                  ),
                ),
                const SizedBox(height: 12),
                _TimeFieldRow(
                  label: 'Sleep time',
                  value: state.form.sleepTime,
                  fieldKey: const Key('profile-sleep-time-field'),
                  onTap: () => _pickTime(
                    initialValue: state.form.sleepTime,
                    onSelected: _controller.updateSleepTime,
                  ),
                ),
                if (state.showWakeTimeNote) ...<Widget>[
                  const SizedBox(height: 16),
                  _InfoNote(
                    key: const Key('profile-wake-time-note'),
                    text:
                        'Wake time changed. Schedule recalculation will be added in a later phase.',
                  ),
                ],
              ],
            ),
            const SizedBox(height: 16),
            _SectionCard(
              title: 'Caregiver',
              children: <Widget>[
                _LabeledField(
                  label: 'Caregiver name',
                  child: TextField(
                    key: const Key('profile-caregiver-name-field'),
                    controller: _caregiverNameController,
                    onChanged: _controller.updateCaregiverName,
                    decoration: const InputDecoration(
                      hintText: 'Enter caregiver name',
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _LabeledField(
                  label: 'Caregiver phone',
                  child: TextField(
                    key: const Key('profile-caregiver-phone-field'),
                    controller: _caregiverPhoneController,
                    onChanged: _controller.updateCaregiverPhone,
                    decoration: const InputDecoration(
                      hintText: 'Enter caregiver phone',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (state.saveMessage.isNotEmpty) ...<Widget>[
              _InfoNote(
                key: const Key('profile-save-message'),
                text: state.saveMessage,
              ),
              const SizedBox(height: 16),
            ],
            Row(
              children: <Widget>[
                Expanded(
                  child: OutlinedButton(
                    key: const Key('profile-reset-button'),
                    onPressed: _controller.resetForm,
                    child: const Text('Reset'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    key: const Key('profile-save-button'),
                    onPressed: _controller.save,
                    child: const Text('Save'),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Future<void> _pickTime({
    required String initialValue,
    required ValueChanged<String> onSelected,
  }) async {
    final TimeOfDay initialTime = _parseTime(initialValue);
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );

    if (picked == null) {
      return;
    }

    onSelected(_formatTime(picked));
  }

  void _syncControllers() {
    final ProfileFormData form = _controller.state.form;
    _syncTextController(_fullNameController, form.fullName);
    _syncTextController(_patientCodeController, form.patientCode);
    _syncTextController(_ageController, form.age);
    _syncTextController(_occupationController, form.occupation);
    _syncTextController(_comorbidityCountController, form.comorbidityCount);
    _syncTextController(_diseaseListController, form.diseaseList);
    _syncTextController(_caregiverNameController, form.caregiverName);
    _syncTextController(_caregiverPhoneController, form.caregiverPhone);
  }

  void _syncTextController(TextEditingController controller, String value) {
    if (controller.text == value) {
      return;
    }

    controller.value = TextEditingValue(
      text: value,
      selection: TextSelection.collapsed(offset: value.length),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.state});

  final ProfileState state;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final bool hasCaregiverContact =
        state.form.caregiverName.trim().isNotEmpty ||
        state.form.caregiverPhone.trim().isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('Profile', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 12),
        Text(
          'Edit the shared local demo profile. Save writes to app-level local state, and Reset restores the initial local seed state.',
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(color: colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: <Widget>[
            _HeaderChip(
              label: state.savedProfile.patientCode,
              icon: Icons.badge_rounded,
            ),
            _HeaderChip(
              label: hasCaregiverContact ? 'Caregiver enabled' : 'Self-managed',
              icon: Icons.support_agent_rounded,
            ),
          ],
        ),
      ],
    );
  }
}

class _HeaderChip extends StatelessWidget {
  const _HeaderChip({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 18, color: colorScheme.primary),
          const SizedBox(width: 8),
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _LabeledField extends StatelessWidget {
  const _LabeledField({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(label, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}

class _TimeFieldRow extends StatelessWidget {
  const _TimeFieldRow({
    required this.label,
    required this.value,
    required this.fieldKey,
    required this.onTap,
  });

  final String label;
  final String value;
  final Key fieldKey;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      key: fieldKey,
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          suffixIcon: const Icon(Icons.schedule_rounded),
        ),
        child: Text(value),
      ),
    );
  }
}

class _InfoNote extends StatelessWidget {
  const _InfoNote({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(
            Icons.info_outline_rounded,
            color: colorScheme.onPrimaryContainer,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onPrimaryContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

TimeOfDay _parseTime(String value) {
  final List<String> parts = value.split(':');
  final int hour = parts.length == 2 ? int.tryParse(parts[0]) ?? 0 : 0;
  final int minute = parts.length == 2 ? int.tryParse(parts[1]) ?? 0 : 0;
  return TimeOfDay(hour: hour, minute: minute);
}

String _formatTime(TimeOfDay value) {
  final String hour = value.hour.toString().padLeft(2, '0');
  final String minute = value.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
}

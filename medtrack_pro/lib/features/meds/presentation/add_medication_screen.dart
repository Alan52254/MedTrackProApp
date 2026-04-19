import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../application/add_medication_controller.dart';
import '../application/add_medication_state.dart';

class AddMedicationScreen extends StatefulWidget {
  const AddMedicationScreen({super.key, required this.controller});

  final AddMedicationController controller;

  @override
  State<AddMedicationScreen> createState() => _AddMedicationScreenState();
}

class _AddMedicationScreenState extends State<AddMedicationScreen> {
  final ImagePicker _imagePicker = ImagePicker();

  late final TextEditingController _drugNameController;
  late final TextEditingController _doseController;
  late final TextEditingController _durationDaysController;
  late final TextEditingController _indicationController;
  late final TextEditingController _drugInteractionsController;
  late final TextEditingController _noteController;

  @override
  void initState() {
    super.initState();
    final AddMedicationFormData form = widget.controller.state.form;
    _drugNameController = TextEditingController(text: form.drugName);
    _doseController = TextEditingController(text: form.dose);
    _durationDaysController = TextEditingController(text: form.durationDays);
    _indicationController = TextEditingController(text: form.indication);
    _drugInteractionsController = TextEditingController(
      text: form.drugInteractions,
    );
    _noteController = TextEditingController(text: form.note);
    widget.controller.addListener(_handleControllerChange);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_handleControllerChange);
    _drugNameController.dispose();
    _doseController.dispose();
    _durationDaysController.dispose();
    _indicationController.dispose();
    _drugInteractionsController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _handleControllerChange() {
    // Auto-pop if saved successfully.
    if (widget.controller.state.isSaved && mounted) {
      Navigator.of(context).pop(true);
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? file = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );

      if (file != null) {
        final String sourceLabel = source == ImageSource.camera
            ? 'camera'
            : 'gallery';
        widget.controller.setImage(file.path, sourceLabel);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Image picker error: $e')));
      }
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ListTile(
                  key: const Key('add-med-camera-option'),
                  leading: const Icon(Icons.camera_alt_rounded),
                  title: const Text('Take a photo'),
                  subtitle: const Text('Scan prescription (UI only — no OCR)'),
                  onTap: () {
                    Navigator.of(context).pop();
                    _pickImage(ImageSource.camera);
                  },
                ),
                ListTile(
                  key: const Key('add-med-gallery-option'),
                  leading: const Icon(Icons.photo_library_rounded),
                  title: const Text('Choose from gallery'),
                  onTap: () {
                    Navigator.of(context).pop();
                    _pickImage(ImageSource.gallery);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (BuildContext context, Widget? child) {
        final AddMedicationState state = widget.controller.state;
        final ColorScheme colorScheme = Theme.of(context).colorScheme;

        return Scaffold(
          appBar: AppBar(title: const Text('Add Medication')),
          body: ListView(
            padding: const EdgeInsets.all(20),
            children: <Widget>[
              // Image section
              _ImageSection(
                imagePath: state.form.imagePath,
                imageSource: state.form.imageSource,
                onPickImage: _showImageSourceDialog,
                onClearImage: widget.controller.clearImage,
              ),
              const SizedBox(height: 20),

              // Form fields
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Medication Details',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        key: const Key('add-med-drug-name-field'),
                        controller: _drugNameController,
                        onChanged: widget.controller.updateDrugName,
                        decoration: const InputDecoration(
                          labelText: 'Drug name *',
                          hintText: 'Enter drug name',
                        ),
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        key: const Key('add-med-frequency-field'),
                        initialValue: state.form.commonFrequency,
                        decoration: const InputDecoration(
                          labelText: 'Common frequency',
                        ),
                        items: const <DropdownMenuItem<String>>[
                          DropdownMenuItem<String>(
                            value: 'Once daily',
                            child: Text('Once daily'),
                          ),
                          DropdownMenuItem<String>(
                            value: 'Twice daily',
                            child: Text('Twice daily'),
                          ),
                          DropdownMenuItem<String>(
                            value: 'Three times daily',
                            child: Text('Three times daily'),
                          ),
                          DropdownMenuItem<String>(
                            value: 'As needed',
                            child: Text('As needed'),
                          ),
                        ],
                        onChanged: (String? value) {
                          if (value != null) {
                            widget.controller.updateCommonFrequency(value);
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        key: const Key('add-med-dose-field'),
                        controller: _doseController,
                        onChanged: widget.controller.updateDose,
                        decoration: const InputDecoration(
                          labelText: 'Dose *',
                          hintText: 'e.g. 500 mg',
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        key: const Key('add-med-duration-field'),
                        controller: _durationDaysController,
                        keyboardType: TextInputType.number,
                        onChanged: widget.controller.updateDurationDays,
                        decoration: const InputDecoration(
                          labelText: 'Duration (days)',
                          hintText: '30',
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        key: const Key('add-med-indication-field'),
                        controller: _indicationController,
                        onChanged: widget.controller.updateIndication,
                        decoration: const InputDecoration(
                          labelText: 'Indication',
                          hintText: 'What is it for?',
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        key: const Key('add-med-interactions-field'),
                        controller: _drugInteractionsController,
                        onChanged: widget.controller.updateDrugInteractions,
                        maxLines: 2,
                        decoration: const InputDecoration(
                          labelText: 'Drug interactions',
                          hintText: 'Comma-separated interactions',
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        key: const Key('add-med-note-field'),
                        controller: _noteController,
                        onChanged: widget.controller.updateNote,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Note',
                          hintText: 'Additional instructions or notes',
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Save message
              if (state.saveMessage.isNotEmpty) ...<Widget>[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    state.saveMessage,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Action buttons
              Row(
                children: <Widget>[
                  Expanded(
                    child: OutlinedButton(
                      key: const Key('add-med-reset-button'),
                      onPressed: () {
                        widget.controller.resetForm();
                        _drugNameController.clear();
                        _doseController.clear();
                        _durationDaysController.text = '30';
                        _indicationController.clear();
                        _drugInteractionsController.clear();
                        _noteController.clear();
                      },
                      child: const Text('Reset'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      key: const Key('add-med-save-button'),
                      onPressed: widget.controller.save,
                      child: const Text('Save Medication'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }
}

class _ImageSection extends StatelessWidget {
  const _ImageSection({
    required this.imagePath,
    required this.imageSource,
    required this.onPickImage,
    required this.onClearImage,
  });

  final String imagePath;
  final String imageSource;
  final VoidCallback onPickImage;
  final VoidCallback onClearImage;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Prescription Image',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Optional: capture or select a prescription image. No OCR — image is stored locally for reference.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            if (imagePath.isNotEmpty) ...<Widget>[
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.file(
                  File(imagePath),
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                  errorBuilder:
                      (
                        BuildContext context2,
                        Object error,
                        StackTrace? stack,
                      ) => Container(
                        width: double.infinity,
                        height: 200,
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Center(
                          child: Icon(Icons.broken_image_rounded, size: 48),
                        ),
                      ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: <Widget>[
                  Icon(
                    imageSource == 'camera'
                        ? Icons.camera_alt_rounded
                        : Icons.photo_library_rounded,
                    size: 16,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      imageSource == 'camera'
                          ? 'Captured from camera'
                          : 'Selected from gallery',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  TextButton(
                    key: const Key('add-med-clear-image'),
                    onPressed: onClearImage,
                    child: const Text('Remove'),
                  ),
                ],
              ),
            ] else
              OutlinedButton.icon(
                key: const Key('add-med-pick-image-button'),
                onPressed: onPickImage,
                icon: const Icon(Icons.add_a_photo_rounded),
                label: const Text('Add Image'),
              ),
          ],
        ),
      ),
    );
  }
}

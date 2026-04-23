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
  bool _isPopping = false;

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
    _syncControllers(widget.controller.state.form);
    if (widget.controller.state.isSaved && mounted && !_isPopping) {
      _isPopping = true;
      Navigator.of(context).pop(true);
    }
  }

  void _syncControllers(AddMedicationFormData form) {
    if (_drugNameController.text != form.drugName) {
      _drugNameController.text = form.drugName;
    }
    if (_doseController.text != form.dose) {
      _doseController.text = form.dose;
    }
    if (_durationDaysController.text != form.durationDays) {
      _durationDaysController.text = form.durationDays;
    }
    if (_indicationController.text != form.indication) {
      _indicationController.text = form.indication;
    }
    if (_drugInteractionsController.text != form.drugInteractions) {
      _drugInteractionsController.text = form.drugInteractions;
    }
    if (_noteController.text != form.note) {
      _noteController.text = form.note;
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final String sourceLabel = source == ImageSource.camera
        ? 'camera'
        : 'gallery';
    widget.controller.beginImagePicking(sourceLabel);

    try {
      final XFile? file = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );

      if (!mounted) {
        return;
      }

      if (file == null) {
        widget.controller.cancelImagePicking();
        return;
      }

      widget.controller.setImage(file.path, sourceLabel);
    } catch (_) {
      widget.controller.failImagePicking(
        'Unable to access the selected image. You can continue entering medication details manually.',
      );
    }
  }

  Future<void> _showImageSourceDialog() async {
    final ImageSource? source = await showModalBottomSheet<ImageSource>(
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
                  subtitle: const Text(
                    'Capture a prescription photo to autofill this form.',
                  ),
                  onTap: () {
                    Navigator.of(context).pop(ImageSource.camera);
                  },
                ),
                ListTile(
                  key: const Key('add-med-gallery-option'),
                  leading: const Icon(Icons.photo_library_rounded),
                  title: const Text('Choose from gallery'),
                  subtitle: const Text(
                    'Select an existing prescription image for extraction.',
                  ),
                  onTap: () {
                    Navigator.of(context).pop(ImageSource.gallery);
                  },
                ),
                ListTile(
                  key: const Key('add-med-cancel-image-option'),
                  leading: const Icon(Icons.close_rounded),
                  title: const Text('Cancel'),
                  onTap: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (!mounted || source == null) {
      return;
    }

    await _pickImage(source);
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
              _ImageSection(
                state: state,
                onPickImage: _showImageSourceDialog,
                onClearImage: widget.controller.clearImage,
                onRunOcr: state.hasAttachedImage && !state.isRunningOcr
                    ? widget.controller.extractFromSelectedImage
                    : null,
              ),
              const SizedBox(height: 20),
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
                        key: Key(
                          'add-med-frequency-field-${state.form.commonFrequency}',
                        ),
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
              if (state.errorMessage.isNotEmpty) ...<Widget>[
                _MessageBanner(
                  message: state.errorMessage,
                  backgroundColor: colorScheme.errorContainer,
                  foregroundColor: colorScheme.onErrorContainer,
                ),
                const SizedBox(height: 16),
              ],
              if (state.saveMessage.isNotEmpty) ...<Widget>[
                _MessageBanner(
                  message: state.saveMessage,
                  backgroundColor: colorScheme.primaryContainer,
                  foregroundColor: colorScheme.onPrimaryContainer,
                ),
                const SizedBox(height: 16),
              ],
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
    required this.state,
    required this.onPickImage,
    required this.onClearImage,
    required this.onRunOcr,
  });

  final AddMedicationState state;
  final VoidCallback onPickImage;
  final VoidCallback onClearImage;
  final Future<void> Function()? onRunOcr;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final String imagePath = state.form.imagePath;
    final String imageSource = state.form.imageSource;

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
              'Optional: capture or select a prescription image. Then run OCR only if you want help autofilling the form.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            _StatusBanner(
              flowStatus: state.flowStatus,
              message: state.statusMessage,
              hasImage: state.hasAttachedImage,
            ),
            if (state.statusMessage.isNotEmpty) const SizedBox(height: 16),
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
              const SizedBox(height: 12),
              Row(
                children: <Widget>[
                  Expanded(
                    child: OutlinedButton.icon(
                      key: const Key('add-med-change-image'),
                      onPressed: state.isPickingImage ? null : onPickImage,
                      icon: const Icon(Icons.photo_library_outlined),
                      label: const Text('Change Image'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.tonalIcon(
                      key: const Key('add-med-run-ocr'),
                      onPressed: onRunOcr == null
                          ? null
                          : () => onRunOcr!.call(),
                      icon: const Icon(Icons.document_scanner_outlined),
                      label: Text(
                        state.isRunningOcr ? 'Running OCR...' : 'Run OCR',
                      ),
                    ),
                  ),
                ],
              ),
            ] else
              OutlinedButton.icon(
                key: const Key('add-med-pick-image-button'),
                onPressed: state.isPickingImage ? null : onPickImage,
                icon: const Icon(Icons.add_a_photo_rounded),
                label: const Text('Add Image'),
              ),
          ],
        ),
      ),
    );
  }
}

class _StatusBanner extends StatelessWidget {
  const _StatusBanner({
    required this.flowStatus,
    required this.message,
    required this.hasImage,
  });

  final AddMedicationFlowStatus flowStatus;
  final String message;
  final bool hasImage;

  @override
  Widget build(BuildContext context) {
    if (message.isEmpty && flowStatus == AddMedicationFlowStatus.idle) {
      return const SizedBox.shrink();
    }

    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    Color backgroundColor = colorScheme.surfaceContainerHighest;
    Color foregroundColor = colorScheme.onSurfaceVariant;
    IconData icon = Icons.document_scanner_outlined;

    switch (flowStatus) {
      case AddMedicationFlowStatus.pickingImage:
        backgroundColor = colorScheme.primaryContainer;
        foregroundColor = colorScheme.onPrimaryContainer;
        icon = Icons.photo_library_outlined;
        break;
      case AddMedicationFlowStatus.imageAttached:
        backgroundColor = colorScheme.secondaryContainer;
        foregroundColor = colorScheme.onSecondaryContainer;
        icon = Icons.photo_outlined;
        break;
      case AddMedicationFlowStatus.runningOcr:
        backgroundColor = colorScheme.primaryContainer;
        foregroundColor = colorScheme.onPrimaryContainer;
        icon = Icons.autorenew_rounded;
        break;
      case AddMedicationFlowStatus.ocrSuccess:
        backgroundColor = colorScheme.tertiaryContainer;
        foregroundColor = colorScheme.onTertiaryContainer;
        icon = Icons.check_circle_outline_rounded;
        break;
      case AddMedicationFlowStatus.ocrFailure:
      case AddMedicationFlowStatus.saveFailure:
      case AddMedicationFlowStatus.saveSuccess:
      case AddMedicationFlowStatus.idle:
        break;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (flowStatus == AddMedicationFlowStatus.pickingImage ||
              flowStatus == AddMedicationFlowStatus.runningOcr)
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2.4,
                color: foregroundColor,
              ),
            )
          else
            Icon(icon, size: 20, color: foregroundColor),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message.isEmpty
                  ? hasImage
                        ? 'Image attached. Run OCR if you want help filling the form.'
                        : 'Add a prescription image if you want optional OCR assistance.'
                  : message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: foregroundColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageBanner extends StatelessWidget {
  const _MessageBanner({
    required this.message,
    required this.backgroundColor,
    required this.foregroundColor,
  });

  final String message;
  final Color backgroundColor;
  final Color foregroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        message,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: foregroundColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

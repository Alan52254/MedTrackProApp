import 'dart:io';

import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

import '../models/prescription_ocr_result.dart';

class PrescriptionOcrService {
  const PrescriptionOcrService();

  Future<PrescriptionOcrResult> extractFromImage(String imagePath) async {
    final File imageFile = File(imagePath);
    if (!await imageFile.exists()) {
      throw const FileSystemException('Selected image could not be found.');
    }

    final TextRecognizer textRecognizer = TextRecognizer(
      script: TextRecognitionScript.latin,
    );

    try {
      final InputImage inputImage = InputImage.fromFilePath(imagePath);
      final RecognizedText recognizedText = await textRecognizer.processImage(
        inputImage,
      );
      final String fullText = recognizedText.text.trim();
      if (fullText.isEmpty) {
        throw const OcrExtractionException(
          'No readable prescription text was detected.',
        );
      }

      final List<String> lines = fullText
          .split('\n')
          .map((String line) => line.trim())
          .where((String line) => line.isNotEmpty)
          .toList(growable: false);
      final String lowerText = fullText.toLowerCase();

      final String dose = _extractDose(lines, fullText);
      final String frequency = _extractFrequency(lowerText);
      final String duration = _extractDuration(lowerText);
      final String indication = _extractIndication(lines);
      final String interactions = _extractInteractions(lines);
      final String note = _extractNote(lines);
      final String drugName = _extractDrugName(lines, dose);

      return PrescriptionOcrResult(
        drugName: drugName,
        dose: dose,
        frequency: frequency,
        duration: duration,
        indication: indication,
        note: note,
        interactionField: interactions,
      );
    } finally {
      textRecognizer.close();
    }
  }

  String _extractDrugName(List<String> lines, String dose) {
    final RegExp headerNoise = RegExp(
      r'^(rx|take|directions|sig|dr\.?|doctor|patient|name|date)\b',
      caseSensitive: false,
    );

    for (final String line in lines.take(6)) {
      if (headerNoise.hasMatch(line)) {
        continue;
      }
      final String cleaned = dose.isEmpty
          ? line
          : line.replaceAll(dose, '').trim();
      if (cleaned.length >= 3 && !_looksLikeFrequency(cleaned.toLowerCase())) {
        return cleaned;
      }
    }

    return lines.isEmpty ? '' : lines.first;
  }

  String _extractDose(List<String> lines, String fullText) {
    final List<RegExp> patterns = <RegExp>[
      RegExp(r'(\d+(?:\.\d+)?)\s*(mg|g|ml|mcg|units?)\b', caseSensitive: false),
      RegExp(
        r'(\d+(?:\.\d+)?)\s*(tab|tabs|tablet|tablets|cap|caps|capsule|capsules|puff|puffs)\b',
        caseSensitive: false,
      ),
    ];

    for (final RegExp pattern in patterns) {
      final Match? fullMatch = pattern.firstMatch(fullText);
      if (fullMatch != null) {
        return fullMatch.group(0)?.trim() ?? '';
      }
      for (final String line in lines) {
        final Match? lineMatch = pattern.firstMatch(line);
        if (lineMatch != null) {
          return lineMatch.group(0)?.trim() ?? '';
        }
      }
    }

    return '';
  }

  String _extractFrequency(String lowerText) {
    if (lowerText.contains('bid') ||
        lowerText.contains('twice daily') ||
        lowerText.contains('2 times daily') ||
        lowerText.contains('two times daily')) {
      return 'Twice daily';
    }
    if (lowerText.contains('tid') ||
        lowerText.contains('three times daily') ||
        lowerText.contains('3 times daily')) {
      return 'Three times daily';
    }
    if (lowerText.contains('prn') || lowerText.contains('as needed')) {
      return 'As needed';
    }
    if (lowerText.contains('daily') ||
        lowerText.contains('qd') ||
        lowerText.contains('once daily') ||
        lowerText.contains('every day')) {
      return 'Once daily';
    }
    return '';
  }

  String _extractDuration(String lowerText) {
    final Match? daysMatch = RegExp(
      r'(?:for|x)\s*(\d{1,3})\s*(?:days?|d)\b',
      caseSensitive: false,
    ).firstMatch(lowerText);
    if (daysMatch != null) {
      return daysMatch.group(1) ?? '';
    }

    final Match? standaloneMatch = RegExp(
      r'\b(\d{1,3})\s*days?\b',
      caseSensitive: false,
    ).firstMatch(lowerText);
    return standaloneMatch?.group(1) ?? '';
  }

  String _extractIndication(List<String> lines) {
    for (final String line in lines) {
      final Match? match = RegExp(
        r'(?:for|indication[:\-]?)\s+(.+)$',
        caseSensitive: false,
      ).firstMatch(line);
      if (match != null) {
        return match.group(1)?.trim() ?? '';
      }
    }
    return '';
  }

  String _extractInteractions(List<String> lines) {
    for (final String line in lines) {
      final String lowerLine = line.toLowerCase();
      if (lowerLine.contains('interaction') || lowerLine.contains('avoid ')) {
        return line;
      }
    }
    return '';
  }

  String _extractNote(List<String> lines) {
    for (final String line in lines) {
      final String lowerLine = line.toLowerCase();
      if (lowerLine.startsWith('note') ||
          lowerLine.contains('do not') ||
          lowerLine.contains('warning')) {
        return line;
      }
    }
    return '';
  }

  bool _looksLikeFrequency(String value) {
    return value.contains('daily') ||
        value.contains('bid') ||
        value.contains('tid') ||
        value.contains('prn');
  }
}

class OcrExtractionException implements Exception {
  const OcrExtractionException(this.message);

  final String message;

  @override
  String toString() => message;
}

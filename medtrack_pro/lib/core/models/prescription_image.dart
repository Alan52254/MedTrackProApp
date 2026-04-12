class PrescriptionImage {
  const PrescriptionImage({
    required this.id,
    required this.patientId,
    required this.uploadedBy,
    required this.fileName,
    required this.fileUrl,
    required this.filePath,
    required this.mimeType,
    required this.fileSize,
    required this.extractedStatus,
    required this.linkedPrescriptionIds,
    required this.createdAt,
  });

  final String id;
  final String patientId;
  final String uploadedBy;
  final String fileName;
  final String fileUrl;
  final String filePath;
  final String mimeType;
  final int fileSize;
  final String extractedStatus;
  final List<String> linkedPrescriptionIds;
  final DateTime createdAt;

  factory PrescriptionImage.fromJson(Map<String, dynamic> json) {
    return PrescriptionImage(
      id: json['id'] as String? ?? '',
      patientId: json['patientId'] as String? ?? '',
      uploadedBy: json['uploadedBy'] as String? ?? '',
      fileName: json['fileName'] as String? ?? '',
      fileUrl: json['fileUrl'] as String? ?? '',
      filePath: json['filePath'] as String? ?? '',
      mimeType: json['mimeType'] as String? ?? '',
      fileSize: json['fileSize'] as int? ?? 0,
      extractedStatus: json['extractedStatus'] as String? ?? '',
      linkedPrescriptionIds:
          (json['linkedPrescriptionIds'] as List<dynamic>? ?? <dynamic>[])
              .whereType<String>()
              .toList(growable: false),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'patientId': patientId,
      'uploadedBy': uploadedBy,
      'fileName': fileName,
      'fileUrl': fileUrl,
      'filePath': filePath,
      'mimeType': mimeType,
      'fileSize': fileSize,
      'extractedStatus': extractedStatus,
      'linkedPrescriptionIds': linkedPrescriptionIds,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

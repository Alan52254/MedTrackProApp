# Firebase Integration Rules

## Firebase Responsibilities

- `Firebase Auth`: authentication and account identity
- `Cloud Firestore`: structured entities and metadata
- `Firebase Storage`: prescription image files

## Mandatory Design Rules

- Prescription image binaries must go to Storage
- Prescription image metadata must go to Firestore
- Do not store images as base64 in Firestore
- Do not call Firebase APIs directly from widgets
- Route persistence through repositories or services

## Suggested Ownership

- Auth service handles session and sign-in concerns
- Repositories handle Firestore read and write behavior
- Storage service handles file upload lifecycle
- Application layer coordinates upload, metadata persistence, and UI state

## Error Handling

- Upload failure must be visible in UI state
- Firestore write failure must be visible in UI state
- Do not fail silently

## Migration Strategy

- Keep local sample repositories available until Firebase paths are stable
- Prefer interface-compatible repository boundaries so local and Firebase implementations can swap cleanly

## Prescription Upload Flow

Recommended order:

1. User selects image
2. UI enters upload-in-progress state
3. File uploads to Storage
4. Metadata is written to Firestore
5. UI refreshes with thumbnail, filename, time, and status

## Security and Data Hygiene

- Keep auth-aware ownership fields such as `patientId` and `uploadedBy`
- Preserve file metadata including filename, MIME type, file size, and storage path

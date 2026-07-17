# FrameFit security and privacy checklist

FrameFit editing is local-first: editing photos and settings must never be
sent to a service, written to analytics, or committed to this repository.
The separately selected community photo may be uploaded only after explicit
public-post confirmation and the privacy preparation described below.

## Before committing

- Do not add real user photos, original camera captures, paths, EXIF dumps,
  location data, or screenshots that expose personal content.
- Do not add API keys, `.env` values, Android/iOS signing material, Firebase
  configuration, service-account JSON, or certificate files. Store release
  signing keys outside the repository and provide them only through a secure
  release environment.
- Keep diagnostic output free of image bytes, file paths, metadata, and other
  personal information.
- Review `git diff --check` and search changed files for credentials before
  pushing. The project ignores common local credential and private-photo paths,
  but ignore rules are a safety net, not permission to store secrets locally.

## Photo handling rules

- Request camera or photo access only after the corresponding user action.
- Preserve the source file; editing must produce a separate output.
- Validate file signatures, encoded size, and image dimensions before full
  decoding so malformed or decompression-bomb inputs cannot exhaust memory.
- Strip location and ancillary JPEG metadata from exports by default.
- Delete temporary export files after save, share, cancellation, or failure
  whenever the platform no longer needs the file.
- Community publishing must re-orient, resize, and re-encode the selected image
  so GPS, EXIF, XMP, IPTC, comments, and original names never leave the device.
- The app may contain a Supabase publishable client key supplied at build time,
  but never a secret, service-role, database, or administrator credential.
- Every exposed database table and storage write path must be protected by RLS,
  ownership checks, input limits, reporting, and rate limits.
- Any additional server upload, analytics SDK, cloud sync, or AI feature still
  requires a separate explicit product/privacy review before implementation.

## Verification

The GitHub quality gate runs dependency resolution, analysis, tests, and an
Android debug build on pushes to `main`, the active real-photo-preset branch,
and pull requests. A release APK is not a public-distribution artifact until
it is signed with a private release key outside this repository.

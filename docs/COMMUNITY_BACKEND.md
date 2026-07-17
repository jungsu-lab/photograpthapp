# FrameFit community backend

The community is an optional Supabase-backed feature. The editor continues to
work locally when the backend is not configured.

## Provisioning

1. Create a Supabase project and enable anonymous sign-ins.
2. Apply `supabase/migrations/202607170001_create_community.sql` through the
   Supabase CLI or SQL editor.
3. Enable CAPTCHA or Cloudflare Turnstile for anonymous authentication before
   a public release.
4. Build with the project URL and **publishable** client key:

```powershell
flutter run `
  --dart-define=SUPABASE_URL=https://PROJECT.supabase.co `
  --dart-define=SUPABASE_PUBLISHABLE_KEY=sb_publishable_PROJECT_KEY
```

Never place a `service_role` or secret key in the app, repository, CI log, or
APK. The publishable key is intentionally client-visible; authorization is
enforced by Postgres and Storage RLS.

## Privacy and moderation

- Upload starts only after the user presses the publish button.
- Images are re-oriented, resized to at most 2048 px, and re-encoded as JPEG.
  This removes EXIF, GPS, XMP, IPTC, original names, and other source metadata.
- Public posts expose only the prepared JPEG, nickname, caption, preset id,
  preset intensity, and composition id.
- Users can report a post once. Reports are never readable from the client.
- A database trigger limits each account to five posts per hour.
- Public launch still requires an operator moderation view and a retention/
  deletion policy for reports and removed images.

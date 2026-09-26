# Connecting a real Supabase backend

GOALZY runs entirely on an in-memory mock backend by default — nothing
below is required to build or run the app. This is what Stage 3 added to
make connecting a *real* backend possible when you're ready, without
requiring it.

## What's actually wired up right now

- **Auth** — sign in, sign up, Google/Apple OAuth, sign out, session
  restore. Fully real once connected (see below).
- **Generic database calls** (`select`/`insert`/`update` in
  `lib/core/network/real_supabase_client.dart`) — real and usable, but
  **nothing in the app calls them yet**. Tasks, Habits, Goals, Calendar,
  Analytics, Notifications, and Focus Mode all still read from their own
  in-memory mock data (`lib/shared/data/mock_data.dart` and each
  feature's own mock repository). Migrating each of those to a real table
  is separate, feature-by-feature work — each one needs its own schema,
  its own testing against a real project, and shouldn't be done as one
  unverified sweep.
- `delete(table)` on the client interface deliberately throws — the
  interface has no row-id parameter, so a "real" implementation would
  delete every row in a table. It needs a signature change
  (`delete(table, id)`) before that's safe to implement.

## 1. Create a Supabase project

Create a free project at [supabase.com](https://supabase.com). You'll need
two values from **Project Settings → API**:

- **Project URL** (e.g. `https://xxxxx.supabase.co`)
- **`anon` / `public` key** — this is the only key that should ever exist
  in a Flutter client. **Never use the `service_role` / secret key here**
  — it bypasses Row Level Security entirely and must never ship inside an
  app.

## 2. Run the schema

Open **SQL Editor → New query** in your Supabase dashboard, paste in the
contents of `supabase/schema.sql` from this repo, and run it. Read it
first — it creates a `profiles` table matching `UserProfile` exactly,
turns on Row Level Security (so a user can only ever read/write their own
row), and adds a trigger that creates a profile automatically when
someone signs up.

Nothing in this project runs this SQL automatically. You're always
reviewing and running it yourself.

## 3. Enable email/password and OAuth providers

In **Authentication → Providers**: email/password is on by default. For
Google/Apple sign-in (used by the existing "Continue with Google/Apple"
buttons), enable and configure those providers with your own OAuth
credentials per Supabase's provider setup docs — that part is
provider-specific configuration outside this repo's scope.

## 4. Run the app with your credentials

Credentials are never hardcoded or committed — they're passed at
build/run time:

```bash
flutter run \
  --dart-define=SUPABASE_URL=https://xxxxx.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=your-anon-key
```

Same flags work with `flutter build apk`, `flutter build ios`,
`flutter build web`, etc.

If you don't pass these, the app runs on the mock backend exactly as
before — connecting a backend is opt-in. If you pass them but
`Supabase.initialize()` fails for any reason (wrong URL, no network), the
app logs it and quietly falls back to the mock backend rather than
crashing — see the bootstrap logic in `lib/main.dart`.

## Architecture reference

- `lib/core/config/backend_config.dart` — reads the two `--dart-define`
  values, exposes `BackendConfig.isConfigured`.
- `lib/core/network/supabase_client_stub.dart` — the stable interface
  (`SupabaseClientStub`) everything else depends on.
- `lib/core/network/real_supabase_client.dart` — the real implementation,
  used only once `Supabase.initialize()` has actually succeeded.
- `lib/core/di/providers.dart` — `supabaseClientProvider` defaults to the
  mock; `lib/main.dart` overrides it with the real client at the
  `ProviderScope` level, but only on confirmed successful initialization.
- `lib/features/authentication/` — `AuthRepository` /
  `MockAuthRepository` are unchanged in shape; they depend on
  `SupabaseClientStub`, not on which implementation is active, so nothing
  there needed to change for this to work.

## One honest caveat

The `supabase_flutter` API calls in `real_supabase_client.dart`
(`signInWithPassword`, `signInWithOAuth`, `currentSession`, the
`.from(table).select()/.insert()/.update()` query-builder pattern) were
written to match the standard, documented `supabase_flutter` v2.x API
(this project depends on `^2.8.0`). They were not tested against a live
project — there's no Supabase network access available in the environment
that built this integration. Please run `flutter analyze` and do a real
sign-in test against your own project before relying on this.

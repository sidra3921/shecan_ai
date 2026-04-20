# Supabase Dummy Data Guide

Use this guide to add realistic test data for SheCan AI so you can exercise the app with real backend records instead of UI placeholders.

## What this seed covers

- 2 mentor accounts
- 1 client account
- 2 projects
- 2 mentor gigs
- 1 conversation and 2 messages
- 2 notifications
- 1 payment
- 1 review
- 1 dispute
- 1 saved gig

## Before you run it

1. Open Supabase and create test Auth users first.
2. Copy their user IDs from Authentication.
3. Open [SUPABASE_DUMMY_DATA.sql](SUPABASE_DUMMY_DATA.sql) and replace these placeholder UUIDs:
   - `11111111-1111-1111-1111-111111111111` for the client
   - `22222222-2222-2222-2222-222222222222` for mentor 1
   - `33333333-3333-3333-3333-333333333333` for mentor 2
4. Make sure your Supabase tables already exist.

## How to insert the data

### Option 1: Supabase SQL Editor

1. Open your Supabase project.
2. Go to SQL Editor.
3. Paste the contents of [SUPABASE_DUMMY_DATA.sql](SUPABASE_DUMMY_DATA.sql).
4. Replace the placeholder UUIDs with your real Auth user IDs.
5. Run the query.

### Option 2: Run section by section

If one table fails because your schema uses different column names, run the file in smaller pieces:

1. Start with the `users` block.
2. Then insert `projects`.
3. Then `mentor_gigs`.
4. Then the communication tables: `conversations` and `messages`.
5. Finish with `notifications`, `payments`, `reviews`, `disputes`, and `saved_gigs`.

## After insertion

1. Open Table Editor and confirm the records exist.
2. Sign in to the app with the client account.
3. Sign in to the app with the mentor account.
4. Verify these screens and flows:
   - profile loading
   - project list and project detail
   - mentor gig list
   - chat/messages
   - notifications
   - payments
   - reviews
   - disputes

## Recommended test accounts

- Client: `client.demo@shecan.ai`
- Mentor 1: `mentor.demo@shecan.ai`
- Mentor 2: `mentor2.demo@shecan.ai`

## Notes

- The seed uses stable UUIDs so rerunning it should update the same rows.
- If your schema uses slightly different column names, adjust that table block only.
- If a table is protected by RLS, run the seed from the Supabase SQL Editor, not from the app.

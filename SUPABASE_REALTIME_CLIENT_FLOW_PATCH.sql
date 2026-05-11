-- =============================================
-- SheCan AI: Realtime Patch for Client Flows
-- Enables Realtime publication for tables used by:
-- - Saved mentors/gigs
-- - Reviews
-- - Disputes
-- - Payments (escrow-aware)
-- =============================================

-- Escrow metadata for payments (safe no-ops if table missing).
ALTER TABLE IF EXISTS public.payments
  ADD COLUMN IF NOT EXISTS escrow_status text,
  ADD COLUMN IF NOT EXISTS escrow_hold_until timestamptz,
  ADD COLUMN IF NOT EXISTS escrow_released_at timestamptz,
  ADD COLUMN IF NOT EXISTS escrow_reference text;

DO $$
BEGIN
  IF to_regclass('public.saved_gigs') IS NOT NULL THEN
    BEGIN
      ALTER PUBLICATION supabase_realtime ADD TABLE public.saved_gigs;
    EXCEPTION
      WHEN duplicate_object THEN
        NULL;
      WHEN undefined_table THEN
        NULL;
    END;
  END IF;

  IF to_regclass('public.reviews') IS NOT NULL THEN
    BEGIN
      ALTER PUBLICATION supabase_realtime ADD TABLE public.reviews;
    EXCEPTION
      WHEN duplicate_object THEN
        NULL;
      WHEN undefined_table THEN
        NULL;
    END;
  END IF;

  IF to_regclass('public.disputes') IS NOT NULL THEN
    BEGIN
      ALTER PUBLICATION supabase_realtime ADD TABLE public.disputes;
    EXCEPTION
      WHEN duplicate_object THEN
        NULL;
      WHEN undefined_table THEN
        NULL;
    END;
  END IF;

  IF to_regclass('public.payments') IS NOT NULL THEN
    BEGIN
      ALTER PUBLICATION supabase_realtime ADD TABLE public.payments;
    EXCEPTION
      WHEN duplicate_object THEN
        NULL;
      WHEN undefined_table THEN
        NULL;
    END;
  END IF;
END $$;

-- Optional verification query:
-- SELECT schemaname, tablename
-- FROM pg_publication_tables
-- WHERE pubname = 'supabase_realtime'
--   AND schemaname = 'public'
--   AND tablename IN ('saved_gigs', 'reviews', 'disputes', 'payments')
-- ORDER BY tablename;

-- =============================================
-- Diploma Anchor bootstrap (idempotent)
-- Executed at container init (docker-entrypoint-initdb.d)
-- =============================================

-- 1) Extend enum for status if an enum type is used.
-- Adjust type name if different. We attempt only if it exists.
DO $$
DECLARE
  enum_name text := 'diploma_requests_status_enum';
BEGIN
  IF EXISTS (SELECT 1 FROM pg_type t WHERE t.typname = enum_name) THEN
    -- Add values if missing
    IF NOT EXISTS (SELECT 1 FROM pg_enum e JOIN pg_type t ON e.enumtypid = t.oid WHERE t.typname = enum_name AND e.enumlabel = 'ready_for_anchor') THEN
      EXECUTE format('ALTER TYPE %I ADD VALUE ''ready_for_anchor''', enum_name);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_enum e JOIN pg_type t ON e.enumtypid = t.oid WHERE t.typname = enum_name AND e.enumlabel = 'anchored') THEN
      EXECUTE format('ALTER TYPE %I ADD VALUE ''anchored''', enum_name);
    END IF;
  END IF;
END$$;

-- 2) Add anchor columns to diploma_requests if not present.
ALTER TABLE IF EXISTS diploma_requests
  ADD COLUMN IF NOT EXISTS "anchorRequested" boolean DEFAULT false,
  ADD COLUMN IF NOT EXISTS "anchorTxHash" varchar(66),
  ADD COLUMN IF NOT EXISTS "anchorBatchId" varchar(255),
  ADD COLUMN IF NOT EXISTS "anchorDiplomeLabel" varchar(255);

-- 3) Create anchor signatures table.
CREATE TABLE IF NOT EXISTS diploma_anchor_signatures (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  "diplomaRequestId" uuid NOT NULL,
  "signerAddress" varchar(42) NOT NULL,
  message text NOT NULL,
  signature text NOT NULL,
  "createdAt" timestamptz NOT NULL DEFAULT now()
);

-- 4) Index for fast lookup.
CREATE INDEX IF NOT EXISTS idx_anchor_sig_request ON diploma_anchor_signatures("diplomaRequestId");

-- 5) (Optional) FK - skipped if table structure uncertain; uncomment if desired.
-- ALTER TABLE diploma_anchor_signatures
--   ADD CONSTRAINT fk_anchor_request
--   FOREIGN KEY ("diplomaRequestId") REFERENCES diploma_requests(id) ON DELETE CASCADE;

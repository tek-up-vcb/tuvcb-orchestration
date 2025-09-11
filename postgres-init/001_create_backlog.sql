-- postgres-init/001_create_backlog.sql
CREATE TABLE IF NOT EXISTS backlog (
  id           BIGSERIAL PRIMARY KEY,
  user_id      BIGINT,
  action_type  VARCHAR(64) NOT NULL,
  action_description TEXT   NOT NULL,
  metadata     JSONB       NULL,
  created_at   TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_backlog_created_at ON backlog (created_at DESC);
CREATE INDEX IF NOT EXISTS idx_backlog_user_id ON backlog (user_id);

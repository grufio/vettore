-- Postgres schema for grufio (projects-only)
-- Idempotent: safe creates

-- Ensure projects table exists with shape expected by the app
CREATE TABLE IF NOT EXISTS projects (
  id BIGSERIAL PRIMARY KEY,
  title TEXT NOT NULL,
  author TEXT,
  status TEXT NOT NULL DEFAULT 'draft',
  created_at BIGINT NOT NULL,
  updated_at BIGINT NOT NULL,
  image_id BIGINT REFERENCES images(id),
  canvas_width_px INTEGER,
  canvas_height_px INTEGER,
  canvas_width_value DOUBLE PRECISION NOT NULL DEFAULT 0,
  canvas_width_unit TEXT NOT NULL DEFAULT 'px',
  canvas_height_value DOUBLE PRECISION NOT NULL DEFAULT 0,
  canvas_height_unit TEXT NOT NULL DEFAULT 'px',
  grid_cell_width_value DOUBLE PRECISION NOT NULL DEFAULT 0,
  grid_cell_width_unit TEXT NOT NULL DEFAULT 'px',
  grid_cell_height_value DOUBLE PRECISION NOT NULL DEFAULT 0,
  grid_cell_height_unit TEXT NOT NULL DEFAULT 'px'
);

-- Ensure image_id exists on existing installs and add FK to images
ALTER TABLE projects ADD COLUMN IF NOT EXISTS image_id BIGINT;
DO $$ BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint WHERE conname = 'projects_image_id_fk'
  ) THEN
    ALTER TABLE projects
      ADD CONSTRAINT projects_image_id_fk FOREIGN KEY (image_id)
      REFERENCES images(id);
  END IF;
END $$;
CREATE INDEX IF NOT EXISTS projects_image_id_idx ON projects(image_id);

-- Images table for uploaded/processed images
CREATE TABLE IF NOT EXISTS images (
  id BIGSERIAL PRIMARY KEY,
  orig_src BYTEA,
  conv_src BYTEA,
  orig_bytes INTEGER,
  conv_bytes INTEGER,
  orig_width INTEGER,
  orig_height INTEGER,
  mime_type TEXT,
  orig_dpi INTEGER,
  dpi INTEGER,
  phys_width_px4 DOUBLE PRECISION,
  phys_height_px4 DOUBLE PRECISION
);

CREATE INDEX IF NOT EXISTS images_dpi_idx ON images(dpi);

-- Unit constraints (idempotent)
DO $$ BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint
    WHERE conname = 'chk_projects_canvas_width_unit'
  ) THEN
    ALTER TABLE projects
      ADD CONSTRAINT chk_projects_canvas_width_unit
      CHECK (canvas_width_unit IN ('px','mm','in'));
  END IF;
END $$;

DO $$ BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint
    WHERE conname = 'chk_projects_canvas_height_unit'
  ) THEN
    ALTER TABLE projects
      ADD CONSTRAINT chk_projects_canvas_height_unit
      CHECK (canvas_height_unit IN ('px','mm','in'));
  END IF;
END $$;

DO $$ BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint
    WHERE conname = 'chk_projects_grid_cell_width_unit'
  ) THEN
    ALTER TABLE projects
      ADD CONSTRAINT chk_projects_grid_cell_width_unit
      CHECK (grid_cell_width_unit IN ('px','mm','in'));
  END IF;
END $$;

DO $$ BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint
    WHERE conname = 'chk_projects_grid_cell_height_unit'
  ) THEN
    ALTER TABLE projects
      ADD CONSTRAINT chk_projects_grid_cell_height_unit
      CHECK (grid_cell_height_unit IN ('px','mm','in'));
  END IF;
END $$;

-- Indexes
DROP INDEX IF EXISTS projects_updated_at_idx;
CREATE INDEX IF NOT EXISTS projects_updated_at_idx ON projects(updated_at);
CREATE INDEX IF NOT EXISTS projects_status_updated_idx ON projects(status, updated_at);

-- Realtime notifications (LISTEN/NOTIFY)
-- Function to notify on changes to projects
CREATE OR REPLACE FUNCTION notify_projects_changed() RETURNS trigger AS $$
DECLARE
  v_id BIGINT;
  v_payload TEXT;
BEGIN
  v_id := COALESCE(NEW.id, OLD.id);
  v_payload := json_build_object('op', TG_OP, 'id', v_id)::text;
  PERFORM pg_notify('projects_changed', v_payload);
  RETURN NULL; -- AFTER triggers ignore return value; NULL is safe for all ops
END;
$$ LANGUAGE plpgsql;

-- Triggers for INSERT/UPDATE/DELETE
DROP TRIGGER IF EXISTS trg_projects_insert_notify ON projects;
CREATE TRIGGER trg_projects_insert_notify
AFTER INSERT ON projects
FOR EACH ROW EXECUTE FUNCTION notify_projects_changed();

DROP TRIGGER IF EXISTS trg_projects_update_notify ON projects;
CREATE TRIGGER trg_projects_update_notify
AFTER UPDATE ON projects
FOR EACH ROW EXECUTE FUNCTION notify_projects_changed();

DROP TRIGGER IF EXISTS trg_projects_delete_notify ON projects;
CREATE TRIGGER trg_projects_delete_notify
AFTER DELETE ON projects
FOR EACH ROW EXECUTE FUNCTION notify_projects_changed();

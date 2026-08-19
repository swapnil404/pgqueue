CREATE TABLE jobs (
    id bigserial PRIMARY KEY,
    job_type text NOT NULL,
    payload jsonb NOT NULL,
    status text NOT NULL DEFAULT 'pending',
    heartbeat timestamptz,
    created_at timestamptz NOT NULL DEFAULT now(),
    attempts integer NOT NULL DEFAULT 0,
    max_attempts integer NOT NULL DEFAULT 5,
    ran_by text
);

CREATE INDEX idx_jobs_status_created ON jobs (status, created_at) WHERE status = 'pending';

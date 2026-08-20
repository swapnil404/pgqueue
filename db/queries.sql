-- name: InsertJob :one
INSERT INTO jobs (job_type, payload)
VALUES ($1, $2)
RETURNING id;

-- name: ClaimJob :one
UPDATE jobs
SET status = 'running', ran_by = $1, heartbeat = now()
WHERE id = (
    SELECT id FROM jobs
    WHERE status = 'pending'
    ORDER BY created_at
    LIMIT 1
    FOR UPDATE SKIP LOCKED
)
RETURNING id, job_type, payload, attempts;

-- name: UpdateHeartbeat :exec
UPDATE jobs
SET heartbeat = now()
WHERE id = $1;

-- name: CompleteJob :exec
UPDATE jobs
SET status = 'completed'
WHERE id = $1;

-- name: RetryJob :execrows
UPDATE jobs
SET status = 'pending', attempts = attempts + 1
WHERE id = $1 AND attempts + 1 < max_attempts;

-- name: FailJob :exec
UPDATE jobs
SET status = 'failed', attempts = attempts + 1
WHERE id = $1 AND attempts + 1 >= max_attempts;

-- name: ReapStaleJobs :exec
UPDATE jobs
SET status = 'pending'
WHERE status = 'running' AND heartbeat < now() - interval '30 seconds';

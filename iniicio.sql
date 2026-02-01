CREATE TABLE IF NOT EXISTS visit (
	id BIGSERIAL PRIMARY KEY,
	visitor_name VARCHAR(120) NOT NULL,
	visitor_document VARCHAR(40) NOT NULL,
	visitor_email VARCHAR(120),
	host_name VARCHAR(120) NOT NULL,
	reason VARCHAR(200) NOT NULL,
	visit_entry TIMESTAMP NOT NULL DEFAULT NOW(),
	visit_exit TIMESTAMP
);

-- Índices Útiles
CREATE INDEX IF NOT EXISTS idx_visit_entry ON visit(visit_entry);
CREATE INDEX IF NOT EXISTS idx_visit_exit ON visit(visit_exit);
CREATE INDEX IF NOT EXISTS idx_host_name ON visit(host_name);
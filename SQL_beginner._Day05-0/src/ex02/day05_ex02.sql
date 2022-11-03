set enable_seqscan = off;

CREATE INDEX idx_person_name ON person(UPPER(name));

EXPLAIN ANALYZE
  select name from person where upper(name) = 'IRINA';

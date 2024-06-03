ALTER TABLE film1e6 ADD COLUMN weighted_tsv tsvector;
ALTER TABLE film1e6 ADD COLUMN weighted_tsv2 tsvector;


select * from film1e6;

UPDATE film1e6 SET
weighted_tsv = x.weighted_tsv,
weighted_tsv2 = x.weighted_tsv
FROM (
SELECT film_id,
setweight(to_tsvector('english', COALESCE(title,'')), 'A') ||
setweight(to_tsvector('english', COALESCE(description,'')), 'B')
AS weighted_tsv
FROM film1e6
) AS x
WHERE x.film_id = film1e6.film_id;


CREATE INDEX weighted_tsv_idx1e6 ON film1e6 USING GIN (weighted_tsv2);


--sin indice
vacuum analyze;
EXPLAIN ANALYZE
SELECT title, description, ts_rank_cd(weighted_tsv, query) AS rank
FROM film1e6, to_tsquery('english', 'Man | Woman') query
WHERE query @@ weighted_tsv
ORDER BY rank DESC
LIMIT 10;





-- con indice
ANALYZE film1e6;
SET enable_seqscan = OFF;
EXPLAIN ANALYZE
SELECT title, description, ts_rank_cd(weighted_tsv2, query) AS rank
FROM film1e6, to_tsquery('english', 'Man | Woman') query
WHERE query @@ weighted_tsv2
ORDER BY rank DESC
LIMIT 10;
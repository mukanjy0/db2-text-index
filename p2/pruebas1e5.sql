ALTER TABLE film1e5 ADD COLUMN weighted_tsv tsvector;
ALTER TABLE film1e5 ADD COLUMN weighted_tsv2 tsvector;

CREATE INDEX weighted_tsv_idx1e5 ON film1e5 USING GIN (weighted_tsv2);

select * from film1e5;

UPDATE film1e5 SET
weighted_tsv = x.weighted_tsv,
weighted_tsv2 = x.weighted_tsv
FROM (
SELECT film_id,
setweight(to_tsvector('english', COALESCE(title,'')), 'A') ||
setweight(to_tsvector('english', COALESCE(description,'')), 'B')
AS weighted_tsv
FROM film1e5
) AS x
WHERE x.film_id = film1e5.film_id;

--sin indice
vacuum analyze;
EXPLAIN ANALYZE
SELECT title, description, ts_rank_cd(weighted_tsv, query) AS rank
FROM film1e5, to_tsquery('english', 'Man | Woman') query
WHERE query @@ weighted_tsv
ORDER BY rank DESC
LIMIT 10;





-- con indice
ANALYZE film1e5;
SET enable_seqscan = OFF;
EXPLAIN ANALYZE
SELECT title, description, ts_rank_cd(weighted_tsv2, query) AS rank
FROM film1e5, to_tsquery('english', 'Man | Woman') query
WHERE query @@ weighted_tsv2
ORDER BY rank DESC
LIMIT 10;
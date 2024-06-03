DROP TABLE IF EXISTS articles;

-- Creación de la tabla 'articles'
CREATE TABLE articles (
    id SERIAL PRIMARY KEY,
    title TEXT,
    article TEXT NULL
);

-- Subida de datos desde un archivo CSV
COPY Public."articles" FROM '/Users/edgarchambilla/Downloads/title_article_filtered_1e6.csv' DELIMITER ',' CSV HEADER;

-- Añadiendo nuevas columnas para almacenar vectores de texto ponderados
ALTER TABLE articles ADD COLUMN weighted_tsv tsvector;
ALTER TABLE articles ADD COLUMN weighted_tsv2 tsvector;

-- Actualización de las columnas 'weighted_tsv' y 'weighted_tsv2' con valores ponderados
UPDATE articles SET
weighted_tsv = x.weighted_tsv,
weighted_tsv2 = x.weighted_tsv
FROM (
SELECT id,
setweight(to_tsvector('english', COALESCE(title,'')), 'A') ||
setweight(to_tsvector('english', COALESCE(article,'')), 'B')
AS weighted_tsv
FROM articles
) AS x
WHERE x.id = articles.id;

-- Selecciona las columnas 'weighted_tsv' y 'weighted_tsv2' para ver su contenido
select weighted_tsv,weighted_tsv2 from articles

-- Creación de un índice para la columna 'weighted_tsv2' usando GIN (Generalized Inverted Index)
CREATE INDEX weighted_tsv_idx1e3 ON articles USING GIN (weighted_tsv2);

-- Sin índice:
vacuum analyze;
EXPLAIN ANALYZE
SELECT title, article, ts_rank_cd(weighted_tsv, query) AS rank
FROM articles, to_tsquery('english', 'Paris | London') query
WHERE query @@ weighted_tsv
ORDER BY rank DESC
LIMIT 10;

-- Con índice:
ANALYZE articles;
SET enable_seqscan = OFF;
EXPLAIN ANALYZE
SELECT title, article, ts_rank_cd(weighted_tsv2, query) AS rank
FROM articles, to_tsquery('english', 'Paris | London') query
WHERE query @@ weighted_tsv2
ORDER BY rank DESC
LIMIT 20;




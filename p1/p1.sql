create schema if not exists s1k;
create schema if not exists s10k;
create schema if not exists s100k;
create schema if not exists s1m;

drop table article;
set search_path to 's1m'; -- edit schema name

-- create table with 2 text attributes
create table if not exists article (
                         body text,
                         indexed_body text
);

-- extension for trigrams
create extension if not exists pg_trgm with schema s1m; -- edit schema name

-- fill with random data (text)
insert into article
select md5(random()::text)
from (select id from generate_series(1, 1000000) as id) as T;

update article set indexed_body = body;

reset search_path;
create index article_idx on s1m.article
    using GIN (indexed_body gin_trgm_ops);


set search_path to 's1m'; -- edit schema name

explain analyse
select count(*)
from article
where body like '%abc%';

explain analyse
select count(*)
from article
where indexed_body like '%abc%';


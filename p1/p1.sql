-- extension for trigrams
create extension if not exists pg_trgm;

/*
==================
|       1k       |
==================
 */

create schema if not exists s1k;
set search_path to 's1k';

-- create table with 2 text attributes
create table if not exists article (
                                       body text,
                                       indexed_body text
);

-- fill with random data (text)
insert into article
select md5(random()::text)
from (select id from generate_series(1, 1000) as id) as T; -- edit number

update article set indexed_body = body;

reset search_path;
create index article_idx on s1k.article -- edit schema name
    using GIN (indexed_body gin_trgm_ops);

/*
==================
|       10k       |
==================
 */

create schema if not exists s10k;
set search_path to 's10k';

-- create table with 2 text attributes
create table if not exists article (
                                       body text,
                                       indexed_body text
);

-- fill with random data (text)
insert into article
select md5(random()::text)
from (select id from generate_series(1, 10000) as id) as T; -- edit number

update article set indexed_body = body;

reset search_path;
create index article_idx on s10k.article -- edit schema name
    using GIN (indexed_body gin_trgm_ops);

/*
==================
|       100k       |
==================
 */

create schema if not exists s100k;
set search_path to 's100k';

-- create table with 2 text attributes
create table if not exists article (
                                       body text,
                                       indexed_body text
);

-- fill with random data (text)
insert into article
select md5(random()::text)
from (select id from generate_series(1, 100000) as id) as T; -- edit number

update article set indexed_body = body;

reset search_path;
create index article_idx on s100k.article -- edit schema name
    using GIN (indexed_body gin_trgm_ops);

/*
==================
|       1m       |
==================
 */

create schema if not exists s1m;
set search_path to 's1m';

-- create table with 2 text attributes
create table if not exists article (
                                       body text,
                                       indexed_body text
);

-- fill with random data (text)
insert into article
select md5(random()::text)
from (select id from generate_series(1, 1000000) as id) as T; -- edit number

update article set indexed_body = body;

reset search_path;
create index article_idx on s1m.article -- edit schema name
    using GIN (indexed_body gin_trgm_ops);

/*
==================
|     queries    |
==================
 */

set search_path to 's1k'; -- edit schema name

explain analyse
select count(*)
from article
where body like '%abc%';

explain analyse
select count(*)
from article
where indexed_body like '%abc%';

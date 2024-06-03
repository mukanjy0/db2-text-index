CREATE TABLE film1e4 AS TABLE film WITH NO DATA;

ALTER TABLE film1e4 ADD PRIMARY KEY (film_id);


INSERT INTO film1e4 (film_id, title, description, release_year, language_id, rental_duration, 
					 rental_rate, length, replacement_cost, rating, last_update, special_features)
SELECT film_id, title, description, release_year, language_id, rental_duration, rental_rate, length, 
replacement_cost, rating, last_update, special_features
FROM film;



DO $$
DECLARE
    original_count int;
    current_count int;
    max_id int;
BEGIN
    SELECT COUNT(*) INTO original_count FROM film;

    SELECT COUNT(*) INTO current_count FROM film1e4;

    SELECT MAX(film_id) INTO max_id FROM film1e4;

    WHILE current_count < 10000 LOOP
        INSERT INTO film1e4 (film_id, title, description, release_year, language_id, rental_duration, rental_rate, 
							 length, replacement_cost, rating, last_update, special_features)
        SELECT max_id + row_number() OVER (), title, description, release_year, language_id, rental_duration, rental_rate, 
		length, replacement_cost, rating, last_update, special_features
        FROM film;

        current_count := current_count + original_count;

        max_id := max_id + original_count;
    END LOOP;
END $$;

select * from film1e4;
CREATE TABLE film1e5 AS TABLE film WITH NO DATA;

ALTER TABLE film1e5 ADD PRIMARY KEY (film_id);


INSERT INTO film1e5 (film_id, title, description, release_year, language_id, rental_duration, 
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

    SELECT COUNT(*) INTO current_count FROM film1e5;

    SELECT MAX(film_id) INTO max_id FROM film1e5;

    WHILE current_count < 100000 LOOP
        INSERT INTO film1e5 (film_id, title, description, release_year, language_id, rental_duration, rental_rate, 
							 length, replacement_cost, rating, last_update, special_features)
        SELECT max_id + row_number() OVER (), title, description, release_year, language_id, rental_duration, rental_rate, 
		length, replacement_cost, rating, last_update, special_features
        FROM film;

        current_count := current_count + original_count;

        max_id := max_id + original_count;
    END LOOP;
END $$;

SELECT * FROM film1e5;


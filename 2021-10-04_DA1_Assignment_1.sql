use imdb;

ALTER TABLE actors
RENAME COLUMN id TO actor_id;

ALTER TABLE movies
RENAME COLUMN movies_id TO movie_id;

ALTER TABLE movies
RENAME COLUMN name TO movie_name;

ALTER TABLE directors
RENAME COLUMN id TO directors_id;



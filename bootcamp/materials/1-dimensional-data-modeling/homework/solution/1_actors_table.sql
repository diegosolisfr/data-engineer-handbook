DROP TYPE IF EXISTS film CASCADE;
CREATE TYPE film AS (
    film TEXT,
    votes INTEGER,
    rating REAL,
    filmid TEXT
);

DROP TYPE IF EXISTS quality_class CASCADE;
CREATE TYPE quality_class AS
    ENUM ('star', 'good', 'average', 'bad');

DROP TABLE IF EXISTS actors;
CREATE TABLE actors (
    actor TEXT,
    actorid TEXT,
    year INTEGER,
    films film[],
    quality_class quality_class,
    is_active BOOLEAN,
    PRIMARY KEY (actorid, year)
);

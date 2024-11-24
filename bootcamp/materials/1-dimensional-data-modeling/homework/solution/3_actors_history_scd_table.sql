DROP TABLE IF EXISTS actors_history_scd;
CREATE TABLE actors_history_scd (
    actor TEXT,
    actorid TEXT,
    quality_class quality_class,
    is_active BOOLEAN,
    start_year INTEGER,
    end_year INTEGER,
    year INTEGER,
    PRIMARY KEY (actorid, start_year, end_year, year)
);

DROP TYPE IF EXISTS scd_type;
CREATE TYPE scd_type AS (
    quality_class quality_class,
    is_active BOOLEAN,
    start_year INTEGER,
    end_year INTEGER
);

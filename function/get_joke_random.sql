CREATE OR REPLACE FUNCTION get_joke_random(
    category VARCHAR DEFAULT NULL
) RETURNS json AS $$

    SELECT
        get_joke(j.joke_id)
    FROM
        joke AS j
    WHERE
        CASE
            WHEN get_joke_random.category IS NOT NULL
            THEN categories IS NOT NULL AND categories ?| array[ get_joke_random.category ]
            ELSE true
        END
    ORDER BY
        RANDOM()
    LIMIT
        1;

$$ LANGUAGE sql;

COMMENT ON FUNCTION get_joke_random(VARCHAR) IS 'Get a random joke.';
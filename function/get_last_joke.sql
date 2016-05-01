CREATE OR REPLACE FUNCTION get_last_joke(
) RETURNS json AS $$

    SELECT
        get_joke(joke_id)
    FROM
        joke
    ORDER BY
        created_at DESC
    LIMIT
        1
    OFFSET
        0;

$$ LANGUAGE sql;

COMMENT ON FUNCTION get_last_joke() IS 'Get the last joke from the database.';
CREATE OR REPLACE FUNCTION get_first_joke(
) RETURNS json AS $$

    SELECT get_joke(joke_id) FROM joke LIMIT 1 OFFSET 0;

$$ LANGUAGE sql;

COMMENT ON FUNCTION get_first_joke() IS 'Get the first joke from the database.';
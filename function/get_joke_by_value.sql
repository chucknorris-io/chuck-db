CREATE OR REPLACE FUNCTION get_joke_by_value(
    "value" VARCHAR
) RETURNS json AS
$$

SELECT get_joke(joke_id)
FROM joke
WHERE value = get_joke_by_value.value;

$$ LANGUAGE sql;

COMMENT ON FUNCTION get_joke_by_value(VARCHAR) IS 'Get a joke by value.';

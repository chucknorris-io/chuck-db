CREATE OR REPLACE FUNCTION get_joke(
    joke_id SLUGID
) RETURNS json AS $$

    SELECT
        JSON_BUILD_OBJECT (
            'id',         j.joke_id,
            'categories', j.categories,
            'value',      j.value,
            'createdAt',  j.created_at,
            'updatedAt',  j.updated_at
        ) as joke
        
    FROM
        joke AS j
    WHERE
        j.joke_id = get_joke.joke_id;

$$ LANGUAGE sql;

COMMENT ON FUNCTION get_joke(SLUGID) IS 'Get a joke by a given joke id.';
CREATE OR REPLACE FUNCTION update_joke(
    joke_id    SLUGID,
    categories JSONB,
    value      VARCHAR
) RETURNS json AS $$

    UPDATE joke SET
        categories = update_joke.categories,
        value      = update_joke.value
    WHERE
        joke_id    = update_joke.joke_id
    RETURNING
        get_joke(update_joke.joke_id);

$$ LANGUAGE sql;

COMMENT ON FUNCTION update_joke(SLUGID, JSONB, VARCHAR) IS 'Update a joke.';
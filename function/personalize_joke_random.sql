CREATE OR REPLACE FUNCTION personalize_joke_random(
    replace_term VARCHAR
) RETURNS json AS $$

    SELECT
        JSON_BUILD_OBJECT (
            'id',         j.joke_id,
            'categories', j.categories,
            'value',      replace(j.value, 'Chuck Norris', personalize_joke_random.replace_term),
            'createdAt',  j.created_at,
            'updatedAt',  j.updated_at
        ) as joke
    FROM
        joke AS j
    WHERE
        j.value LIKE ('%Chuck Norris %')
        AND
        j.value NOT ILIKE ('% he %')
        AND
        j.value NOT ILIKE ('% him %')
        AND
        j.value NOT ILIKE ('% his %')
    ORDER BY
        RANDOM()
    LIMIT
        1;

$$ LANGUAGE sql;

COMMENT ON FUNCTION personalize_joke_random(varchar) IS 'Get a random personalized joke.';
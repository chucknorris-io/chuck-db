BEGIN TRANSACTION;

    DROP FUNCTION IF EXISTS get_joke_random(VARCHAR);

    CREATE OR REPLACE FUNCTION get_joke_random(
        category VARCHAR DEFAULT NULL,
        parental_control BOOLEAN DEFAULT false
    ) RETURNS json AS $$

        SELECT
            get_joke(j.joke_id)
        FROM
            joke AS j
        WHERE
            CASE
                WHEN get_joke_random.parental_control = true
                THEN categories IS NOT NULL AND NOT (categories ?| array[ 'explicit' ])
                ELSE true
            END
            AND
            CASE
                WHEN get_joke_random.category IS NOT NULL AND get_joke_random.category != 'explicit'
                THEN categories IS NOT NULL AND categories ?| array[ get_joke_random.category ]
                ELSE true
            END
        ORDER BY
            RANDOM()
        LIMIT
            1;

    $$ LANGUAGE sql;

    COMMENT ON FUNCTION get_joke_random(VARCHAR, BOOLEAN) IS 'Get a random joke.';

    DROP FUNCTION IF EXISTS personalize_joke_random(VARCHAR);

    CREATE OR REPLACE FUNCTION personalize_joke_random(
        replace_term     VARCHAR,
        parental_control BOOLEAN DEFAULT false
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
            CASE
                WHEN personalize_joke_random.parental_control = true
                THEN categories IS NOT NULL AND NOT (categories ?| array[ 'explicit' ])
                ELSE true
            END
            AND
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

    COMMENT ON FUNCTION personalize_joke_random(VARCHAR, BOOLEAN) IS 'Get a random personalized joke.';

COMMIT TRANSACTION;

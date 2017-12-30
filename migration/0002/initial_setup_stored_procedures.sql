BEGIN TRANSACTION;

    CREATE OR REPLACE FUNCTION count_jokes() RETURNS bigint AS $$
       SELECT count(*) FROM joke;
    $$ LANGUAGE sql;
    COMMENT ON FUNCTION count_jokes() IS 'Get the total number of jokes.';

    CREATE OR REPLACE FUNCTION delete_duplicated_jokes() RETURNS bigint AS $$
        WITH deletions AS (
            DELETE FROM joke WHERE joke_id IN (
                SELECT joke_id FROM (SELECT joke_id, ROW_NUMBER() OVER (partition BY joke ORDER BY created_at) AS row_num FROM joke) AS t
            WHERE t.row_num > 1) RETURNING 1
        )
        SELECT count(*) FROM deletions;
    $$ LANGUAGE sql;
    COMMENT ON FUNCTION delete_duplicated_jokes() IS 'Deleting duplicated jokes.';

    CREATE OR REPLACE FUNCTION delete_joke(
        joke_id SLUGID
    ) RETURNS bigint AS $$
        WITH deletions AS (
            DELETE FROM joke WHERE joke_id = delete_joke.joke_id RETURNING 1
        )
        SELECT count(*) FROM deletions;
    $$ LANGUAGE sql;
    COMMENT ON FUNCTION delete_joke(SLUGID) IS 'Delete a joke by a given joke id.';

    CREATE OR REPLACE FUNCTION find_categories() RETURNS json AS $$
        (SELECT array_to_json(array_agg(row_to_json(t))) FROM (
            SELECT
                j.categories->>0 AS "name",
                count(j.joke_id) AS "count"
            FROM
                joke AS j
            WHERE
                j.categories IS NOT NULL
            GROUP BY
                j.categories->>0
            ORDER BY
                count(j.joke_id) DESC
        ) t);
    $$ LANGUAGE sql;
    COMMENT ON FUNCTION find_categories() IS 'Get categories with joke count.';

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

    CREATE OR REPLACE FUNCTION find_jokes_by_ids(
        ids json
    ) RETURNS json AS $$
        SELECT
            JSON_BUILD_OBJECT(
                'items', json_agg(
                    get_joke(joke_id)
                )
            )
        FROM
            joke
        WHERE
            find_jokes_by_ids.ids::jsonb ? joke_id::text
    $$ LANGUAGE sql;
    COMMENT ON FUNCTION find_jokes_by_ids(json)
      IS 'Get jokes by a given json array of joke ids. Example response:
    {
         "items" : [
            {"joke_id" : "abc", "categories" : [], "value" : "...", "createdAt" : "2016-03-12T04:17:12.779747", "updatedAt" : "2016-03-12T23:06:38.023945"},
            {"joke_id" : "def", "categories" : [], "value" : "...", "createdAt" : "2016-03-12T04:17:12.779747", "updatedAt" : "2016-03-12T23:06:38.023945"},
            {"joke_id" : "ghi", "categories" : [], "value" : "...", "createdAt" : "2016-03-12T04:17:12.779747", "updatedAt" : "2016-03-12T23:06:38.023945"},
        ]
    }';

    CREATE OR REPLACE FUNCTION find_jokes_by_query(
        query   VARCHAR,
        options JSON DEFAULT '{ "limit": null, "offset": 0 }'
    ) RETURNS json AS $$
        WITH total AS (
            SELECT count(*) FROM joke WHERE lower(value) LIKE '%' || lower(find_jokes_by_query.query) || '%'
        )
        SELECT
            json_build_object(
                'total',  (SELECT * FROM total),
                'result', json_agg(
                    get_joke(result.joke_id)
                )
            )
        FROM (
            SELECT
                joke_id
            FROM
                joke
            WHERE
                lower(value) LIKE '%' || lower(find_jokes_by_query.query) || '%'
            LIMIT
                CASE
                    WHEN (find_jokes_by_query.options->>'limit')::text IS NULL
                    THEN null
                    ELSE (find_jokes_by_query.options->>'limit')::integer
            END
            OFFSET
                CASE
                    WHEN (find_jokes_by_query.options->>'offset')::text IS NULL
                    THEN 0
                    ELSE (find_jokes_by_query.options->>'offset')::integer
            END
        ) AS result;
    $$ LANGUAGE sql;
    COMMENT ON FUNCTION find_jokes_by_query(VARCHAR, JSON) IS 'Find jokes by a given query.';

    CREATE OR REPLACE FUNCTION get_auth_provider(
        auth_provider_id INTEGER
    ) RETURNS json AS $$
        SELECT
            JSON_BUILD_OBJECT (
                'createdAt', ap.created_at,
                'id',        ap.auth_provider_id,
                'meta',      ap.meta,
                'name',      ap.name,
                'slug',      ap.slug,
                'updatedAt', ap.updated_at
            ) as auth_provider
        FROM
            auth_provider AS ap
        WHERE
            ap.auth_provider_id = get_auth_provider.auth_provider_id;
    $$ LANGUAGE sql;
    COMMENT ON FUNCTION get_auth_provider(INTEGER) IS 'Get a auth provider by a given auth provider id.';

    CREATE OR REPLACE FUNCTION get_joke_by_value(
        "value" VARCHAR
    ) RETURNS json AS $$
        SELECT
            get_joke(joke_id)
        FROM
            joke
        WHERE
            value = get_joke_by_value.value;
    $$ LANGUAGE sql;
    COMMENT ON FUNCTION get_joke_by_value(VARCHAR) IS 'Get a joke by value.';

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

    CREATE OR REPLACE FUNCTION get_joke_window_by_joke_id(
        joke_id SLUGID
    ) RETURNS json AS $$

    WITH joke AS (
        SELECT
            joke_id,
            ROW_NUMBER () OVER (ORDER BY joke.created_at ASC, joke.joke_id ASC) AS row_number
        FROM joke
    ), current AS (
        SELECT * FROM joke WHERE joke_id = get_joke_window_by_joke_id.joke_id LIMIT 1
    ), prev AS (
        SELECT
          (CASE
              WHEN (SELECT min(row_number) FROM joke) >= current.row_number - 1
              THEN (SELECT joke_id FROM joke WHERE row_number = (SELECT max(row_number) FROM joke))
              ELSE (SELECT joke_id FROM joke WHERE row_number = current.row_number - 1)
          END) AS joke_id
        FROM joke, current LIMIT 1
    ), next AS (
        SELECT
          (CASE
              WHEN (SELECT max(row_number) FROM joke) <= current.row_number + 1
              THEN (SELECT joke_id FROM joke WHERE row_number = (SELECT min(row_number) FROM joke))
              ELSE (SELECT joke_id FROM joke WHERE row_number = current.row_number + 1)
          END) AS joke_id
          FROM joke, current LIMIT 1
    )
    SELECT
        JSON_BUILD_OBJECT (
            'current',  get_joke(current.joke_id),
            'next',     get_joke(next.joke_id),
            'previous', get_joke(prev.joke_id)
        )
    FROM current, prev, next;
    $$ LANGUAGE sql;
    COMMENT ON FUNCTION get_joke_window_by_joke_id(SLUGID) IS 'Get a joke by a given id including the previous and next joke.';

    CREATE OR REPLACE FUNCTION insert_auth_provider(
        name VARCHAR,
        slug VARCHAR,
        meta JSONB
    ) RETURNS json AS $$
        INSERT INTO auth_provider (
            name,
            slug,
            meta
        )
        VALUES (
            insert_auth_provider.name,
            insert_auth_provider.slug,
            insert_auth_provider.meta
        )
        RETURNING get_auth_provider(auth_provider.auth_provider_id);
    $$ LANGUAGE sql;
    COMMENT ON FUNCTION insert_auth_provider(VARCHAR, VARCHAR, JSONB) IS 'Insert an auth provider.';

    CREATE OR REPLACE FUNCTION insert_joke(
        joke_id    SLUGID,
        categories JSONB,
        value      VARCHAR
    ) RETURNS json AS $$
        INSERT INTO joke (
            joke_id,
            categories,
            value
        )
        VALUES (
            insert_joke.joke_id,
            insert_joke.categories,
            insert_joke.value
        )
        RETURNING get_joke(insert_joke.joke_id);
    $$ LANGUAGE sql;
    COMMENT ON FUNCTION insert_joke(SLUGID, JSONB, VARCHAR) IS 'Insert a joke.';

    CREATE OR REPLACE FUNCTION paginate_jokes(
        size     integer DEFAULT 500,
        start    integer DEFAULT 0,
        category varchar DEFAULT NULL
    ) RETURNS json AS $$
        WITH total_count AS (
            SELECT
                count(*)
            FROM
                joke
            WHERE
                CASE
                    WHEN paginate_jokes.category IS NOT NULL
                    THEN categories IS NOT NULL AND categories ?| array[ paginate_jokes.category ]
                    ELSE true
                END
        )
        SELECT
            JSON_BUILD_OBJECT (
                'total', ( SELECT * FROM total_count ),
                'count', count(jokes),
                'items', JSON_AGG(
                    get_joke(joke_id)
                )
            )
        FROM (
            SELECT
                joke_id
            FROM
                joke
            WHERE
                CASE
                    WHEN paginate_jokes.category IS NOT NULL
                    THEN categories IS NOT NULL AND categories ?| array[ paginate_jokes.category ]
                    ELSE true
                END
            LIMIT
                paginate_jokes.size
            OFFSET
                paginate_jokes.start
        ) as jokes;
    $$ LANGUAGE sql;
    COMMENT ON FUNCTION paginate_jokes(INTEGER, INTEGER, VARCHAR) IS 'Get a subset of jokes defined by a given SIZE and START and an optional category.';

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

    CREATE OR REPLACE FUNCTION update_auth_provider(
        auth_provider_id INTEGER,
        name             VARCHAR,
        meta             JSONB,
        slug             VARCHAR
    ) RETURNS json AS $$
        UPDATE auth_provider SET
            name = update_auth_provider.name,
            meta = update_auth_provider.meta,
            slug = update_auth_provider.slug
        WHERE
            auth_provider_id = update_auth_provider.auth_provider_id
        RETURNING
            get_auth_provider(update_auth_provider.auth_provider_id);
    $$ LANGUAGE sql;
    COMMENT ON FUNCTION update_auth_provider(INTEGER, VARCHAR, JSONB, VARCHAR) IS 'Update an auth provider.';

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

COMMIT TRANSACTION;

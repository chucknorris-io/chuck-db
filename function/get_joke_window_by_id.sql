CREATE OR REPLACE FUNCTION get_joke_window_by_joke_id(
    joke_id SLUGID
) RETURNS json AS $$

    SELECT
        JSON_BUILD_OBJECT (
             'current',  get_joke(current),
             'next',     CASE WHEN next IS NULL
                             THEN get_first_joke()
                             ELSE get_joke(next)
                        END,
            'previous', CASE WHEN prev IS NULL
                             THEN get_last_joke()
                             ELSE get_joke(prev)
                        END
        )
    FROM
        (
            SELECT
                joke_id AS current,
                lead (j.joke_id) OVER (ORDER BY j.created_at desc, j.joke_id ASC) AS next,
                lag  (j.joke_id) OVER (ORDER BY j.created_at desc, j.joke_id ASC) AS prev
            FROM joke AS j
        ) AS jokes
    WHERE
        get_joke_window_by_joke_id.joke_id IN (current, prev, next) LIMIT 1 OFFSET 1;

$$ LANGUAGE sql;

COMMENT ON FUNCTION get_joke_window_by_joke_id(SLUGID) IS 'Get a joke by a given id including the previous and next joke.';  
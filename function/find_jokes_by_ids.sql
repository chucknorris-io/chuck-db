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
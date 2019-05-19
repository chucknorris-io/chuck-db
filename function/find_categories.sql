CREATE OR REPLACE FUNCTION find_categories() RETURNS json AS
$$

(SELECT array_to_json(array_agg(row_to_json(t)))
 FROM (
          SELECT j.categories ->> 0 AS "name",
                 count(j.joke_id)   AS "count"
          FROM joke AS j
          WHERE j.categories IS NOT NULL
          GROUP BY j.categories ->> 0
          ORDER BY count(j.joke_id) DESC
      ) t);

$$ LANGUAGE sql;

COMMENT ON FUNCTION find_categories() IS 'Get categories with joke count.';

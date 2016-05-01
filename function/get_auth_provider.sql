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
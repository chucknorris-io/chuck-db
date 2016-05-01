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
-- Snowflake Queries for Flattening Nested JSON Data
-- These queries work with the JSON data loaded into the JSON_DATA_TABLE

-- ========================================
-- 1. BASIC QUERY - Extract top-level fields
-- ========================================

SELECT
    RAW_DATA:id::NUMBER as event_id,
    RAW_DATA:timestamp::TIMESTAMP as event_timestamp,
    RAW_DATA:user.name::STRING as user_name,
    RAW_DATA:user.email::STRING as user_email,
    RAW_DATA:event.type::STRING as event_type,
    LOADED_AT,
    FILENAME
FROM JSON_DATA_TABLE
ORDER BY event_id;

-- ========================================
-- 2. FLATTEN NESTED OBJECTS - User Profile
-- ========================================

SELECT
    RAW_DATA:id::NUMBER as event_id,
    RAW_DATA:user.user_id::NUMBER as user_id,
    RAW_DATA:user.name::STRING as user_name,
    RAW_DATA:user.email::STRING as user_email,
    RAW_DATA:user.profile.age::NUMBER as user_age,
    RAW_DATA:user.profile.location::STRING as user_location,
    RAW_DATA:user.profile.preferences.theme::STRING as preferred_theme,
    RAW_DATA:user.profile.preferences.language::STRING as preferred_language,
    RAW_DATA:user.profile.preferences.notifications::BOOLEAN as notifications_enabled
FROM JSON_DATA_TABLE
ORDER BY event_id;

-- ========================================
-- 3. FLATTEN ARRAYS - Using LATERAL FLATTEN
-- ========================================

-- Extract each tag as a separate row
SELECT
    RAW_DATA:id::NUMBER as event_id,
    RAW_DATA:user.name::STRING as user_name,
    f.value::STRING as tag
FROM JSON_DATA_TABLE,
LATERAL FLATTEN(input => RAW_DATA:tags) f
ORDER BY event_id, tag;

-- ========================================
-- 4. COMPLEX NESTED EXTRACTION - Purchase Events
-- ========================================

SELECT
    RAW_DATA:id::NUMBER as event_id,
    RAW_DATA:timestamp::TIMESTAMP as event_timestamp,
    RAW_DATA:user.name::STRING as customer_name,
    RAW_DATA:event.type::STRING as event_type,

    -- Product details
    RAW_DATA:event.details.product_id::STRING as product_id,
    RAW_DATA:event.details.product_name::STRING as product_name,
    RAW_DATA:event.details.price::NUMBER(10,2) as original_price,
    RAW_DATA:event.details.currency::STRING as currency,

    -- Discount details
    RAW_DATA:event.details.discount.code::STRING as discount_code,
    RAW_DATA:event.details.discount.amount::NUMBER(10,2) as discount_amount,
    RAW_DATA:event.details.discount.percentage::NUMBER as discount_percentage,

    -- Calculated final price
    (RAW_DATA:event.details.price::NUMBER - RAW_DATA:event.details.discount.amount::NUMBER) as final_price,

    -- Shipping details
    RAW_DATA:event.shipping.method::STRING as shipping_method,
    RAW_DATA:event.shipping.address.city::STRING as shipping_city,
    RAW_DATA:event.shipping.address.state::STRING as shipping_state,
    RAW_DATA:event.shipping.estimated_delivery::DATE as estimated_delivery,

    -- Metadata
    RAW_DATA:metadata.source::STRING as data_source,
    RAW_DATA:metadata.version::STRING as app_version

FROM JSON_DATA_TABLE
WHERE RAW_DATA:event.type::STRING = 'purchase'
ORDER BY event_id;

-- ========================================
-- 5. AGGREGATE ANALYSIS - User Behavior Summary
-- ========================================

SELECT
    RAW_DATA:user.user_id::NUMBER as user_id,
    RAW_DATA:user.name::STRING as user_name,
    RAW_DATA:user.profile.location::STRING as location,
    COUNT(*) as total_events,

    -- Count events by type
    SUM(CASE WHEN RAW_DATA:event.type::STRING = 'purchase' THEN 1 ELSE 0 END) as purchase_events,
    SUM(CASE WHEN RAW_DATA:event.type::STRING = 'page_view' THEN 1 ELSE 0 END) as page_view_events,

    -- Calculate total spent (only for purchase events)
    SUM(
        CASE WHEN RAW_DATA:event.type::STRING = 'purchase'
        THEN (RAW_DATA:event.details.price::NUMBER - COALESCE(RAW_DATA:event.details.discount.amount::NUMBER, 0))
        ELSE 0 END
    ) as total_spent,

    MIN(RAW_DATA:timestamp::TIMESTAMP) as first_event,
    MAX(RAW_DATA:timestamp::TIMESTAMP) as last_event

FROM JSON_DATA_TABLE
GROUP BY user_id, user_name, location
ORDER BY total_spent DESC;

-- ========================================
-- 6. CREATE A VIEW - Flattened Product Purchases
-- ========================================

CREATE OR REPLACE VIEW PURCHASE_EVENTS_FLATTENED AS
SELECT
    RAW_DATA:id::NUMBER as event_id,
    RAW_DATA:timestamp::TIMESTAMP as purchase_timestamp,
    RAW_DATA:user.user_id::NUMBER as customer_id,
    RAW_DATA:user.name::STRING as customer_name,
    RAW_DATA:user.email::STRING as customer_email,
    RAW_DATA:user.profile.location::STRING as customer_location,

    RAW_DATA:event.details.product_id::STRING as product_id,
    RAW_DATA:event.details.product_name::STRING as product_name,
    RAW_DATA:event.details.price::NUMBER(10,2) as original_price,
    RAW_DATA:event.details.discount.amount::NUMBER(10,2) as discount_amount,
    (RAW_DATA:event.details.price::NUMBER - COALESCE(RAW_DATA:event.details.discount.amount::NUMBER, 0)) as final_price,
    RAW_DATA:event.details.currency::STRING as currency,

    RAW_DATA:event.shipping.method::STRING as shipping_method,
    RAW_DATA:event.shipping.address.city::STRING as shipping_city,
    RAW_DATA:event.shipping.address.state::STRING as shipping_state,
    RAW_DATA:event.shipping.estimated_delivery::DATE as estimated_delivery,

    LOADED_AT as data_loaded_at,
    FILENAME as source_file

FROM JSON_DATA_TABLE
WHERE RAW_DATA:event.type::STRING = 'purchase';

-- ========================================
-- 7. WORKING WITH NULL VALUES AND CONDITIONALS
-- ========================================

SELECT
    RAW_DATA:id::NUMBER as event_id,
    RAW_DATA:user.name::STRING as user_name,
    RAW_DATA:event.type::STRING as event_type,

    -- Handle optional fields with COALESCE
    COALESCE(RAW_DATA:event.details.product_name::STRING, 'N/A') as product_name,
    COALESCE(RAW_DATA:event.details.price::NUMBER, 0) as price,

    -- Conditional logic based on JSON content
    CASE
        WHEN RAW_DATA:event.type::STRING = 'purchase' THEN 'Revenue Event'
        WHEN RAW_DATA:event.type::STRING = 'page_view' THEN 'Engagement Event'
        ELSE 'Other Event'
    END as event_category,

    -- Check if nested field exists
    IFF(RAW_DATA:event.details.discount IS NOT NULL, 'Has Discount', 'No Discount') as discount_status,

    -- Extract array length
    ARRAY_SIZE(RAW_DATA:tags) as tag_count

FROM JSON_DATA_TABLE
ORDER BY event_id;

-- ========================================
-- 8. PERFORMANCE TIP - Create a materialized view for frequent queries
-- ========================================

-- For frequently accessed flattened data, create a materialized view
CREATE OR REPLACE SECURE VIEW USER_EVENTS_SUMMARY AS
SELECT
    RAW_DATA:user.user_id::NUMBER as user_id,
    RAW_DATA:user.name::STRING as user_name,
    RAW_DATA:user.email::STRING as user_email,
    RAW_DATA:user.profile.location::STRING as location,
    RAW_DATA:user.profile.age::NUMBER as age,
    RAW_DATA:event.type::STRING as event_type,
    RAW_DATA:event.category::STRING as event_category,
    RAW_DATA:timestamp::TIMESTAMP as event_timestamp,
    RAW_DATA:metadata.source::STRING as data_source,
    LOADED_AT,
    FILENAME
FROM JSON_DATA_TABLE;

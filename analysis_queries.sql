-- QUERY 1: TOTAL CARDS IN DATASET
SELECT COUNT('card') AS total_cards 
FROM pokemon_prices;

-- QUERY 2: TOP 10 MOST EXPENSIVE UNGRADED CARDS
SELECT DISTINCT TOP 10 [Set], Card, Ungraded
FROM pokemon_prices
WHERE Ungraded IS NOT NULL AND 
(Card NOT LIKE '%Box%' AND Card NOT LIKE '%Pack%')
ORDER BY Ungraded DESC;

-- QUERY 3: GRADING ROI ANALYSIS WITH OUTLIER FLAG
-- PSA 10 is the highest grade a card can receive from Professional Sports Authenticator
-- This query calculates how much more a card is worth when graded PSA 10 vs ungraded
-- Example: if Charizard ungraded = $100 and PSA 10 = $500, the multiplier = 5.0x
-- A high multiplier = strong financial incentive to get that card professionally graded
-- NOTE: We don't have sales volume data, so we flag statistical outliers instead
-- Cards flagged as 'Outlier' have a multiplier 10x above the dataset average
-- These likely reflect a single rare sale and should be verified manually before acting on them

SELECT DISTINCT
    [Set], 
    Card, 
    Ungraded, 
    [PSA_10],
    ROUND(CAST([PSA_10] AS FLOAT) / NULLIF(CAST(Ungraded AS FLOAT), 0), 2) AS psa10_multiplier,

    -- Data quality flag: identifies cards with abnormally high multipliers
    -- These are not necessarily wrong, but should be treated with caution
    CASE 
        WHEN ROUND(CAST([PSA_10] AS FLOAT) / NULLIF(CAST(Ungraded AS FLOAT), 0), 2) > (
            SELECT AVG(CAST([PSA_10] AS FLOAT) / NULLIF(CAST(Ungraded AS FLOAT), 0)) * 10
            FROM pokemon_prices
            WHERE Ungraded IS NOT NULL 
            AND [PSA_10] IS NOT NULL
            AND Ungraded > 1
            AND Card NOT LIKE '%Box%' 
            AND Card NOT LIKE '%Pack%'
        )
        THEN 'Outlier - Verify Manually'
        ELSE 'Reliable'
    END AS data_quality_flag
FROM pokemon_prices
WHERE Ungraded IS NOT NULL AND [PSA_10] IS NOT NULL
AND Ungraded > 1
AND (Card NOT LIKE '%Box%' AND Card NOT LIKE '%Pack%')
ORDER BY psa10_multiplier DESC;

-- QUERY 4: RELIABLE GRADING ROI (NO OUTLIERS)
-- These are cards where grading to PSA 10 is genuinely worth it based on consistent market data

SELECT DISTINCT TOP 20 
    [Set], 
    Card, 
    Ungraded, 
    [PSA_10],
    ROUND(CAST([PSA_10] AS FLOAT) / NULLIF(CAST(Ungraded AS FLOAT), 0), 2) AS psa10_multiplier

FROM pokemon_prices
WHERE Ungraded IS NOT NULL AND [PSA_10] IS NOT NULL
AND Ungraded > 1
AND (Card NOT LIKE '%Box%' AND Card NOT LIKE '%Pack%')

-- Exclude outliers by capping at 10x the average multiplier
AND (CAST([PSA_10] AS FLOAT) / NULLIF(CAST(Ungraded AS FLOAT), 0)) <= (
    SELECT AVG(CAST([PSA_10] AS FLOAT) / NULLIF(CAST(Ungraded AS FLOAT), 0)) * 10
    FROM pokemon_prices
    WHERE Ungraded IS NOT NULL 
    AND [PSA_10] IS NOT NULL
    AND Ungraded > 1
    AND Card NOT LIKE '%Box%' 
    AND Card NOT LIKE '%Pack%'
)

ORDER BY psa10_multiplier DESC;


-- QUERY 5: CARDS WHERE GRADING ADDS OVER $500 IN VALUE
-- Includes the difference between PSA 10 and Grade 9 value gained
SELECT DISTINCT [Set], Card, Ungraded, [Grade_9], [PSA_10],
    ROUND([PSA_10] - Ungraded, 2) AS psa10_value_gained,
    ROUND([Grade_9] - Ungraded, 2) AS grade9_value_gained,
    ROUND([PSA_10] - [Grade_9], 2) AS psa10_vs_grade9_diff
FROM pokemon_prices
WHERE Ungraded IS NOT NULL 
AND [PSA_10] IS NOT NULL 
AND [Grade_9] IS NOT NULL
AND ([PSA_10] - Ungraded > 500 OR [Grade_9] - Ungraded > 500)
AND (Card NOT LIKE '%Box%' AND Card NOT LIKE '%Pack%')
ORDER BY psa10_value_gained DESC;

-- QUERY 6: AVERAGE VALUE ADDED BY GRADING ACROSS ALL CARDS
-- Grade 9 is more realistic to achieve than PSA 10
SELECT DISTINCT
    ROUND(AVG([Grade_9] - Ungraded), 2) AS avg_value_added_grade9,
    ROUND(AVG([PSA_10] - Ungraded), 2) AS avg_value_added_psa10,
    ROUND(AVG([PSA_10] - [Grade_9]), 2) AS avg_extra_value_psa10_vs_grade9,
    COUNT(*) AS cards_analyzed
FROM pokemon_prices
WHERE Ungraded IS NOT NULL 
AND [PSA_10] IS NOT NULL 
AND [Grade_9] IS NOT NULL
AND (Card NOT LIKE '%Box%' AND Card NOT LIKE '%Pack%');

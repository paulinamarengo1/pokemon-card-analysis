-- Total number of cards scraped
SELECT COUNT('card') AS total_cards 
FROM pokemon_prices;

-- Top 10 most expensive ungraded cards (excluding sealed products)
SELECT TOP 10 [Set], Card, Ungraded
FROM pokemon_prices
WHERE Ungraded IS NOT NULL AND 
(Card NOT LIKE '%Box%' AND Card NOT LIKE '%Pack%')
ORDER BY Ungraded DESC;

-- Grading ROI — PSA 10 price divided by ungraded price
-- Higher multiplier means more financial upside to getting the card graded
SELECT TOP 20 [Set], Card, Ungraded, [PSA_10],
    ROUND(CAST([PSA_10] AS FLOAT) / NULLIF(CAST(Ungraded AS FLOAT), 0), 2) AS psa10_multiplier
FROM pokemon_prices
WHERE Ungraded IS NOT NULL AND [PSA_10] IS NOT NULL
AND Ungraded > 1
AND (Card NOT LIKE '%Box%' AND Card NOT LIKE '%Pack%')
ORDER BY psa10_multiplier DESC;

-- Cards where grading to PSA 10 or Grade 9 adds over $500 in value
-- Includes the difference between PSA 10 and Grade 9 value gained
SELECT [Set], Card, Ungraded, [Grade_9], [PSA_10],
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

-- Average value added by grading across all cards
-- Grade 9 is more realistic to achieve than PSA 10
SELECT 
    ROUND(AVG([Grade_9] - Ungraded), 2) AS avg_value_added_grade9,
    ROUND(AVG([PSA_10] - Ungraded), 2) AS avg_value_added_psa10,
    ROUND(AVG([PSA_10] - [Grade_9]), 2) AS avg_extra_value_psa10_vs_grade9,
    COUNT(*) AS cards_analyzed
FROM pokemon_prices
WHERE Ungraded IS NOT NULL 
AND [PSA_10] IS NOT NULL 
AND [Grade_9] IS NOT NULL
AND (Card NOT LIKE '%Box%' AND Card NOT LIKE '%Pack%');

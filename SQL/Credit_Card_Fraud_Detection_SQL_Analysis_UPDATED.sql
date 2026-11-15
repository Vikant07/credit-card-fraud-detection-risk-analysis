/*
PROJECT: Credit Card Fraud Detection & Risk Analysis
DIALECT: MySQL 8.0+

WORKFLOW
1. Your original CSV is already imported as projectdata.credit_card_fraud_detection_2026.
2. Select the projectdata database, then run this script.
3. The script creates projectdata.fraud_clean as a VIEW over your source table.
4. It does not overwrite or modify projectdata.credit_card_fraud_detection_2026.
5. Run the analysis queries section by section and interpret the results.

IMPORTANT DATA NOTES
- The supplied data profile says 42 columns, but its listed field names count to
  43. This script uses the full list of 43 field names from the profile. Compare
  the actual CSV header with the SELECT list below before running the view.
- The profile describes browser blanks as not applicable for in-store/ATM
  transactions. The view labels these "Not Applicable"; other blank browser
  values become "Unknown".
- fraud_type and fraud_amount_lost are outcomes, not valid predictors of is_fraud.
  Do not use them as input features in a predictive model (target leakage).
- The profile reports dates through 2027-01-01. Since this project is being
  analysed before that date, check the future-date validation query below.
- This is descriptive SQL analysis. Validate profile-level statistics against
  the actual CSV; do not assume profiler summaries are raw-data results.

SOURCE TABLE
Database: projectdata
Table: credit_card_fraud_detection_2026
Expected column names are listed in the CREATE VIEW section.
This source table is treated as raw data and is not modified by this script.
*/

-- =========================================================
-- 0. DATABASE
-- =========================================================
USE projectdata;

-- IMPORTANT:
-- The source table already exists as projectdata.credit_card_fraud_detection_2026.
-- Do not run a destructive DROP, UPDATE, or DELETE on the source table.


-- =========================================================
-- 1. CREATE CLEANING VIEW
-- =========================================================
-- This view:
--   * trims text fields and converts empty strings to NULL,
--   * converts numeric text to numeric data types,
--   * converts common TRUE/FALSE values to 1/0,
--   * parses transaction_datetime,
--   * handles browser blanks according to transaction channel.
--
-- If your imported CSV has different column names, adjust them here.

CREATE OR REPLACE VIEW projectdata.fraud_clean AS
SELECT
    NULLIF(TRIM(transaction_id), '') AS transaction_id,
    NULLIF(TRIM(customer_id), '') AS customer_id,
    NULLIF(TRIM(card_id), '') AS card_id,
    NULLIF(TRIM(merchant_id), '') AS merchant_id,

    CASE
        WHEN NULLIF(TRIM(transaction_datetime), '') IS NULL THEN NULL
        ELSE CAST(
            REPLACE(LEFT(TRIM(transaction_datetime), 19), 'T', ' ')
            AS DATETIME
        )
    END AS transaction_datetime,

    CAST(NULLIF(TRIM(transaction_amount), '') AS DECIMAL(14,2))
        AS transaction_amount,

    NULLIF(TRIM(merchant_category), '') AS merchant_category,
    NULLIF(TRIM(merchant_country), '') AS merchant_country,

    CAST(NULLIF(TRIM(transaction_hour), '') AS UNSIGNED)
        AS transaction_hour,
    NULLIF(TRIM(transaction_day_of_week), '') AS transaction_day_of_week,

    CASE
        WHEN LOWER(TRIM(card_present)) IN ('1', 'true', 'yes', 'y') THEN 1
        WHEN LOWER(TRIM(card_present)) IN ('0', 'false', 'no', 'n') THEN 0
        ELSE NULL
    END AS card_present,

    CAST(NULLIF(TRIM(customer_age), '') AS UNSIGNED) AS customer_age,
    NULLIF(TRIM(customer_gender), '') AS customer_gender,
    NULLIF(TRIM(customer_state), '') AS customer_state,

    CAST(NULLIF(TRIM(account_age_days), '') AS UNSIGNED)
        AS account_age_days,
    CAST(NULLIF(TRIM(credit_limit), '') AS DECIMAL(14,2))
        AS credit_limit,
    CAST(NULLIF(TRIM(credit_score), '') AS UNSIGNED) AS credit_score,
    CAST(NULLIF(TRIM(num_cards_held), '') AS UNSIGNED) AS num_cards_held,

    CAST(NULLIF(TRIM(transactions_last_1h), '') AS UNSIGNED)
        AS transactions_last_1h,
    CAST(NULLIF(TRIM(transactions_last_24h), '') AS UNSIGNED)
        AS transactions_last_24h,
    CAST(NULLIF(TRIM(transactions_last_7d), '') AS UNSIGNED)
        AS transactions_last_7d,

    CAST(NULLIF(TRIM(amount_last_1h), '') AS DECIMAL(14,2))
        AS amount_last_1h,
    CAST(NULLIF(TRIM(amount_last_24h), '') AS DECIMAL(14,2))
        AS amount_last_24h,

    CAST(NULLIF(TRIM(days_since_last_transaction), '') AS DECIMAL(12,2))
        AS days_since_last_transaction,
    CAST(NULLIF(TRIM(distance_from_home_km), '') AS DECIMAL(12,2))
        AS distance_from_home_km,
    CAST(NULLIF(TRIM(distance_from_last_tx_km), '') AS DECIMAL(12,2))
        AS distance_from_last_tx_km,

    CASE
        WHEN LOWER(TRIM(international_transaction)) IN ('1', 'true', 'yes', 'y') THEN 1
        WHEN LOWER(TRIM(international_transaction)) IN ('0', 'false', 'no', 'n') THEN 0
        ELSE NULL
    END AS international_transaction,

    CASE
        WHEN LOWER(TRIM(high_risk_country)) IN ('1', 'true', 'yes', 'y') THEN 1
        WHEN LOWER(TRIM(high_risk_country)) IN ('0', 'false', 'no', 'n') THEN 0
        ELSE NULL
    END AS high_risk_country,

    CAST(NULLIF(TRIM(amount_vs_avg_ratio), '') AS DECIMAL(12,3))
        AS amount_vs_avg_ratio,

    CASE
        WHEN LOWER(TRIM(used_chip)) IN ('1', 'true', 'yes', 'y') THEN 1
        WHEN LOWER(TRIM(used_chip)) IN ('0', 'false', 'no', 'n') THEN 0
        ELSE NULL
    END AS used_chip,

    CASE
        WHEN LOWER(TRIM(used_pin)) IN ('1', 'true', 'yes', 'y') THEN 1
        WHEN LOWER(TRIM(used_pin)) IN ('0', 'false', 'no', 'n') THEN 0
        ELSE NULL
    END AS used_pin,

    NULLIF(TRIM(transaction_channel), '') AS transaction_channel,
    NULLIF(TRIM(device_type), '') AS device_type,

    CASE
        WHEN LOWER(TRIM(COALESCE(browser, ''))) IN
             ('', 'n/a', 'na', 'not applicable', 'none', 'null')
        THEN
            CASE
                WHEN LOWER(TRIM(COALESCE(transaction_channel, ''))) IN
                     ('in-store', 'in store', 'pos', 'atm', 'store', 'point of sale')
                THEN 'Not Applicable'
                ELSE 'Unknown'
            END
        ELSE TRIM(browser)
    END AS browser,

    CASE
        WHEN LOWER(TRIM(is_weekend)) IN ('1', 'true', 'yes', 'y') THEN 1
        WHEN LOWER(TRIM(is_weekend)) IN ('0', 'false', 'no', 'n') THEN 0
        ELSE NULL
    END AS is_weekend,

    CAST(NULLIF(TRIM(avg_transaction_amount_30d), '') AS DECIMAL(14,2))
        AS avg_transaction_amount_30d,
    CAST(NULLIF(TRIM(std_transaction_amount_30d), '') AS DECIMAL(14,2))
        AS std_transaction_amount_30d,

    CAST(NULLIF(TRIM(num_declined_last_30d), '') AS UNSIGNED)
        AS num_declined_last_30d,
    CAST(NULLIF(TRIM(num_chargebacks_ever), '') AS UNSIGNED)
        AS num_chargebacks_ever,

    NULLIF(TRIM(email_domain), '') AS email_domain,

    CASE
        WHEN LOWER(TRIM(is_fraud)) IN ('1', 'true', 'yes', 'y') THEN 1
        WHEN LOWER(TRIM(is_fraud)) IN ('0', 'false', 'no', 'n') THEN 0
        ELSE NULL
    END AS is_fraud,

    NULLIF(TRIM(fraud_type), '') AS fraud_type,

    CAST(NULLIF(TRIM(fraud_amount_lost), '') AS DECIMAL(14,2))
        AS fraud_amount_lost

FROM projectdata.credit_card_fraud_detection_2026;


-- =========================================================
-- 2. DATA UNDERSTANDING & QUALITY CHECKS
-- =========================================================

-- 2.1 Total rows and unique entities
SELECT
    COUNT(*) AS total_transactions,
    COUNT(DISTINCT transaction_id) AS unique_transaction_ids,
    COUNT(DISTINCT customer_id) AS unique_customers,
    COUNT(DISTINCT card_id) AS unique_cards,
    COUNT(DISTINCT merchant_id) AS unique_merchants
FROM fraud_clean;

-- 2.2 Duplicate transaction IDs
SELECT
    transaction_id,
    COUNT(*) AS occurrences
FROM fraud_clean
WHERE transaction_id IS NOT NULL
GROUP BY transaction_id
HAVING COUNT(*) > 1
ORDER BY occurrences DESC;

-- 2.3 Missing-value checks on important analysis fields
SELECT 'transaction_id' AS column_name, SUM(transaction_id IS NULL) AS missing_count FROM fraud_clean
UNION ALL SELECT 'transaction_datetime', SUM(transaction_datetime IS NULL) FROM fraud_clean
UNION ALL SELECT 'transaction_amount', SUM(transaction_amount IS NULL) FROM fraud_clean
UNION ALL SELECT 'merchant_category', SUM(merchant_category IS NULL) FROM fraud_clean
UNION ALL SELECT 'merchant_country', SUM(merchant_country IS NULL) FROM fraud_clean
UNION ALL SELECT 'transaction_channel', SUM(transaction_channel IS NULL) FROM fraud_clean
UNION ALL SELECT 'browser', SUM(browser IS NULL) FROM fraud_clean
UNION ALL SELECT 'is_fraud', SUM(is_fraud IS NULL) FROM fraud_clean;

-- 2.4 Invalid or unexpected values
SELECT
    SUM(transaction_amount < 0) AS negative_transaction_amounts,
    SUM(customer_age <= 0 OR customer_age > 120) AS unusual_customer_ages,
    SUM(credit_score < 300 OR credit_score > 850) AS unusual_credit_scores,
    SUM(transaction_hour < 0 OR transaction_hour > 23) AS invalid_transaction_hours,
    SUM(is_fraud NOT IN (0, 1)) AS invalid_fraud_flags
FROM fraud_clean;

-- 2.5 Check transaction date range and future-dated rows
SELECT
    MIN(transaction_datetime) AS first_transaction_datetime,
    MAX(transaction_datetime) AS last_transaction_datetime,
    SUM(transaction_datetime > NOW()) AS future_dated_transactions
FROM fraud_clean;

-- 2.6 Check target labels
SELECT
    is_fraud,
    COUNT(*) AS transaction_count
FROM fraud_clean
GROUP BY is_fraud
ORDER BY is_fraud;


-- =========================================================
-- 3. EXECUTIVE KPI SUMMARY
-- =========================================================
SELECT
    COUNT(*) AS total_transactions,
    COUNT(DISTINCT customer_id) AS unique_customers,
    COUNT(DISTINCT card_id) AS unique_cards,
    COUNT(DISTINCT merchant_id) AS unique_merchants,

    SUM(is_fraud = 1) AS fraud_transactions,
    SUM(is_fraud = 0) AS legitimate_transactions,

    ROUND(100.0 * SUM(is_fraud = 1) / NULLIF(COUNT(is_fraud), 0), 2)
        AS fraud_rate_pct,

    ROUND(SUM(transaction_amount), 2) AS total_transaction_value,
    ROUND(AVG(transaction_amount), 2) AS average_transaction_value,

    ROUND(SUM(CASE WHEN is_fraud = 1 THEN transaction_amount ELSE 0 END), 2)
        AS fraud_transaction_value,

    ROUND(SUM(CASE WHEN is_fraud = 1 THEN fraud_amount_lost ELSE 0 END), 2)
        AS reported_fraud_amount_lost,

    ROUND(AVG(CASE WHEN is_fraud = 1 THEN transaction_amount END), 2)
        AS average_fraud_transaction_value
FROM fraud_clean;


-- =========================================================
-- 4. FRAUD TREND ANALYSIS
-- =========================================================

-- 4.1 Monthly transaction and fraud trend
SELECT
    DATE_FORMAT(transaction_datetime, '%Y-%m') AS transaction_month,
    COUNT(*) AS total_transactions,
    SUM(is_fraud = 1) AS fraud_transactions,
    ROUND(100.0 * SUM(is_fraud = 1) / NULLIF(COUNT(is_fraud), 0), 2)
        AS fraud_rate_pct,
    ROUND(SUM(transaction_amount), 2) AS transaction_value,
    ROUND(SUM(CASE WHEN is_fraud = 1 THEN fraud_amount_lost ELSE 0 END), 2)
        AS reported_fraud_loss
FROM fraud_clean
GROUP BY DATE_FORMAT(transaction_datetime, '%Y-%m')
ORDER BY transaction_month;

-- 4.2 Fraud by hour of day
SELECT
    transaction_hour,
    COUNT(*) AS total_transactions,
    SUM(is_fraud = 1) AS fraud_transactions,
    ROUND(100.0 * SUM(is_fraud = 1) / NULLIF(COUNT(is_fraud), 0), 2)
        AS fraud_rate_pct
FROM fraud_clean
GROUP BY transaction_hour
ORDER BY transaction_hour;

-- 4.3 Fraud by day of week
SELECT
    transaction_day_of_week,
    COUNT(*) AS total_transactions,
    SUM(is_fraud = 1) AS fraud_transactions,
    ROUND(100.0 * SUM(is_fraud = 1) / NULLIF(COUNT(is_fraud), 0), 2)
        AS fraud_rate_pct
FROM fraud_clean
GROUP BY transaction_day_of_week
ORDER BY fraud_rate_pct DESC;

-- 4.4 Weekend versus weekday
SELECT
    CASE WHEN is_weekend = 1 THEN 'Weekend'
         WHEN is_weekend = 0 THEN 'Weekday'
         ELSE 'Unknown'
    END AS day_type,
    COUNT(*) AS total_transactions,
    SUM(is_fraud = 1) AS fraud_transactions,
    ROUND(100.0 * SUM(is_fraud = 1) / NULLIF(COUNT(is_fraud), 0), 2)
        AS fraud_rate_pct
FROM fraud_clean
GROUP BY day_type
ORDER BY fraud_rate_pct DESC;


-- =========================================================
-- 5. FRAUD BY MERCHANT, COUNTRY & CHANNEL
-- =========================================================

-- 5.1 Merchant category risk
SELECT
    merchant_category,
    COUNT(*) AS total_transactions,
    SUM(is_fraud = 1) AS fraud_transactions,
    ROUND(100.0 * SUM(is_fraud = 1) / NULLIF(COUNT(is_fraud), 0), 2)
        AS fraud_rate_pct,
    ROUND(AVG(transaction_amount), 2) AS average_transaction_amount
FROM fraud_clean
GROUP BY merchant_category
HAVING COUNT(*) >= 30
ORDER BY fraud_rate_pct DESC;

-- 5.2 Country risk
SELECT
    merchant_country,
    COUNT(*) AS total_transactions,
    SUM(is_fraud = 1) AS fraud_transactions,
    ROUND(100.0 * SUM(is_fraud = 1) / NULLIF(COUNT(is_fraud), 0), 2)
        AS fraud_rate_pct,
    ROUND(SUM(CASE WHEN is_fraud = 1 THEN fraud_amount_lost ELSE 0 END), 2)
        AS reported_fraud_loss
FROM fraud_clean
GROUP BY merchant_country
HAVING COUNT(*) >= 30
ORDER BY fraud_rate_pct DESC;

-- 5.3 High-risk-country flag
SELECT
    high_risk_country,
    COUNT(*) AS total_transactions,
    SUM(is_fraud = 1) AS fraud_transactions,
    ROUND(100.0 * SUM(is_fraud = 1) / NULLIF(COUNT(is_fraud), 0), 2)
        AS fraud_rate_pct
FROM fraud_clean
GROUP BY high_risk_country;

-- 5.4 Transaction channel
SELECT
    transaction_channel,
    COUNT(*) AS total_transactions,
    SUM(is_fraud = 1) AS fraud_transactions,
    ROUND(100.0 * SUM(is_fraud = 1) / NULLIF(COUNT(is_fraud), 0), 2)
        AS fraud_rate_pct,
    ROUND(AVG(transaction_amount), 2) AS average_transaction_amount
FROM fraud_clean
GROUP BY transaction_channel
ORDER BY fraud_rate_pct DESC;

-- 5.5 Device type
SELECT
    device_type,
    COUNT(*) AS total_transactions,
    SUM(is_fraud = 1) AS fraud_transactions,
    ROUND(100.0 * SUM(is_fraud = 1) / NULLIF(COUNT(is_fraud), 0), 2)
        AS fraud_rate_pct
FROM fraud_clean
GROUP BY device_type
ORDER BY fraud_rate_pct DESC;

-- 5.6 Browser (Unknown / Not Applicable categories are retained)
SELECT
    browser,
    COUNT(*) AS total_transactions,
    SUM(is_fraud = 1) AS fraud_transactions,
    ROUND(100.0 * SUM(is_fraud = 1) / NULLIF(COUNT(is_fraud), 0), 2)
        AS fraud_rate_pct
FROM fraud_clean
GROUP BY browser
HAVING COUNT(*) >= 30
ORDER BY fraud_rate_pct DESC;


-- =========================================================
-- 6. CUSTOMER & ACCOUNT RISK ANALYSIS
-- =========================================================

-- 6.1 Account age segments
SELECT
    CASE
        WHEN account_age_days < 90 THEN 'New: under 90 days'
        WHEN account_age_days < 365 THEN '90 days to under 1 year'
        WHEN account_age_days >= 365 THEN '1 year or more'
        ELSE 'Unknown'
    END AS account_age_segment,
    COUNT(*) AS total_transactions,
    SUM(is_fraud = 1) AS fraud_transactions,
    ROUND(100.0 * SUM(is_fraud = 1) / NULLIF(COUNT(is_fraud), 0), 2)
        AS fraud_rate_pct
FROM fraud_clean
GROUP BY account_age_segment
ORDER BY fraud_rate_pct DESC;

-- 6.2 Credit score bands
SELECT
    CASE
        WHEN credit_score < 580 THEN 'Below 580'
        WHEN credit_score < 670 THEN '580-669'
        WHEN credit_score < 740 THEN '670-739'
        WHEN credit_score < 800 THEN '740-799'
        WHEN credit_score >= 800 THEN '800+'
        ELSE 'Unknown'
    END AS credit_score_band,
    COUNT(*) AS total_transactions,
    SUM(is_fraud = 1) AS fraud_transactions,
    ROUND(100.0 * SUM(is_fraud = 1) / NULLIF(COUNT(is_fraud), 0), 2)
        AS fraud_rate_pct
FROM fraud_clean
GROUP BY credit_score_band
ORDER BY fraud_rate_pct DESC;

-- 6.3 Customer age bands
SELECT
    CASE
        WHEN customer_age < 25 THEN 'Under 25'
        WHEN customer_age < 35 THEN '25-34'
        WHEN customer_age < 45 THEN '35-44'
        WHEN customer_age < 55 THEN '45-54'
        WHEN customer_age >= 55 THEN '55+'
        ELSE 'Unknown'
    END AS customer_age_band,
    COUNT(*) AS total_transactions,
    SUM(is_fraud = 1) AS fraud_transactions,
    ROUND(100.0 * SUM(is_fraud = 1) / NULLIF(COUNT(is_fraud), 0), 2)
        AS fraud_rate_pct
FROM fraud_clean
GROUP BY customer_age_band
ORDER BY fraud_rate_pct DESC;

-- 6.4 Previous chargebacks
SELECT
    CASE
        WHEN num_chargebacks_ever = 0 THEN 'No previous chargebacks'
        WHEN num_chargebacks_ever = 1 THEN '1 previous chargeback'
        WHEN num_chargebacks_ever >= 2 THEN '2+ previous chargebacks'
        ELSE 'Unknown'
    END AS chargeback_history,
    COUNT(*) AS total_transactions,
    SUM(is_fraud = 1) AS fraud_transactions,
    ROUND(100.0 * SUM(is_fraud = 1) / NULLIF(COUNT(is_fraud), 0), 2)
        AS fraud_rate_pct
FROM fraud_clean
GROUP BY chargeback_history
ORDER BY fraud_rate_pct DESC;

-- 6.5 Number of declined transactions in prior 30 days
SELECT
    CASE
        WHEN num_declined_last_30d = 0 THEN '0 declines'
        WHEN num_declined_last_30d BETWEEN 1 AND 2 THEN '1-2 declines'
        WHEN num_declined_last_30d BETWEEN 3 AND 5 THEN '3-5 declines'
        WHEN num_declined_last_30d > 5 THEN 'More than 5 declines'
        ELSE 'Unknown'
    END AS decline_history,
    COUNT(*) AS total_transactions,
    SUM(is_fraud = 1) AS fraud_transactions,
    ROUND(100.0 * SUM(is_fraud = 1) / NULLIF(COUNT(is_fraud), 0), 2)
        AS fraud_rate_pct
FROM fraud_clean
GROUP BY decline_history
ORDER BY fraud_rate_pct DESC;


-- =========================================================
-- 7. TRANSACTION BEHAVIOUR & ANOMALY ANALYSIS
-- =========================================================

-- 7.1 Transactions in the previous hour
SELECT
    CASE
        WHEN transactions_last_1h = 0 THEN '0'
        WHEN transactions_last_1h = 1 THEN '1'
        WHEN transactions_last_1h = 2 THEN '2'
        WHEN transactions_last_1h >= 3 THEN '3+'
        ELSE 'Unknown'
    END AS transactions_previous_hour,
    COUNT(*) AS total_transactions,
    SUM(is_fraud = 1) AS fraud_transactions,
    ROUND(100.0 * SUM(is_fraud = 1) / NULLIF(COUNT(is_fraud), 0), 2)
        AS fraud_rate_pct
FROM fraud_clean
GROUP BY transactions_previous_hour
ORDER BY fraud_rate_pct DESC;

-- 7.2 Amount compared with customer's 30-day average
SELECT
    CASE
        WHEN amount_vs_avg_ratio < 1 THEN 'Below average'
        WHEN amount_vs_avg_ratio < 2 THEN '1x to under 2x'
        WHEN amount_vs_avg_ratio < 5 THEN '2x to under 5x'
        WHEN amount_vs_avg_ratio >= 5 THEN '5x or more'
        ELSE 'Unknown'
    END AS amount_vs_average_band,
    COUNT(*) AS total_transactions,
    SUM(is_fraud = 1) AS fraud_transactions,
    ROUND(100.0 * SUM(is_fraud = 1) / NULLIF(COUNT(is_fraud), 0), 2)
        AS fraud_rate_pct,
    ROUND(AVG(transaction_amount), 2) AS average_transaction_amount
FROM fraud_clean
GROUP BY amount_vs_average_band
ORDER BY fraud_rate_pct DESC;

-- 7.3 Distance from home
SELECT
    CASE
        WHEN distance_from_home_km < 10 THEN 'Under 10 km'
        WHEN distance_from_home_km < 50 THEN '10-49 km'
        WHEN distance_from_home_km < 100 THEN '50-99 km'
        WHEN distance_from_home_km >= 100 THEN '100+ km'
        ELSE 'Unknown'
    END AS distance_from_home_band,
    COUNT(*) AS total_transactions,
    SUM(is_fraud = 1) AS fraud_transactions,
    ROUND(100.0 * SUM(is_fraud = 1) / NULLIF(COUNT(is_fraud), 0), 2)
        AS fraud_rate_pct
FROM fraud_clean
GROUP BY distance_from_home_band
ORDER BY fraud_rate_pct DESC;

-- 7.4 Distance from previous transaction
SELECT
    CASE
        WHEN distance_from_last_tx_km < 10 THEN 'Under 10 km'
        WHEN distance_from_last_tx_km < 100 THEN '10-99 km'
        WHEN distance_from_last_tx_km < 500 THEN '100-499 km'
        WHEN distance_from_last_tx_km >= 500 THEN '500+ km'
        ELSE 'Unknown'
    END AS distance_from_previous_tx_band,
    COUNT(*) AS total_transactions,
    SUM(is_fraud = 1) AS fraud_transactions,
    ROUND(100.0 * SUM(is_fraud = 1) / NULLIF(COUNT(is_fraud), 0), 2)
        AS fraud_rate_pct
FROM fraud_clean
GROUP BY distance_from_previous_tx_band
ORDER BY fraud_rate_pct DESC;


-- =========================================================
-- 8. PAYMENT AUTHENTICATION ANALYSIS
-- =========================================================

-- 8.1 Card-present versus card-not-present
SELECT
    CASE WHEN card_present = 1 THEN 'Card Present'
         WHEN card_present = 0 THEN 'Card Not Present'
         ELSE 'Unknown'
    END AS card_presence,
    COUNT(*) AS total_transactions,
    SUM(is_fraud = 1) AS fraud_transactions,
    ROUND(100.0 * SUM(is_fraud = 1) / NULLIF(COUNT(is_fraud), 0), 2)
        AS fraud_rate_pct
FROM fraud_clean
GROUP BY card_presence
ORDER BY fraud_rate_pct DESC;

-- 8.2 Chip usage
SELECT
    used_chip,
    COUNT(*) AS total_transactions,
    SUM(is_fraud = 1) AS fraud_transactions,
    ROUND(100.0 * SUM(is_fraud = 1) / NULLIF(COUNT(is_fraud), 0), 2)
        AS fraud_rate_pct
FROM fraud_clean
GROUP BY used_chip;

-- 8.3 PIN usage
SELECT
    used_pin,
    COUNT(*) AS total_transactions,
    SUM(is_fraud = 1) AS fraud_transactions,
    ROUND(100.0 * SUM(is_fraud = 1) / NULLIF(COUNT(is_fraud), 0), 2)
        AS fraud_rate_pct
FROM fraud_clean
GROUP BY used_pin;

-- 8.4 International versus domestic transactions
SELECT
    international_transaction,
    COUNT(*) AS total_transactions,
    SUM(is_fraud = 1) AS fraud_transactions,
    ROUND(100.0 * SUM(is_fraud = 1) / NULLIF(COUNT(is_fraud), 0), 2)
        AS fraud_rate_pct,
    ROUND(SUM(CASE WHEN is_fraud = 1 THEN fraud_amount_lost ELSE 0 END), 2)
        AS reported_fraud_loss
FROM fraud_clean
GROUP BY international_transaction;


-- =========================================================
-- 9. FRAUD TYPE, MERCHANT & CUSTOMER INVESTIGATION
-- =========================================================

-- 9.1 Fraud type distribution (descriptive outcome field)
SELECT
    fraud_type,
    COUNT(*) AS transaction_count,
    ROUND(SUM(transaction_amount), 2) AS transaction_value,
    ROUND(SUM(fraud_amount_lost), 2) AS reported_fraud_loss
FROM fraud_clean
WHERE is_fraud = 1
GROUP BY fraud_type
ORDER BY transaction_count DESC;

-- 9.2 Merchants with the highest number of fraud transactions
SELECT
    merchant_id,
    COUNT(*) AS fraud_transactions,
    ROUND(SUM(transaction_amount), 2) AS fraud_transaction_value,
    ROUND(SUM(fraud_amount_lost), 2) AS reported_fraud_loss
FROM fraud_clean
WHERE is_fraud = 1
GROUP BY merchant_id
ORDER BY fraud_transactions DESC
LIMIT 20;

-- 9.3 Customers with the highest number of fraud transactions
SELECT
    customer_id,
    COUNT(*) AS fraud_transactions,
    ROUND(SUM(transaction_amount), 2) AS fraud_transaction_value,
    ROUND(SUM(fraud_amount_lost), 2) AS reported_fraud_loss
FROM fraud_clean
WHERE is_fraud = 1
GROUP BY customer_id
ORDER BY fraud_transactions DESC
LIMIT 20;


-- =========================================================
-- 10. COMBINED RISK SEGMENTS
-- =========================================================

-- 10.1 Hour x channel
SELECT
    transaction_hour,
    transaction_channel,
    COUNT(*) AS total_transactions,
    SUM(is_fraud = 1) AS fraud_transactions,
    ROUND(100.0 * SUM(is_fraud = 1) / NULLIF(COUNT(is_fraud), 0), 2)
        AS fraud_rate_pct
FROM fraud_clean
GROUP BY transaction_hour, transaction_channel
HAVING COUNT(*) >= 20
ORDER BY fraud_rate_pct DESC;

-- 10.2 Country x international flag
SELECT
    merchant_country,
    international_transaction,
    COUNT(*) AS total_transactions,
    SUM(is_fraud = 1) AS fraud_transactions,
    ROUND(100.0 * SUM(is_fraud = 1) / NULLIF(COUNT(is_fraud), 0), 2)
        AS fraud_rate_pct
FROM fraud_clean
GROUP BY merchant_country, international_transaction
HAVING COUNT(*) >= 20
ORDER BY fraud_rate_pct DESC;

-- 10.3 Account age x transaction velocity
SELECT
    CASE
        WHEN account_age_days < 90 THEN 'New account'
        WHEN account_age_days < 365 THEN 'Account under 1 year'
        WHEN account_age_days >= 365 THEN 'Account 1 year+'
        ELSE 'Unknown'
    END AS account_age_segment,
    CASE
        WHEN transactions_last_1h >= 3 THEN 'High velocity: 3+'
        WHEN transactions_last_1h BETWEEN 1 AND 2 THEN 'Medium velocity: 1-2'
        WHEN transactions_last_1h = 0 THEN 'No recent transaction'
        ELSE 'Unknown'
    END AS velocity_segment,
    COUNT(*) AS total_transactions,
    SUM(is_fraud = 1) AS fraud_transactions,
    ROUND(100.0 * SUM(is_fraud = 1) / NULLIF(COUNT(is_fraud), 0), 2)
        AS fraud_rate_pct
FROM fraud_clean
GROUP BY account_age_segment, velocity_segment
HAVING COUNT(*) >= 20
ORDER BY fraud_rate_pct DESC;


-- =========================================================
-- 11. FINAL ANALYST CHECKLIST
-- =========================================================
-- Before presenting findings:
-- [ ] Confirm the actual CSV header matches the view's referenced fields.
-- [ ] Confirm row count and distinct transaction IDs.
-- [ ] Investigate duplicate transaction IDs before deciding how to handle them.
-- [ ] Check NULLs and invalid values in the quality queries.
-- [ ] Verify the date range; investigate future-dated records.
-- [ ] Use fraud rate together with sample size (avoid over-interpreting tiny groups).
-- [ ] Distinguish fraud transaction value from reported fraud_amount_lost.
-- [ ] Do not use fraud_type or fraud_amount_lost as predictors of is_fraud.
-- [ ] Remember that association does not prove causation.
-- [ ] Validate all reported numbers against query output from the raw CSV.

-- END OF SCRIPT

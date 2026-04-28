-- Nigeria vs Canada Retail Analysis
-- SQL Queries — MySQL Workbench
-- Author: Baraqat Atanda
-- Period: Q1 2019 – Q3 2024 (Nigeria) | Q1 2019 – Q4 2023 (Canada)
 
USE retail_analysis;

-- SCHEMA SETUP
CREATE DATABASE IF NOT EXISTS retail_analysis;
USE retail_analysis;

CREATE TABLE nigeria_trade (
    id INT AUTO_INCREMENT PRIMARY KEY,
    year YEAR NOT NULL,
    quarter TINYINT NOT NULL,
    period_label VARCHAR(10) NOT NULL,
    nigeria_trade_real_growth_pct DECIMAL(8,4),
    nigeria_gdp_growth_pct DECIMAL(8,4),
    UNIQUE KEY uq_period (year, quarter)
);

CREATE TABLE canada_retail (
    id INT AUTO_INCREMENT PRIMARY KEY,
    year YEAR NOT NULL,
    quarter TINYINT NOT NULL,
    period_label VARCHAR(10) NOT NULL,
    retail_sales_cad DECIMAL(18,2),
    retail_growth_yoy_pct DECIMAL(8,4),
    UNIQUE KEY uq_period (year, quarter)
);

SELECT * FROM nigeria_trade LIMIT 5;

-- Nigeria Trade Growth Trend: Shows quarter-by-quarter trade growth with LAG comparison
-- and 4-quarter rolling average to smooth COVID spike

SELECT
    period_label,
    nigeria_trade_real_growth_pct,
    nigeria_gdp_growth_pct,
    ROUND(nigeria_trade_real_growth_pct - nigeria_gdp_growth_pct, 4) AS trade_vs_gdp_spread,
    LAG(nigeria_trade_real_growth_pct) OVER (ORDER BY year, quarter)  AS prev_qtr_growth,
    ROUND(AVG(nigeria_trade_real_growth_pct) OVER (
        ORDER BY year, quarter ROWS BETWEEN 3 PRECEDING AND CURRENT ROW
    ), 4) AS rolling_4q_avg
FROM nigeria_trade
ORDER BY year, quarter;

-- Side-by-Side Nigeria vs Canada Comparison: Shows how Nigeria's trade growth compares to Canada's
-- retail growth each quarter (2020-2023 overlap window)

SELECT
    n.period_label,
    n.year,
    n.quarter,
    n.nigeria_trade_real_growth_pct,
    c.retail_growth_yoy_pct  AS canada_retail_growth_pct,
    ROUND(n.nigeria_trade_real_growth_pct
        - c.retail_growth_yoy_pct, 4)  AS growth_spread,
    CASE
        WHEN n.nigeria_trade_real_growth_pct > c.retail_growth_yoy_pct
            THEN 'Nigeria Outperforms'
        WHEN n.nigeria_trade_real_growth_pct < c.retail_growth_yoy_pct
            THEN 'Canada Outperforms'
        ELSE 'Parity'
    END  AS performance_flag
FROM nigeria_trade n
INNER JOIN canada_retail c
    ON n.year = c.year AND n.quarter = c.quarter
WHERE c.retail_growth_yoy_pct IS NOT NULL
ORDER BY n.year, n.quarter;

-- Annual Average Growth with CTE + RANK: Summarises each year's average growth for both countries
-- and ranks Nigeria's years from best to worst performance

WITH annual AS (
    SELECT
        n.year,
        ROUND(AVG(n.nigeria_trade_real_growth_pct), 4)  AS nigeria_avg,
        ROUND(AVG(c.retail_growth_yoy_pct), 4) AS canada_avg
    FROM nigeria_trade n
    INNER JOIN canada_retail c
        ON n.year = c.year AND n.quarter = c.quarter
    WHERE c.retail_growth_yoy_pct IS NOT NULL
    GROUP BY n.year
)
SELECT
    year,
    nigeria_avg,
    canada_avg,
    ROUND(nigeria_avg - canada_avg, 4)  AS annual_spread,
    RANK() OVER (ORDER BY nigeria_avg DESC) AS nigeria_rank
FROM annual
ORDER BY year;

-- Volatility Analysis: Compares how stable/unstable retail growth is in Nigeria vs Canada using standard deviation

SELECT 'Nigeria Trade' AS market,
    ROUND(AVG(nigeria_trade_real_growth_pct), 4) AS avg_growth,
    ROUND(STDDEV(nigeria_trade_real_growth_pct), 4) AS volatility,
    ROUND(MIN(nigeria_trade_real_growth_pct), 4) AS min_growth,
    ROUND(MAX(nigeria_trade_real_growth_pct), 4) AS max_growth
FROM nigeria_trade
WHERE year BETWEEN 2020 AND 2023

UNION ALL

SELECT 'Canada Retail' AS market,
    ROUND(AVG(retail_growth_yoy_pct), 4),
    ROUND(STDDEV(retail_growth_yoy_pct), 4),
    ROUND(MIN(retail_growth_yoy_pct), 4),
    ROUND(MAX(retail_growth_yoy_pct), 4)
FROM canada_retail
WHERE year BETWEEN 2020 AND 2023
  AND retail_growth_yoy_pct IS NOT NULL;
  
-- COVID Crash + Recovery Phase Analysis: Classifies each quarter into an economic phase to tell the full story of how both markets moved through COVID

SELECT
    n.period_label,
    n.nigeria_trade_real_growth_pct,
    c.retail_growth_yoy_pct AS canada_retail_growth_pct,
    CASE
        WHEN n.year = 2020 AND n.quarter IN (2,3) THEN 'COVID Crash'
        WHEN n.year = 2020 AND n.quarter = 4 THEN 'Early Recovery'
        WHEN n.year = 2021 THEN 'Rebound'
        WHEN n.year = 2022 THEN 'Normalisation'
        WHEN n.year = 2023 THEN 'Post-COVID Baseline'
        ELSE 'Pre-COVID'
    END AS economic_phase,
    ROUND(n.nigeria_trade_real_growth_pct
        - c.retail_growth_yoy_pct, 4) AS spread
FROM nigeria_trade n
LEFT JOIN canada_retail c
    ON n.year = c.year AND n.quarter = c.quarter
ORDER BY n.year, n.quarter;

-- Trade vs Nigeria's Own Economy: Shows whether the retail/trade sector is driving or dragging Nigeria's overall economic growth each quarter

SELECT
    period_label,
    nigeria_trade_real_growth_pct,
    nigeria_gdp_growth_pct,
    ROUND(nigeria_trade_real_growth_pct
        - nigeria_gdp_growth_pct, 4) AS trade_lag,
    CASE
        WHEN nigeria_trade_real_growth_pct >= nigeria_gdp_growth_pct
            THEN 'Trade Leading Economy'
        ELSE 'Trade Lagging Economy'
    END AS sector_signal,
    ROUND(AVG(nigeria_trade_real_growth_pct) OVER (
        ORDER BY year, quarter
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ), 4) AS cumulative_avg
FROM nigeria_trade
ORDER BY year, quarter;

-- Final Export Table for Excel Dashboard: Clean combined output of both datasets 

SELECT
    n.year,
    n.quarter,
    n.period_label,
    n.nigeria_trade_real_growth_pct,
    n.nigeria_gdp_growth_pct,
    ROUND(n.nigeria_trade_real_growth_pct
        - n.nigeria_gdp_growth_pct, 4) AS nigeria_trade_vs_gdp,
    c.retail_sales_cad,
    c.retail_growth_yoy_pct AS canada_retail_growth_pct,
    ROUND(n.nigeria_trade_real_growth_pct
        - c.retail_growth_yoy_pct, 4) AS nigeria_vs_canada_spread
FROM nigeria_trade n
LEFT JOIN canada_retail c
    ON n.year = c.year AND n.quarter = c.quarter
ORDER BY n.year, n.quarter;
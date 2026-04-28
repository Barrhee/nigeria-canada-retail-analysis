# Nigeria vs Canada Retail Analysis
### A Global Comparative Analysis of Retail Sector Growth (2019–2024)

![Excel](https://img.shields.io/badge/Excel-Dashboard-217346?style=flat&logo=microsoft-excel&logoColor=white)
![MySQL](https://img.shields.io/badge/MySQL-Database-4479A1?style=flat&logo=mysql&logoColor=white)
![Data](https://img.shields.io/badge/Data-NBS%20Nigeria%20%7C%20OECD-orange?style=flat)
![Status](https://img.shields.io/badge/Status-Complete-brightgreen?style=flat)

---
## Project Summary

This project benchmarks Nigeria's retail trade sector growth against Canada's retail sales performance across the 2020–2023 overlap window — covering the COVID crash, rebound, normalisation, and post-COVID baseline phases.

---

## Key Findings

| Finding | Detail |
| Canada outperformed Nigeria | Canada's retail growth averaged 2.93% vs Nigeria's 1.36% across 2020–2023 |
| Nigeria more volatile | Nigeria's growth std dev was significantly higher — reflecting FX instability, inflation and weak fiscal buffers |
| Trade lagged Nigeria's own economy | Nigeria's trade sector grew slower than total GDP every single quarter — meaning economic growth was not reaching ordinary consumers |
| 2021 rebound was a base effect | Nigeria's +22% spike in Q2 2021 reflects recovery from a -16% COVID crash, not structural retail expansion |
| Markets converged by 2023 | Both countries settled at ~1–2% growth by 2023, but Nigeria's was eroded by 20%+ inflation |

---

## Repository Structure

```
nigeria-canada-retail-analysis/
├── data/
│   ├── raw/
│   │   ├── Q3_GDP_2024.xlsx
│   │   ├── Q4_GDP_2022_Fn.xlsx
│   │   ├── Q4_GDP_2020__final_Draft.xlsx
│   │   └── CANSLRTTO01MLSAM.csv
│   └── processed/
│       ├── nigeria_trade.csv
│       └── canada_retail.csv
├── sql/
│   └── queries.sql
├── excel/
│   └── nigeria_canada_retail_analysis.xlsx
├── docs/
│   └── data_methodology.docx
└── README.md
```

---
## Dashboard Preview

The Excel dashboard contains 4 charts and 4 KPI cards on a single page:

| Chart | Description |
| Chart 1 | Nigeria Trade vs Canada Retail — YoY Growth Rate (%) |
| Chart 2 | Nigeria Trade Sector vs Total GDP Growth (%) |
| Chart 3 | Nigeria vs Canada Retail Growth Spread (%) |
| Chart 4 | Retail Growth Volatility — Nigeria vs Canada (Std Dev) |

---

## Data Sources

### Nigeria — National Bureau of Statistics (NBS)
The NBS does not publish a standalone retail sales report. The Trade sector row from the quarterly real GDP growth rate tables was used as the closest proxy for retail performance.

Three separate Excel files were downloaded and merged:

| File | Period | Source |
| Q4_GDP_2020__final_Draft.xlsx | 2019–2020 | nigerianstat.gov.ng |
| Q4_GDP_2022_Fn.xlsx | 2021–2022 | nigerianstat.gov.ng |
| Q3_GDP_2024.xlsx | 2023–Q3 2024 | nigerianstat.gov.ng |

### Canada — OECD via FRED
- Series: CANSLRTTO01MLSAM — Canada Total Retail Trade, Seasonally Adjusted
- Publisher: OECD Main Economic Indicators via Federal Reserve Bank of St. Louis
- Coverage: January 1991 – October 2023 (monthly, aggregated to quarterly)
- URL:fred.stlouisfed.org

---

## Tools & Technologies

| Tool | Purpose |
| MySQL Workbench | Database creation, table import, SQL querying |
| Microsoft Excel | Data cleaning, quarterly aggregation, dashboard |
| NBS Nigeria Portal | Raw GDP data download |
| FRED (St. Louis Fed) | Canada retail trade data download |

---

## Database Schema

```sql
CREATE DATABASE retail_analysis;

CREATE TABLE nigeria_trade (
    id                              INT AUTO_INCREMENT PRIMARY KEY,
    year                            YEAR        NOT NULL,
    quarter                         TINYINT     NOT NULL,
    period_label                    VARCHAR(10) NOT NULL,
    nigeria_trade_real_growth_pct   DECIMAL(8,4),
    nigeria_gdp_growth_pct          DECIMAL(8,4),
    UNIQUE KEY uq_period (year, quarter)
);

CREATE TABLE canada_retail (
    id                      INT AUTO_INCREMENT PRIMARY KEY,
    year                    YEAR        NOT NULL,
    quarter                 TINYINT     NOT NULL,
    period_label            VARCHAR(10) NOT NULL,
    retail_sales_cad        DECIMAL(18,2),
    retail_growth_yoy_pct   DECIMAL(8,4),
    UNIQUE KEY uq_period (year, quarter)
);
```

---

## 📝 SQL Queries

Seven queries were written and executed in MySQL Workbench:

| Query | Technique Used | Purpose |

| Q1 — Nigeria Growth Trend | LAG, rolling AVG window function | Track Nigeria's quarter-by-quarter trade growth |
| Q2 — Nigeria vs Canada | INNER JOIN, CASE | Side-by-side comparison with performance flag |
| Q3 — Annual Summary | CTE, RANK window function | Annual averages ranked by Nigeria performance |
| Q4 — Volatility Analysis | STDDEV, UNION ALL | Compare growth stability between both markets |
| Q5 — COVID Phase Analysis | CASE, LEFT JOIN | Classify quarters into economic phases |
| Q6 — Trade vs Own Economy | Window AVG, CASE | Nigeria trade sector vs total GDP growth |
| Q7 — Final Export | Multi-table LEFT JOIN | Clean combined table exported to Excel |

See full query code in [`sql/queries.sql`](sql/queries.sql)

---

## Analyst Narrative

1. COVID Hit Nigeria Harder and Recovery Was Slower
Nigeria's trade sector fell to -16.6% in Q2 2020 vs Canada's -12.9%. Canada recovered to positive territory by Q3 2020 due to government stimulus cheques going directly to consumers. Nigeria had no comparable fiscal stimulus, keeping the sector negative until Q2 2021.

2. Nigeria's 2021 Rebound Was Dramatic But Not Structural
Nigeria's trade sector surged to +22.5% in Q2 2021 — but this is a mathematical base effect from the 2020 crash, not genuine retail expansion. By 2022–2023 growth normalised to 1–5%.

3. Trade Consistently Lagged Nigeria's Own Economy
Nigeria's overall GDP grew at ~3% while the trade sector grew under 2% throughout the study period. This means GDP growth was happening in oil, telecoms and construction — not through consumer spending. A key risk signal for consumer-facing businesses evaluating Nigeria as a market.

4. By 2023 Both Markets Converged — But For Different Reasons
Nigeria's trade growth (~1.4%) converged with Canada's (~2.2%) in 2023. However, Canada's growth represented genuine volume expansion while Nigeria's was being eroded by 20%+ inflation — meaning Nigerians were spending more money but buying less.

---

## Limitations

| Limitation | Notes |
| Nigeria Trade sector is broader than retail only | Includes wholesale and motor vehicle repair — used as directional indicator |
| Canada data ends Oct 2023 | 2024 Nigeria data has no Canada counterpart |
| Different growth methodologies | Nigeria = real GDP growth %; Canada = volume index YoY % |
| Exchange rate not applied | Comparison is growth rates only, not absolute values |

---

## Documentation

Full data methodology, merging process, and schema documentation available in [`docs/data_methodology.docx`](docs/data_methodology.docx)

---

##  Author

Baraqat Atanda
Data Analyst Portfolio Project
Global Comparative Analysis

---

## Connect

Feel free to connect or provide feedback via GitHub Issues or LinkedIn.

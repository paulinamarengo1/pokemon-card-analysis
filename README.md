# Pokémon Card Market Analysis

## Overview
A Python web scraper that collects 30,000+ Pokémon card prices across 325 sets 
from [PriceCharting.com](https://www.pricecharting.com). Data is saved to a CSV 
file and analyzed using SQL to uncover market trends and grading ROI insights.

## Motivation

The Pokemon card market is a multi-billion dollar collectibles market where prices are driven by card condition, rarity, and grading. Professional grading (PSA, BGS) can multiply a card's value significantly but not all cards are worth grading. This project answers the question: which cards are actually worth getting graded, and by how much?

The project was mainly built as a real tool for my personal collection!

## Data Source

All data was self-scraped from **PriceCharting.com** (no Kaggle datasets were used).

PriceCharting aggregates real transaction data from eBay sold listings and other marketplaces, providing:

- Ungraded market prices
- Grade 9 prices (BGS/CGC)
- PSA 10 prices (highest achievable grade)
- Coverage across hundreds of Pokemon sets

Data was scraped using Python (see [`scraper.py`](scraper.py) for the full scraping code) saved to a CSV file, and then loaded into Microsoft SQL Server for analysis.

## Tools & Tech Stack
 
| Tool | Purpose |
|---|---|
| Python (httpx, selectolax) | Web scraping |
| CSV | Intermediate data storage |
| Microsoft SQL Server | Data storage and analysis |
| Power BI | Dashboard and visualization |

## Project Structure
 
```
pokemon-card-analytics/
│
├── scraper/
│   └── scraper.py           # Scrapes all Pokemon sets from PriceCharting
│
├── sql/
│   └── analysis_queries.sql # All analysis queries with documentation
│
├── data/
│   └── pokemon_prices.csv   # Raw scraped data
│
├── dashboard/
│   └── pokemon_analytics.pbix  # Power BI dashboard file
│
└── README.md
```

## How It Works
 
### 1. Data Collection (Python)
The scraper navigates to PriceCharting's Pokemon category page, identifies all available sets, then loops through each set page extracting card names and prices across three grading tiers: ungraded, Grade 9, and PSA 10. A one-second delay between requests avoids overloading the server. Results are saved to a CSV file tagged with the scrape date.
 
### 2. Data Storage (SQL Server)
The CSV is loaded into Microsoft SQL Server where all analysis is performed. Sealed products (boxes, packs) are excluded from all queries since they behave differently from individual cards.
 
### 3. Analysis (SQL)
Six queries drive the core analysis:
 
- **Total cards in dataset** — baseline count of scraped records
- **Top 10 most expensive ungraded cards** — market overview of highest value cards
- **Grading ROI with outlier flag** — PSA 10 multiplier per card, with a statistical flag for unreliable data points
- **Reliable grading opportunities** — same analysis filtered to trustworthy data only
- **Cards where grading adds $500+ in value** — high-impact grading targets
- **Average value added by grading** — market-wide benchmark for grading ROI

### 4. Outlier Handling
Since the dataset does not include sales volume, cards with very few transactions can show extreme price multipliers that don't reflect true market value. To handle this, a statistical outlier flag was built into the grading ROI query: any card with a PSA 10 multiplier more than 10x the dataset average is flagged as "Outlier - Verify Manually" and excluded from the reliable opportunities analysis.
 
### 5. Dashboard (Power BI)
The Power BI dashboard visualizes all six analyses with interactive filters by set and data quality flag.
 
---

## Dashboard Pages
 
- **Page 1: Market Overview** — KPI cards, total dataset size, average prices by grade
- **Page 2: Grading ROI** — scatter plot of ungraded price vs PSA 10 multiplier, colored by data quality flag
- **Page 3: Best Grading Opportunities** — top reliable cards by grading ROI
- **Page 4: Collection Tracker** — personal collection valuation against live market prices

 ## What I Learned
 
- End-to-end data pipeline construction: scraping, storage, analysis, and visualization
- Handling data quality issues without sales volume data by using statistical outlier detection
- Translating a real-world collectibles market into a structured analytics problem with business-relevant insights

## Future Improvements
 
- Scrape historical price data for the Pokemon Base Set to enable time series analysis and price forecasting
- Add a Python collection valuation script: input your cards via CSV, output current value and grading recommendations
- Automate weekly scraping to build a longitudinal price dataset over time
- Integrate eBay sold listings via the eBay Browse API as a second pricing source


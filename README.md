# Pokémon Card Market Analysis

## Overview
A Python web scraper that collects 30,000+ Pokémon card prices across 325 sets 
from [PriceCharting.com](https://www.pricecharting.com). Data is saved to a CSV 
file and analyzed using SQL to uncover market trends and grading ROI insights.

> **PSA 10** refers to a professionally graded card in perfect condition, rated 
> by Professional Sports Authenticator: the industry standard for collectible 
> card grading.

## Tools & Libraries
- **Python** — web scraping
- **httpx** — sending HTTP requests
- **selectolax** — parsing HTML
- **SQL** — data analysis
- **Power BI** — data visualization

## Data Collected
| Column | Description |
|---|---|
| Set | Name of the Pokémon card set |
| Card | Name and number of the card |
| Ungraded | Current ungraded market price |
| Grade 9 | PSA 9 graded market price |
| PSA 10 | PSA 10 graded market price |
| Scrape Date | Date the data was collected |

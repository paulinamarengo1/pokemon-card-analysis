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

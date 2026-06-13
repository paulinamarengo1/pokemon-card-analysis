# Pokémon Card Price Scraper
# Scrapes 30,000+ card prices across 325 sets from
# PriceCharting.com and saves results to a CSV file
# Author: Paulina Marengo
# Date: June 2026
# Tools: Python, httpx, selectolax

import httpx
import csv
import time
from selectolax.parser import HTMLParser
from datetime import datetime

# Base URL for PriceCharting and the Pokemon cards category page
base_url = "https://www.pricecharting.com"
url = "https://www.pricecharting.com/category/pokemon-cards"

# Mimic a real browser so that the site does not block the requests
headers = {"User-Agent":"Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36"}

# Record today's date to tag every row with when it was scraped 
scrape_date = datetime.now().strftime("%Y-%m-%d")

# Fetch the main Pokemon cards category page
resp = httpx.get(url, headers=headers)

# Parse the HTML response so we can search through it
html = HTMLParser(resp.text)

# Find all links on the page that point to a Pokemon set (e.g. /console/pokemon-base-set)
sets = [tag for tag in html.css("a") if "/console/pokemon" in tag.attributes.get("href", "")]

# Open a CSV file to write results into (overwrites if it already exists)
print(f"Found {len(sets)} sets. Starting scrape...")

with open("pokemon_prices.csv", "w", newline="", encoding="utf-8") as f:
    writer = csv.writer(f)

    # Write the header row
    writer.writerow(["Set", "Card", "Ungraded", "Grade 9", "PSA 10", "Scrape Date"])

    # Loop through every set we found
    for i, s in enumerate(sets, 1):

        # Get the set name and build its full URL
        set_name = s.text().strip()
        set_url = base_url + s.attributes.get("href")
        print(f"[{i}/{len(sets)}] Scraping {set_name}...")

        try:
            # Fetch the set page
            resp2 = httpx.get(set_url, headers=headers, timeout=10)

            # Parse the HTML of the set page
            html2 = HTMLParser(resp2.text)

            # Find all card rows inside the prices table
            rows = html2.css("table#games_table tbody tr")

            # Loop through each card row and extract the data
            for row in rows:
                name = row.css_first("td.title a")
                ungraded = row.css_first("td.used_price span.js-price")
                grade9 = row.css_first("td.cib_price span.js-price")
                psa10 = row.css_first("td.new_price span.js-price")

                # Only write the row if the card name exists (skips empty/bad data)
                if name:
                    writer.writerow([
                        set_name,
                        name.text().strip(),
                        ungraded.text().strip() if ungraded else "N/A",
                        grade9.text().strip() if grade9 else "N/A",
                        psa10.text().strip() if psa10 else "N/A",
                        scrape_date
                    ])

            time.sleep(1)  # wait one second, avoid getting blocked

        except Exception as e:
            # If a set fails print error, move on
            print(f"  Error scraping {set_name}: {e}")
            continue

print("Sucess, Saved to pokemon_prices.csv")

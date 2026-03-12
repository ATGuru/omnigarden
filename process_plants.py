#!/usr/bin/env python3

# Simple script to process the USDA plant data
input_file = "plantlist.txt"
output_file = "usda_plants_clean.csv"

import csv

with open(input_file, 'r', encoding='utf-8') as infile, \
     open(output_file, 'w', newline='', encoding='utf-8') as outfile:

    reader = csv.reader(infile)
    writer = csv.writer(outfile, quoting=csv.QUOTE_ALL)
    
    # Write header
    header = next(reader)  # Skip original header
    writer.writerow(["symbol", "synonym_symbol", "scientific_name", "common_name", "family"])
    
    count = 0
    for row in reader:
        if len(row) >= 5:
            # Only keep rows with actual data
            if row[0] and row[0] != '"Symbol"':
                writer.writerow(row[:5])
                count += 1

print(f"Processed {count} plants")
print(f"Clean CSV saved as: {output_file}")

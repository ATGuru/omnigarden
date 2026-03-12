import csv
import re

input_file = "plantlst.txt"   # rename your downloaded file to this
output_file = "usda_plants_clean.csv"

with open(input_file, 'r', encoding='utf-8', errors='ignore') as infile, \
     open(output_file, 'w', newline='', encoding='utf-8') as outfile:

    writer = csv.writer(outfile, quoting=csv.QUOTE_ALL)
    
    # Write header
    writer.writerow(["Symbol", "Synonym Symbol", "Scientific Name with Author", "Common Name", "Family"])
    
    for line in infile:
        # Skip empty lines and obvious junk
        line = line.strip()
        if not line or line.startswith('"Symbol"') or len(line) < 20:
            continue
            
        # Split on "," but handle cases where fields are missing or have internal commas
        # This is a rough but effective way for this specific file
        parts = re.split(r'(?<!\\),', line.strip('"'))
        parts = [p.strip().strip('"') for p in parts]
        
        # Pad to 5 columns if short
        while len(parts) < 5:
            parts.append("")
            
        writer.writerow(parts[:5])  # only take first 5 fields

print(f"Clean CSV saved as: {output_file}")
print("Rows processed (approx):", sum(1 for line in open(input_file)) - 1)

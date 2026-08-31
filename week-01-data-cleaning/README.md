
# Project 1: Data Cleaning & Preparation

## Overview
This project cleans a raw e-commerce order dataset (1,200 records, 14 columns) as part of the DecodeLabs Data Analytics Industrial Training Kit. The goal was to identify missing values, remove duplicates, and correct formatting issues to produce a reliable, analysis-ready dataset.

**Files:**
- `data/raw/Dataset for Data Analytics.xlsx` — original, untouched dataset
- `data/cleaned/Dataset for Data Analytics - cleaned.xlsx` — cleaned output

## Step 1: Initial Audit
Before making any changes, I ran a full audit of the raw dataset to establish a baseline:

- **Missing values:** checked every column for nulls
- **Duplicates:** checked both full-row duplicates and `OrderID` uniqueness
- **Calculation integrity:** verified `Quantity × UnitPrice = TotalPrice` on every row
- **ID formats:** verified `OrderID`, `CustomerID`, and `TrackingNumber` all matched their expected patterns
- **Text fields:** checked for inconsistent casing or stray whitespace

This confirmed the dataset had no duplicate rows, no duplicate order IDs, and no calculation errors — the two real issues were incomplete coupon data and inconsistent date formatting.

## Step 2: Handling Missing Values
**Finding:** `CouponCode` had 309 blank entries (~26% of all rows).

**Action:** Filled blanks with `"No Coupon Used"` instead of deleting the rows.

**Reasoning:** A blank cell in a categorical column is ambiguous — it isn't clear whether no coupon was applied, or the value simply wasn't recorded. Since every other field in these rows (quantity, price, order status, etc.) was fully populated and valid, deleting them would have thrown away good data to "fix" one column. An explicit label resolves the ambiguity while keeping every record intact, which is the standard approach for missing categorical data.

## Step 3: Standardizing Date Format
**Finding:** The `Date` column held valid date values but was not displayed in a consistent, standard format.

**Action:** Reformatted the column to ISO 8601 (`yyyy-mm-dd`), and sorted all records chronologically in ascending order.

**Reasoning:** ISO 8601 is the unambiguous, locale-independent date standard — it removes any confusion between day-first and month-first formats, and it's the expected format for downstream analysis, reporting, or import into other tools. The underlying date values were left as true dates (not converted to text), so date math, filtering, and sorting all continue to work correctly.

## Step 4: Final Validation
After cleaning, I re-ran the same checks from Step 1 to confirm nothing broke:

| Check | Result |
|---|---|
| Missing values | 0 (previously 309 in `CouponCode`) |
| Duplicate rows | 0 |
| Duplicate `OrderID`s | 0 |
| `Quantity × UnitPrice = TotalPrice` mismatches | 0 |
| Records preserved | 1,200 / 1,200 |
| Date format | ISO 8601 (`yyyy-mm-dd`) |

## Result
The cleaned dataset retains all 1,200 original records with zero missing values, zero duplicates, and consistent, unambiguous date formatting — ready for analysis or reporting.

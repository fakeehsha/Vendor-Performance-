# 📊 Vendor Performance Data Analytics

> **Optimizing profitability through inventory & sales analysis using Python, SQL, and Power BI**

![Python](https://img.shields.io/badge/Python-3.x-blue?logo=python&logoColor=white)
![SQL](https://img.shields.io/badge/SQL-SQLite-orange?logo=sqlite&logoColor=white)
![Power BI](https://img.shields.io/badge/Power%20BI-Dashboard-yellow?logo=powerbi&logoColor=white)
![Status](https://img.shields.io/badge/Status-Completed-brightgreen)
![License](https://img.shields.io/badge/License-MIT-green)

---

## 🎯 Business Problem

Effective inventory and sales management are critical for optimizing profitability in the retail and wholesale industry. Companies need to ensure they are not incurring losses due to inefficient pricing, poor inventory turnover, or vendor dependency.

### Goals of This Analysis

1. **Identify underperforming brands** that require promotional or pricing adjustments
2. **Determine top vendors** contributing to sales and gross profit
3. **Analyze the impact of bulk purchasing** on unit costs
4. **Assess inventory turnover** to reduce holding costs and improve efficiency
5. **Investigate the profitability variance** between high-performing and low-performing vendors

---

## 📂 Project Structure

```
Vendor-Performance-Data-Analytics/
│
├── data/                              # Raw CSV datasets
│   ├── sales_100k.csv                 # 100K sales transactions
│   ├── purchases_100k.csv            # 100K purchase orders
│   ├── purchase_prices.csv           # Master price list (12K+ items)
│   ├── begin_inventory.csv           # Beginning inventory (206K rows)
│   ├── end_inventory.csv             # Ending inventory (224K rows)
│   └── vendor_invoice.csv            # Vendor invoices (5.5K rows)
│
├── outputs/                           # Analysis outputs
│   ├── q1_underperforming_brands.csv  # Query results
│   ├── q1_underperforming_brands.png  # Visualizations
│   ├── q2_top_vendors.csv / .png
│   ├── q3_bulk_purchasing.csv / .png
│   ├── q4_inventory_turnover.csv / .png
│   ├── q5_vendor_profitability_variance.csv / .png
│   └── powerbi/                       # Power BI star-schema files
│       ├── dim_vendor.csv
│       ├── dim_brand.csv
│       ├── dim_store.csv
│       ├── dim_date.csv
│       ├── fact_sales.csv
│       ├── fact_purchases.csv
│       ├── fact_inventory.csv
│       ├── kpi_summary.csv
│       └── powerbi_measures.txt       # DAX measures
│
├── vendor_analysis.py                 # Main Python + SQL analysis script
├── sql_queries.sql                    # Standalone SQL queries
├── powerbi_data_model.py             # Power BI data preparation script
├── Vendor_Performance_Analysis.ipynb  # Jupyter Notebook version
├── Vendor_Performance_Presentation.pptx  # Project presentation (11 slides)
└── README.md
```

---

## 🛠️ Tools & Technologies

| Tool | Usage |
|------|-------|
| **Python** | Data cleaning, transformation, analysis, visualization (Pandas, Matplotlib, Seaborn) |
| **SQL (SQLite)** | In-memory database queries — CTEs, aggregations, CASE-based tiering, UNION ALL |
| **Power BI** | Interactive dashboard with star-schema model, DAX measures, KPI cards |
| **Jupyter Notebook** | Interactive analysis with inline charts |

---

## 🔧 Data Cleaning & Preprocessing

| Step | Technique | Purpose |
|------|-----------|---------|
| 1 | Column name stripping | Remove header whitespace |
| 2 | String value trimming | Fix join mismatches in text fields |
| 3 | Date parsing (`pd.to_datetime`) | Convert 7 date columns with error handling |
| 4 | Missing value imputation (`fillna(0)`) | Handle NaN in inventory & prices |
| 5 | Column renaming | Standardize `VendorNo` → `VendorNumber` |
| 6 | Duplicate removal | Prevent row multiplication in joins |
| 7 | Derived columns | Calculate COGS, GrossProfit |
| 8 | Division-by-zero protection | Safe ratio calculations |
| 9 | Rounding | Clean 2-decimal output |

---

## 📈 Key Analysis & SQL Queries

### Q1: Underperforming Brands
- **Technique:** CTE + LEFT JOIN on sales, purchase prices, and end inventory
- **Finding:** Several brands show negative or near-zero profit margins with high unsold inventory

### Q2: Top Vendors by Sales & Gross Profit
- **Technique:** Aggregation with COALESCE and profit margin ranking
- **Finding:** DIAGEO NORTH AMERICA leads with $457K in sales; Top 10 vendors contribute ~65.7% of total purchases

### Q3: Bulk Purchasing Impact on Unit Costs
- **Technique:** CASE-based tiering (Small/Medium/Large/Bulk)
- **Finding:** Bulk purchasing confirms volume discounts — larger orders reduce per-unit costs

### Q4: Inventory Turnover Ratio
- **Technique:** UNION ALL for average inventory, COGS ÷ Avg Inventory Value
- **Finding:** High-turnover brands are sold efficiently; low-turnover brands tie up capital

### Q5: Profitability Variance
- **Technique:** CTE with HAVING filter, Top 10 vs Bottom 10 comparison
- **Finding:** 18 percentage point gap — Top 10 vendors average ~42% margin vs Bottom 10 at ~24%

---

## 📊 Power BI Dashboard

The dashboard follows a **star-schema data model** with:
- **4 Dimension Tables:** dim_vendor, dim_brand, dim_store, dim_date
- **3 Fact Tables:** fact_sales, fact_purchases, fact_inventory
- **1 KPI Summary Table:** Pre-computed vendor-level metrics
- **20 DAX Measures:** Including Total Sales, Gross Profit, Profit Margin %, Inventory Turnover

### Dashboard Features:
- 5 KPI Cards (Total Sales, Total Purchase, Gross Profit, Profit Margin %, Unsold Capital)
- Donut Chart — Purchase Contribution % by vendor
- Top Vendors & Top Brands by Sales (bar charts)
- Low Performing Vendors (bar chart)
- Low Performing Brands (scatter plot)

---

## 🚀 How to Run

### Prerequisites
```bash
pip install pandas matplotlib seaborn
```

### Run the Analysis
```bash
# Main analysis with SQL queries + visualizations
python vendor_analysis.py

# Generate Power BI data model
python powerbi_data_model.py
```

### Run in Jupyter Notebook
```bash
jupyter notebook Vendor_Performance_Analysis.ipynb
```

---

## 📌 Key Findings

| # | Finding |
|---|---------|
| 1 | DIAGEO NORTH AMERICA is the top vendor ($457K sales) |
| 2 | Top 10 vendors contribute ~65.7% of total purchase spend |
| 3 | 18pp profit margin gap between best & worst vendors |
| 4 | Bulk purchasing significantly reduces unit costs |
| 5 | Several brands have negative margins with high unsold inventory |
| 6 | $2.71M in unsold capital tied up in low-turnover brands |

---

## ✅ Recommendations

1. Run clearance promotions for negative-margin brands to free up capital
2. Renegotiate terms with low-margin vendors or shift volume to profitable ones
3. Consolidate small purchase orders into bulk orders for volume discounts
4. Set reorder points based on turnover ratios — fast movers get priority
5. Diversify vendor base to reduce dependency on top 10 vendors
6. Implement quarterly vendor scorecards using this analytics framework

---

## 📄 License

This project is for educational and analytical purposes.

---

## 🤝 Connect

If you found this project useful, feel free to ⭐ star this repository!

📊 Postsecondary Earnings Outcomes Data Warehouse & Decision Dashboard
Overview

This project builds a denormalized data warehouse and decision-focused analytics dashboard to analyze postsecondary earnings and employment outcomes by institution, degree level, CIP program, industry, geography, and time since graduation.

The workflow demonstrates an end-to-end analytics pipeline:

Data transformation & unpivoting

SQL-based warehouse design

Ratio-of-sums and percent-of-total calculations

Interactive dashboards in Tableau and Excel

Decision-oriented interpretation of labor-market outcomes

The project culminates in a comparative analysis of Baruch College vs. Binghamton University graduate outcomes, supporting data-driven educational investment decisions.

Data Warehouse Design
Core Table: DW_Outcome

The warehouse is centered on a single denormalized fact table, DW_Outcome, anchored on earnings outcomes.

Design principles:

Earnings outcomes serve as the anchor grain

Required dimensions (Institution, CIP) are joined using INNER JOINs

Optional dimensions (Industry flows, State-level earnings) use LEFT JOINs to preserve earnings records even when supporting data is missing

This approach ensures consistent downstream analysis without unintentionally dropping records

Data Transformation & Unpivoting
SQL Unpivot Logic

Percentile-specific earnings and employment values are unpivoted using SWITCH

Line breaks are removed using CHAR(10) to safely construct SQL insert statements

Values are concatenated using & to dynamically generate SQL-ready rows

Excel-Assisted Schema Generation

Unpivoting logic is initially prototyped in Excel

The generated SQL is copied directly into schema files

Each dataset includes:

CREATE TABLE statements

INSERT INTO statements

New institutions (Baruch, Binghamton) are appended using INSERT-only logic, preserving historical data

Analytical Queries

The project includes several core SQL result sets:

1. Earnings by Percentile & Years Post-Graduation

Uses CASE WHEN expressions

Aggregates earnings using AVG to handle duplicate rows introduced during merges

Fixed filters ensure consistent cohort and institution logic

2. Industry Employment Flows

Uses CTEs, GROUP BY, and SUM() OVER (PARTITION BY CIPCode)

Computes ratio-of-sums to normalize industry flows within each CIP

Enables meaningful cross-program comparisons

3. State-Level Earnings Distribution

Aggregates total earnings by state and industry

Divides by total state earnings to calculate percent-of-total

Supports geographic and industry-based comparisons

Dashboards & Visualizations
Tableau Dashboard

The Tableau dashboard supports interactive exploration of:

Average earnings by percentile and years post-graduation

Normalized industry employment flows by CIP

State-level earnings distribution by industry

Excel Dashboard (Recreated)

All Tableau visuals are fully recreated in Excel:

Pivot tables match Tableau’s aggregation grain

Calculated fields replicate ratio-of-sums logic

Slicers control:

Cohort

Degree award

CIP program

Institution

PivotCharts enable side-by-side institutional comparisons

Integrated Decision Dashboard

The final dashboard operates as a two-layer decision system:

Top Visualization

Aggregates SUM(Flow) by:

Institution

Degree level

Industry

Shows actual labor-market destinations, not just degree completions

Bottom Visualization

Restricts analysis to:

Master’s degrees

2016–2020 cohort

Compares SUM(Employed) by CIP between Baruch and Binghamton

Insight:
Programs with higher employment counts and stronger concentration in high-demand industries—particularly at Baruch—indicate lower labor-market risk and stronger alignment with workforce demand.

Key Findings

Baruch master’s graduates show strong concentration in:

Business

Finance

Professional & technical services

These industries align with high-demand sectors identified by the U.S. Bureau of Labor Statistics

The data supports pursuing a Baruch master’s degree as a:

Lower-risk

Labor-market-aligned

Outcome-driven investment

Tools & Technologies

SQL (CTEs, window functions, denormalized schemas)

Excel (PivotTables, PivotCharts, slicers, calculated fields)

Tableau (Interactive dashboards)

Data warehouse design principles

BLS labor-market data for validation

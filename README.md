# SaaS Analytics with ClickHouse & dbt

This project was built to simulate a real-world analytics environment. By generating a synthetic, yet realistic SaaS dataset using Python, the goal is to demonstrate an end-to-end data pipeline. It bridges the gap between raw event data and actionable business insights, showcasing advanced SQL optimizations in ClickHouse, structured data modeling in dbt, and high-level metric visualization in Power BI.

## 🎯 Project Goals

Demonstrates core analytics engineering skills used in product/growth roles:
- Funnel and churn analysis
- Time-series comparisons (MoM, YoY)
- ClickHouse-specific functions and optimizations
- dbt modeling best practices (staging → fact tables)
- BI dashboarding on a modeled warehouse

## 🛠️ Tech Stack

- **ClickHouse** — OLAP database (local via Docker)
- **Python** — Data generation (pandas, Faker) & loading (clickhouse-connect)
- **dbt** — Data transformation *(coming soon)*
- **Power BI** — Dashboarding *(coming soon)*

## 📊 Data Model

Core tables simulating a SaaS product:

| Table | Description |
|---|---|
| `users` | User accounts: signup date, plan, country |
| `events` | Product usage: signup, login, feature_use |
| `subscriptions` | Subscription history: plan, MRR, start/end dates |

*Note: Features realistic synthetic patterns like funnel drop-offs, engagement-correlated churn, and seasonality.*

## 📁 Repository Structure

```text
saas-analytics-clickhouse-dbt/
├── data/              # Generated synthetic CSVs
├── sql/               # Exploratory & analytical SQL queries
├── dbt/               # dbt project (staging + fact models)
├── powerbi/           # Power BI dashboard file
├── docker-compose.yml # Local ClickHouse setup
├── generate_data.py   # Synthetic data generator
└── load_data.py       # Loads CSVs into ClickHouse
```


## 🚀 Getting Started

```bash
# 1. Start ClickHouse locally
docker compose up -d

# 2. Set up Python environment
python3 -m venv venv
source venv/bin/activate
pip install pandas faker clickhouse-connect

# 3. Generate and load synthetic data
python3 generate_data.py
python3 load_data.py
```

## 📈 Analysis Covered So Far

Each concept lives in its own file under `sql/`, with comments explaining
the ClickHouse-specific functions used.

| File | Concept | Key techniques |
|---|---|---|
| `01_funnel.sql` | Funnel drop-off rate | `uniqIf`, CTEs |
| `02_churn.sql` | Churn analysis by plan | `countIf`, `HAVING` |
| `03_mom_churn_comparison.sql` | Month-over-Month comparison | `LAG()`, `nullIf` |
| `04_yoy_churn_comparison.sql` | Year-over-Year comparison (naive) | `LAG()` limitations |
| `05_yoy_churn_fixed.sql` | YoY comparison (calendar-complete) | `arrayJoin`, `arrayMap`, `range` |
| `06_dau_wau_mau.sql` | Daily/Weekly/Monthly Active Users | `uniqExact`, rolling window joins |
| `07_group_array.sql` | Per-user event sequences | `groupArray()` |
| `08_cascading_ctes.sql` | At-risk user detection | Stacked/cascading CTEs |
| `09_date_filters.sql` | Relative vs. fixed date filtering | `now()`, `INTERVAL`, `toDateTime` |
| `10_group_and_rank.sql` | Top features by plan | `GROUP BY`, `ORDER BY ... DESC` |
| `11_joins.sql` | JOIN types comparison | `INNER JOIN`, `LEFT JOIN` |
| `12_add_variant_column.sql` | Schema evolution | `ALTER TABLE ADD COLUMN` |
| `13_ab_test.sql` | A/B test analysis | `uniqExactIf`, split CTEs |

## 🔧 ClickHouse Functions & `-If` Combinators Used

Rather than a single dedicated file, these appear throughout the project's
queries — a more realistic reflection of how they're actually used:

- **Conditional aggregation (`-If` combinators):** `countIf`, `uniqIf`,
  `uniqExactIf`, `sumIf` — ClickHouse's idiomatic alternative to `CASE WHEN`
  inside aggregate functions.
- **Date/time functions:** `toStartOfMonth`, `toDate`, `now()`, `INTERVAL`,
  `dateDiff`, `addMonths`, `addDays`.
- **Array functions:** `arrayJoin`, `arrayMap`, `range`, `groupArray`.
- **Null handling:** `nullIf`, `coalesce`.

## 🧠 Notable Learnings & Trade-offs

- `LAG()` in ClickHouse returns `0` (not `NULL`) when there's no prior row —
  requires explicit handling with `nullIf()`.
- `uniq()` is approximate (HyperLogLog); `uniqExact()` is precise but heavier —
  a real performance/accuracy trade-off at scale.
- Rolling-window joins (used for WAU/MAU) don't scale to billions of rows;
  production systems would use pre-aggregated tables or Materialized Views instead.
- ClickHouse has no native `generate_series` — date spines are built with
  `arrayJoin(arrayMap(...))`.
  - In ClickHouse, `LEFT JOIN` on non-nullable numeric columns (e.g. `UInt32`)
  returns `0` for unmatched rows, not `NULL` — filtering for "no match" needs
  `WHERE col = 0`, not `WHERE col IS NULL`.
- `ALTER TABLE ADD COLUMN` only changes the schema — it doesn't backfill or
  remove old rows, so schema changes on an already-loaded table can require
  a `TRUNCATE` + reload to avoid duplicate/stale data.

## 🔜 Coming Next

- [ ] dbt models (staging → fact layer)
- [ ] Power BI dashboard

---
*Built step-by-step as a learning project — commits reflect incremental progress.*

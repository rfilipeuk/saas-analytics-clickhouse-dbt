# SaaS Analytics with ClickHouse & dbt

A hands-on portfolio project simulating a SaaS data stack using synthetic data, ClickHouse SQL, dbt, and Power BI.

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

## 🧠 Notable Learnings & Trade-offs

- `LAG()` in ClickHouse returns `0` (not `NULL`) when there's no prior row —
  requires explicit handling with `nullIf()`.
- `uniq()` is approximate (HyperLogLog); `uniqExact()` is precise but heavier —
  a real performance/accuracy trade-off at scale.
- Rolling-window joins (used for WAU/MAU) don't scale to billions of rows;
  production systems would use pre-aggregated tables or Materialized Views instead.
- ClickHouse has no native `generate_series` — date spines are built with
  `arrayJoin(arrayMap(...))`.

## 🔜 Coming Next

- [ ] dbt models (staging → fact layer)
- [ ] Power BI dashboard
- [ ] A/B test analysis
- [ ] Complex aggregations (grouping + decreasing sets)

---
*Built step-by-step as a learning project — commits reflect incremental progress.*

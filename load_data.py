import clickhouse_connect
import pandas as pd

client = clickhouse_connect.get_client(host='localhost', port=8123, database='saas_analytics', username='default', password='portfolio123')

# ---------- USERS ----------
users_df = pd.read_csv("data/users.csv", parse_dates=["signup_date"])
client.insert_df("users", users_df)
print(f"Inserted {len(users_df)} rows into users")

# ---------- EVENTS ----------
events_df = pd.read_csv("data/events.csv", parse_dates=["event_time"])
events_df["feature_name"] = events_df["feature_name"].fillna("")
client.insert_df("events", events_df)
print(f"Inserted {len(events_df)} rows into events")

# ---------- SUBSCRIPTIONS ----------
subs_df = pd.read_csv("data/subscriptions.csv", parse_dates=["start_date", "end_date"])
client.insert_df("subscriptions", subs_df)
print(f"Inserted {len(subs_df)} rows into subscriptions")
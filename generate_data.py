import random
from datetime import datetime, timedelta
from faker import Faker
import pandas as pd

fake = Faker()
random.seed(42)

N_USERS = 2000
START_DATE = datetime(2024, 1, 1)
END_DATE = datetime(2025, 12, 31)
PLANS = ["free", "pro", "enterprise"]
COUNTRIES = ["US", "UK", "BR", "DE", "IN", "CA"]

def random_date(start, end):
    delta = end - start
    return start + timedelta(days=random.randint(0, delta.days))

# -------- USERS --------
users = []
for user_id in range(1, N_USERS + 1):
    signup_date = random_date(START_DATE, END_DATE)
    plan = random.choices(PLANS, weights=[0.7, 0.25, 0.05])[0]
    # A/B test: randomly assign each user to variant A (control) or B (test)
    variant = random.choice(["A", "B"])
    users.append({
        "user_id": user_id,
        "signup_date": signup_date.date(),
        "plan": plan,
        "country": random.choice(COUNTRIES),
        "variant": variant
    })
users_df = pd.DataFrame(users)

# -------- EVENTS (funnel + engagement) --------
FEATURES = ["dashboard", "reports", "api_access", "export", "integrations"]
events = []
event_id = 1

for u in users:
    signup_dt = datetime.combine(u["signup_date"], datetime.min.time())

    # Everyone has a signup event
    events.append({"event_id": event_id, "user_id": u["user_id"], "event_type": "signup",
                    "event_time": signup_dt, "feature_name": ""})
    event_id += 1

    # Variant B (new onboarding) has a higher login conversion rate: 85% vs 70%
    login_probability = 0.85 if u["variant"] == "B" else 0.70
    if random.random() < login_probability:
        login_time = signup_dt + timedelta(hours=random.randint(1, 48))
        events.append({"event_id": event_id, "user_id": u["user_id"], "event_type": "login",
                        "event_time": login_time, "feature_name": ""})
        event_id += 1

        # Simulate ongoing logins + feature usage over following months
        n_sessions = random.randint(0, 40)
        for _ in range(n_sessions):
            session_time = login_time + timedelta(days=random.randint(1, 300))
            if session_time > END_DATE:
                continue
            events.append({"event_id": event_id, "user_id": u["user_id"], "event_type": "login",
                            "event_time": session_time, "feature_name": ""})
            event_id += 1

            # 50% chance they use a feature during a session
            if random.random() < 0.5:
                events.append({"event_id": event_id, "user_id": u["user_id"],
                                "event_type": "feature_use", "event_time": session_time,
                                "feature_name": random.choice(FEATURES)})
                event_id += 1

events_df = pd.DataFrame(events)

# -------- SUBSCRIPTIONS (upgrade + churn) --------
subscriptions =[]
sub_id = 1
mrr_map = {"free": 0.0, "pro": 29.0, "enterprise": 199.0}

for u in users:
    start = u["signup_date"]
    plan = u["plan"]

    # 20% chance the subscription churn (ends) before END_DATE 
    end_date = None
    if plan != "free" and random.random() < 0.20:
        churn_offset = random.randint(30, 500)
        candidate_end = datetime.combine(start, datetime.min.time()) + timedelta(days=churn_offset)
        if candidate_end < END_DATE:
            end_date = candidate_end.date()

    subscriptions.append({
        "subscription_id": sub_id,
        "user_id": u["user_id"],
        "plan": plan,
        "start_date": start,
        "end_date": end_date,
        "mrr": mrr_map[plan]
    })
    sub_id ++ 1

subscriptions_df = pd.DataFrame(subscriptions)

# -------- SAVE TO CSV --------
users_df.to_csv("data/users.csv", index=False)
events_df.to_csv("data/events.csv", index=False)
subscriptions_df.to_csv("data/subscriptions.csv", index=False)

print(f"Generated {len(users_df)} users, {len(events_df)} events, {len(subscriptions_df)} subscriptions")
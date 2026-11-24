"""AML alert scenarios, version-controlled in Git and run inside CAS by CAS Gateway.

Each scenario is one rule. Change a threshold here, review the change in Git,
and the next Gateway job runs the new version. All data is synthetic.
"""
import pandas as pd

SCENARIO_VERSION = "1.0"

SCENARIOS = {
    # repeated cash deposits just under the reporting threshold
    "structuring": lambda d: d["n_cash_near_threshold"] >= 2,
    # a quarter or more of activity with high-risk countries
    "high_risk_geography": lambda d: d["high_risk_country_share"] >= 0.25,
    # activity at least double the customer's usual level
    "velocity_spike": lambda d: d["txn_velocity_ratio"] >= 2.0,
    # politically exposed person sending international wires
    "pep_wires": lambda d: (d["pep_flag"] == 1) & (d["n_intl_wires"] >= 1),
    # account under 6 months old taking large cash deposits
    "new_account_cash": lambda d: (d["account_age_months"] < 6) & (d["cash_deposit_total"] >= 10_000),
}


def score(df: pd.DataFrame) -> pd.DataFrame:
    """One row per customer: a 0/1 flag per scenario, how many hit, and the alert."""
    keep = [c for c in ["customer_id", "segment", "partition", "sar_flag"] if c in df.columns]
    out = df[keep].copy()
    flags = [f"scn_{name}" for name in SCENARIOS]
    for name, rule in SCENARIOS.items():
        out[f"scn_{name}"] = rule(df).astype(int)
    out["n_scenarios_hit"] = out[flags].sum(axis=1)
    out["alert"] = (out["n_scenarios_hit"] > 0).astype(int)
    out["scenario_version"] = SCENARIO_VERSION
    return out

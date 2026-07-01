---
name: model-lifecycle
description: "ML model lifecycle for trading — training, validation, deployment, drift detection, retraining triggers"
triggers:
  - "model lifecycle"
  - "train model"
  - "model deployment"
  - "model drift"
  - "retrain"
  - "ml pipeline"
---

# Model Lifecycle — ML for Trading

## When to Invoke

Use when building, deploying, or maintaining ML models for trading signals — from initial training through production monitoring and retraining.

## The Trading ML Lifecycle

```
Research → Train → Validate → Paper Trade → Deploy → Monitor → Retrain
    ↑                                                              │
    └──────────────────────────────────────────────────────────────┘
```

## Step 1: Problem Formulation

**What are you predicting?**

| Target | Horizon | Model Type |
|--------|---------|-----------|
| Direction (up/down) | 1-5 days | Classification |
| Return magnitude | 1-21 days | Regression |
| Volatility | 1-5 days | Regression / GARCH |
| Ranking (best vs worst) | Rebalance period | Learning-to-rank |
| Regime (bull/bear/sideways) | Variable | HMM / Classification |

**Key question:** Is this a cross-sectional problem (rank stocks vs each other) or time-series (predict one asset's future)?

## Step 2: Training

```python
class TradingModel:
    def __init__(self, config: ModelConfig):
        self.config = config
        self.model = None
        self.feature_pipeline = None
    
    def train(self, X_train: pd.DataFrame, y_train: pd.Series):
        """
        RULES:
        1. No future leakage in features (validate with purging)
        2. Use time-series cross-validation (not random split)
        3. Purge overlap period between train/test folds
        4. Embargo period after test to prevent information leakage
        """
        pass
```

### Time-Series Cross-Validation (CRITICAL)

```python
from sklearn.model_selection import TimeSeriesSplit

def purged_cv(X, y, n_splits=5, purge_days=5, embargo_days=2):
    """
    Walk-forward CV with purging and embargo.
    
    Purge: remove [purge_days] between train and test to prevent
           label leakage from overlapping return windows.
    Embargo: skip [embargo_days] after test before next train fold
             to prevent serial correlation leakage.
    """
    tscv = TimeSeriesSplit(n_splits=n_splits)
    
    for train_idx, test_idx in tscv.split(X):
        # Purge: remove train samples too close to test
        train_end = train_idx[-1]
        test_start = test_idx[0]
        purge_mask = train_idx < (test_start - purge_days)
        train_idx_purged = train_idx[purge_mask]
        
        # Embargo: skip samples after test
        embargo_mask = test_idx < (test_idx[-1] - embargo_days)
        
        yield train_idx_purged, test_idx
```

### Model Choices for Trading

| Model | Strengths | Weaknesses | Use For |
|-------|-----------|-----------|---------|
| XGBoost / LightGBM | Fast, handles tabular, feature importance | Overfits, no sequential awareness | Cross-sectional signals |
| LSTM / Transformer | Captures temporal patterns | Data hungry, overfit risk | Time-series forecasting |
| Linear (Ridge/Lasso) | Interpretable, hard to overfit | Limited complexity | Factor models, combination |
| Random Forest | Robust, hard to overfit | Slow, no extrapolation | Regime classification |
| Ensemble (stacking) | Best of multiple models | Complex, expensive | Production combining |

## Step 3: Validation

```python
def validate_model(model, X_test, y_test, prices) -> ModelValidation:
    """
    Don't just check accuracy — check PROFITABILITY.
    A model that's 51% accurate but wrong on big moves = losing money.
    """
    predictions = model.predict(X_test)
    
    # Standard ML metrics
    accuracy = accuracy_score(y_test, predictions > 0)
    
    # TRADING metrics (what actually matters)
    strategy_returns = predictions * prices.pct_change().shift(-1)
    sharpe = strategy_returns.mean() / strategy_returns.std() * np.sqrt(252)
    
    # Are predictions CALIBRATED? (does confidence = accuracy?)
    # Overconfident models trade too much and lose on costs
    
    return ModelValidation(
        accuracy=accuracy,
        sharpe=sharpe,
        turnover=calculate_turnover(predictions),
        cost_adjusted_sharpe=sharpe_after_costs(strategy_returns, turnover),
    )
```

## Step 4: Paper Trading

Before real money:
1. Deploy model to production infrastructure
2. Generate signals daily (or intraday)
3. Track hypothetical PnL for 3+ months
4. Compare to backtest expectations
5. Monitor for data pipeline issues, latency, errors

**Pass criteria:**
- Paper PnL within 1 standard deviation of backtest expectation
- No systematic errors (always wrong on Mondays, etc.)
- Infrastructure reliable (no missed signals, no stale data)
- Execution assumptions hold (fills achievable at predicted prices)

## Step 5: Production Deployment

```python
class ModelServer:
    def __init__(self, model_path: str, feature_pipeline: Pipeline):
        self.model = load_model(model_path)
        self.features = feature_pipeline
        self.version = model_path.split("/")[-1]
        self.deployed_at = datetime.now()
    
    def predict(self, market_data: pd.DataFrame) -> pd.Series:
        """Generate signals for today's trading."""
        features = self.features.transform(market_data)
        
        # Validate inputs
        assert not features.isna().any().any(), "NaN in features — data pipeline broken"
        
        # Generate predictions
        signals = self.model.predict(features)
        
        # Log for monitoring
        log_prediction(self.version, features, signals)
        
        return signals
```

## Step 6: Monitoring & Drift Detection

```python
class ModelMonitor:
    def __init__(self, model_version: str, baseline_metrics: ModelValidation):
        self.version = model_version
        self.baseline = baseline_metrics
    
    def check_drift(self, recent_features: pd.DataFrame, recent_returns: pd.Series) -> DriftReport:
        """
        Detect when the model should be retrained.
        """
        alerts = []
        
        # Performance drift: Sharpe decaying
        rolling_sharpe = recent_returns.rolling(63).apply(
            lambda x: x.mean() / x.std() * np.sqrt(252)
        )
        if rolling_sharpe.iloc[-1] < self.baseline.sharpe * 0.5:
            alerts.append("CRITICAL: Sharpe dropped below 50% of baseline")
        
        # Feature drift: input distribution shifted
        for col in recent_features.columns:
            ks_stat, p_value = ks_2samp(
                self.baseline_features[col].dropna(),
                recent_features[col].dropna()
            )
            if p_value < 0.01:
                alerts.append(f"Feature drift: {col} (KS p={p_value:.4f})")
        
        # Prediction drift: model confidence collapsing
        recent_preds = self.model.predict_proba(recent_features)
        avg_confidence = np.abs(recent_preds - 0.5).mean()
        if avg_confidence < 0.05:
            alerts.append("Model confidence collapsed — predicting near-random")
        
        return DriftReport(alerts=alerts, retrain_recommended=len(alerts) > 0)
```

### Retraining Triggers

| Trigger | Threshold | Action |
|---------|-----------|--------|
| Sharpe decay | < 50% of baseline for 21 days | Retrain |
| Feature drift | KS test p < 0.01 on 3+ features | Investigate, maybe retrain |
| Regime change | VIX spike, correlation breakdown | Retrain on recent data |
| Calendar | Every 3-6 months regardless | Scheduled retrain |
| Data update | New alternative data source added | Retrain with new features |

## Step 7: Retraining

```python
def retrain(current_model, new_data, config):
    """
    Retrain with EXPANDING window (include all history)
    or ROLLING window (recent data only — if regime matters more).
    
    ALWAYS validate new model against current model before swapping.
    """
    new_model = train(new_data, config)
    
    # Compare new vs current on recent OOS data
    validation_period = new_data.tail(63)  # Last 3 months
    new_perf = validate(new_model, validation_period)
    old_perf = validate(current_model, validation_period)
    
    # Only deploy if new model is better
    if new_perf.sharpe > old_perf.sharpe * 0.9:  # Allow slight regression
        deploy(new_model)
        log(f"Deployed new model: Sharpe {new_perf.sharpe:.2f} vs old {old_perf.sharpe:.2f}")
    else:
        log(f"Kept old model: new Sharpe {new_perf.sharpe:.2f} worse than old {old_perf.sharpe:.2f}")
```

## Output

```markdown
## Model Status

**Model**: [name/version]
**Deployed**: [date]
**Age**: [days since last retrain]

| Metric | Baseline | Current (63d) | Status |
|--------|----------|---------------|--------|
| Sharpe | X | X | OK/DEGRADED |
| Accuracy | X% | X% | OK/DEGRADED |
| Turnover | X% | X% | OK/HIGH |
| Feature drift | — | [N features drifting] | OK/ALERT |
| Confidence | X | X | OK/LOW |

**Retrain recommended**: YES/NO
**Reason**: [if yes, why]
```

## Principles

- **Backtest != live performance** — always paper trade first
- **Simple models degrade slower** — ensembles overfit more
- **Retrain on schedule AND on trigger** — don't wait for disaster
- **A/B test models** — run new model at small size alongside current
- **Log everything** — features, predictions, fills, PnL. You'll need it for debugging.

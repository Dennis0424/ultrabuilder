---
name: backtest
description: "Backtesting methodology — strategy validation, bias avoidance, walk-forward optimization, performance metrics"
triggers:
  - "backtest"
  - "test strategy"
  - "validate strategy"
  - "walk forward"
  - "historical performance"
  - "backtesting"
---

# Backtest — Strategy Validation

## When to Invoke

Use when developing, validating, or debugging a trading strategy. This skill ensures rigorous backtesting methodology that avoids common pitfalls leading to strategies that look great historically but fail live.

## The Cardinal Sins of Backtesting

These biases WILL fool you. Check every strategy against them:

| Bias | What It Is | How to Prevent |
|------|-----------|----------------|
| **Look-ahead** | Using future data in current decisions | Strict point-in-time data, no future leakage |
| **Survivorship** | Testing only on stocks that still exist | Include delisted/bankrupt securities |
| **Overfitting** | Strategy only works on specific historical period | Out-of-sample testing, walk-forward |
| **Selection** | Cherry-picking the best backtest from many | Report ALL strategies tested, Bonferroni correction |
| **Transaction cost** | Ignoring real costs (spread, slippage, commission) | Realistic cost models (2-5bps per side minimum) |
| **Market impact** | Assuming infinite liquidity | Size-aware fills, volume participation limits |

## Workflow

### Step 1: Data Preparation

```python
# Point-in-time data (CRITICAL — no future leakage)
# Bad: Using today's S&P 500 members to test a 2015 strategy
# Good: Using the ACTUAL S&P 500 membership as of each historical date

# Check for survivorship bias
assert dataset.includes_delisted == True
assert dataset.point_in_time == True

# Data splits (NEVER touch test until final validation)
TRAIN = data[:"2018"]        # Develop strategy here
VALIDATE = data["2019":"2021"] # Tune parameters here
TEST = data["2022":]          # Final out-of-sample (ONE shot only)
```

### Step 2: Strategy Implementation

```python
class Strategy:
    def __init__(self, params: StrategyParams):
        self.params = params
    
    def generate_signals(self, market_data: pd.DataFrame) -> pd.Series:
        """
        RULES:
        1. Only use data available at signal time (no future columns)
        2. Account for publication lag (earnings: +1 day, filings: +2 days)
        3. Return position sizes, not just direction
        """
        pass
    
    def calculate_positions(self, signals: pd.Series, portfolio: Portfolio) -> Dict[str, float]:
        """
        Convert signals to actual positions considering:
        - Position sizing (risk budget per trade)
        - Correlation with existing positions
        - Liquidity constraints (% of ADV)
        - Sector/factor exposure limits
        """
        pass
```

### Step 3: Walk-Forward Optimization

```python
# Rolling window approach (prevents overfitting to one period)
# Train on N years, validate on next M months, roll forward

TRAIN_WINDOW = 252 * 3  # 3 years
TEST_WINDOW = 63        # 3 months
STEP = 21              # Roll monthly

results = []
for start in range(0, len(data) - TRAIN_WINDOW - TEST_WINDOW, STEP):
    train = data[start : start + TRAIN_WINDOW]
    test = data[start + TRAIN_WINDOW : start + TRAIN_WINDOW + TEST_WINDOW]
    
    # Optimize on train
    best_params = optimize(strategy, train)
    
    # Test on unseen data
    result = run_backtest(strategy, best_params, test)
    results.append(result)

# Aggregate walk-forward results (this IS your expected performance)
walk_forward_sharpe = aggregate_sharpe(results)
```

### Step 4: Performance Metrics

```python
@dataclass
class BacktestResult:
    # Returns
    total_return: float          # Total % return
    annualized_return: float     # CAGR
    sharpe_ratio: float          # Risk-adjusted return (target: > 1.5)
    sortino_ratio: float         # Downside-risk-adjusted (target: > 2.0)
    calmar_ratio: float          # Return / max drawdown
    
    # Risk
    max_drawdown: float          # Worst peak-to-trough (target: < 20%)
    max_drawdown_duration: int   # Days in worst drawdown
    volatility: float            # Annualized standard deviation
    var_95: float                # Value at Risk (95%)
    cvar_95: float               # Conditional VaR (expected loss beyond VaR)
    
    # Behavior
    win_rate: float              # % of profitable trades
    profit_factor: float         # Gross profit / gross loss (target: > 1.5)
    avg_holding_period: float    # Days per trade
    turnover: float              # Annual portfolio turnover
    
    # Costs
    total_commission: float
    total_slippage: float
    cost_drag: float             # Annual cost as % of NAV
    
    # Robustness
    worst_month: float
    worst_year: float
    correlation_to_market: float # Should be low for alpha strategies
    information_ratio: float     # Alpha / tracking error
```

### Step 5: Robustness Checks

Run these BEFORE declaring a strategy ready:

1. **Parameter sensitivity** — vary each parameter ±20%. If Sharpe collapses, it's overfit.
2. **Random entry test** — replace signals with random. If still profitable, it's market beta not alpha.
3. **Transaction cost sensitivity** — double the costs. Still viable?
4. **Regime analysis** — does it work in bull AND bear markets? Or only one?
5. **Correlation check** — is this just disguised market/factor exposure?
6. **Capacity analysis** — at what AUM does market impact kill the edge?

### Step 6: Report

```markdown
## Backtest Report: [Strategy Name]

**Period**: [start] — [end]
**Universe**: [what securities, how selected]
**Rebalance**: [frequency]
**Costs**: [commission + slippage model]

### Performance
| Metric | In-Sample | Out-of-Sample | Walk-Forward |
|--------|-----------|---------------|--------------|
| Annual Return | X% | X% | X% |
| Sharpe | X | X | X |
| Max Drawdown | X% | X% | X% |
| Win Rate | X% | X% | X% |

### Robustness
- Parameter sensitivity: PASS / FAIL
- Random entry test: PASS / FAIL
- Cost sensitivity: PASS / FAIL
- Regime analysis: [works in: bull/bear/sideways]
- Factor exposure: [correlation to SPY, momentum, value, etc.]

### Verdict: DEPLOY / PAPER TRADE / REJECT
**Reasoning**: [why]
**Next step**: [what to do]
```

## Frameworks

| Framework | Best For | Language |
|-----------|----------|----------|
| vectorbt | Fast vectorized backtests | Python |
| backtrader | Event-driven, realistic fills | Python |
| zipline | Pipeline API, factor models | Python |
| QuantConnect (Lean) | Multi-asset, live trading ready | C#/Python |
| Custom | Full control, production systems | Python/Rust |

## Principles

- **If it looks too good, it IS too good** — Sharpe > 3 in backtest = almost certainly overfit
- **Out-of-sample is truth** — in-sample performance is marketing, OOS is reality
- **Costs kill strategies** — a 5bps-per-side strategy needs 10bps edge minimum
- **Simplicity survives** — complex strategies overfit; simple ones degrade gracefully
- **Paper trade before real money** — minimum 3 months live paper trading matching backtest

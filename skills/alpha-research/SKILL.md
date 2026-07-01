---
name: alpha-research
description: "Alpha research — signal discovery, factor analysis, statistical significance testing, decay analysis"
triggers:
  - "alpha research"
  - "signal discovery"
  - "factor analysis"
  - "alpha decay"
  - "find alpha"
  - "trading signal"
---

# Alpha Research — Signal Discovery

## When to Invoke

Use when searching for new trading signals, analyzing factor exposures, testing whether a signal has genuine predictive power, or monitoring alpha decay in existing strategies.

## What is Alpha?

Alpha = returns unexplained by known risk factors. If your "alpha" is just beta to momentum, it's not alpha.

```
Total Return = Risk-Free + Beta * Market + Factor Exposures + TRUE ALPHA + Noise
                                                              ^^^^^^^^^^^^
                                          This is what you're looking for
```

## The Research Pipeline

```
Hypothesis → Data → Signal → Test → Attribute → Size → Monitor Decay
```

## Step 1: Hypothesis Generation

**Sources of edge:**

| Source | Example | Why it might work |
|--------|---------|-------------------|
| Behavioral bias | Anchoring to 52-week high | Humans are irrational |
| Information asymmetry | Parsing SEC filings faster | Speed advantage |
| Structural constraint | Index rebalancing flows | Forced buyers/sellers |
| Market microstructure | Bid-ask bounce patterns | Mechanical inefficiency |
| Alternative data | Satellite imagery of inventory | Information advantage |
| Factor combination | Value + momentum intersection | Diversification of edges |

**Rule: Start with WHY it should work, not with data mining.**

## Step 2: Signal Construction

```python
class AlphaSignal:
    def __init__(self, name: str, hypothesis: str):
        self.name = name
        self.hypothesis = hypothesis
    
    def compute(self, data: pd.DataFrame) -> pd.Series:
        """
        Returns a signal value for each asset at each timestamp.
        
        RULES:
        1. Point-in-time only (no future data)
        2. Must be computable in production (not just backtest)
        3. Cross-sectional normalization (rank or z-score within universe)
        4. Handle NaN gracefully
        """
        pass
    
    def to_positions(self, signal: pd.Series, method: str = "rank") -> pd.Series:
        """
        Signal → position weights.
        
        Methods:
        - rank: Long top quintile, short bottom quintile
        - zscore: Size proportional to z-score
        - threshold: Long if signal > X, short if < -X
        """
        if method == "rank":
            ranks = signal.rank(pct=True)
            # Long top 20%, short bottom 20%, zero middle 60%
            positions = pd.Series(0, index=signal.index)
            positions[ranks > 0.8] = 1.0
            positions[ranks < 0.2] = -1.0
            return positions / positions.abs().sum()  # Normalize to dollar-neutral
        pass
```

## Step 3: Statistical Testing

### Is the signal real or luck?

```python
def test_signal_significance(signal_returns: pd.Series) -> Dict:
    """
    Multiple tests — no single test is sufficient.
    """
    n = len(signal_returns)
    
    # T-test: Is mean return significantly different from zero?
    t_stat = signal_returns.mean() / (signal_returns.std() / np.sqrt(n))
    t_pvalue = 2 * (1 - stats.t.cdf(abs(t_stat), n - 1))
    
    # Sharpe ratio with confidence interval
    sharpe = signal_returns.mean() / signal_returns.std() * np.sqrt(252)
    sharpe_se = np.sqrt((1 + 0.5 * sharpe**2) / n)  # Lo (2002) approximation
    
    # Deflated Sharpe Ratio (Harvey & Liu 2015)
    # Adjusts for multiple testing — how many signals did you try?
    # DSR = Prob(SR* > 0 | multiple testing)
    
    # Information Coefficient (rank correlation of signal vs forward returns)
    ic = stats.spearmanr(signal_returns.index, signal_returns.values)[0]
    ic_t = ic * np.sqrt(n - 2) / np.sqrt(1 - ic**2)
    
    return {
        "t_stat": t_stat,
        "t_pvalue": t_pvalue,
        "sharpe": sharpe,
        "sharpe_ci_95": (sharpe - 1.96 * sharpe_se, sharpe + 1.96 * sharpe_se),
        "information_coefficient": ic,
        "ic_t_stat": ic_t,
        "n_observations": n,
        "significant_at_5pct": t_pvalue < 0.05,
    }
```

### Multiple Testing Correction

```python
def bonferroni_threshold(n_strategies_tested: int, alpha: float = 0.05) -> float:
    """
    If you tested 100 strategies, the significance bar is 100x higher.
    
    Required t-stat ≈ 3.0+ for real-world quant research
    (much higher than academic 1.96)
    """
    corrected_alpha = alpha / n_strategies_tested
    from scipy.stats import norm
    return norm.ppf(1 - corrected_alpha / 2)

# Harvey, Liu, Zhu (2016): t-stat > 3.0 for new factors
# Given thousands of factors tested historically
MINIMUM_T_STAT = 3.0
```

## Step 4: Factor Attribution

```python
def attribute_returns(strategy_returns: pd.Series, factor_returns: pd.DataFrame) -> Dict:
    """
    Regress strategy returns against known factors.
    What's left (alpha) is your TRUE edge.
    
    Common factor models:
    - CAPM: Market only
    - Fama-French 3: Market + Size + Value
    - Fama-French 5: + Profitability + Investment
    - Carhart 4: FF3 + Momentum
    - AQR 6: FF5 + Momentum
    """
    import statsmodels.api as sm
    
    X = sm.add_constant(factor_returns)
    model = sm.OLS(strategy_returns, X).fit()
    
    return {
        "alpha_annualized": model.params["const"] * 252,
        "alpha_t_stat": model.tvalues["const"],
        "alpha_significant": model.pvalues["const"] < 0.05,
        "r_squared": model.rsquared,
        "factor_exposures": dict(model.params.drop("const")),
        "unexplained_variance": 1 - model.rsquared,
    }
```

### Interpreting Results

| Result | Meaning | Action |
|--------|---------|--------|
| High alpha, low R-squared | True alpha, uncorrelated | Deploy |
| High alpha, high factor beta | Alpha is disguised factor exposure | Hedge factors or reclassify |
| Low alpha, high Sharpe | Return is all factor exposure | Cheaper to buy factor ETFs |
| Alpha decays after costs | Edge exists but not tradeable | Reduce turnover or abandon |

## Step 5: Decay Analysis

```python
def analyze_alpha_decay(signal: pd.Series, forward_returns: pd.DataFrame) -> pd.Series:
    """
    How quickly does the signal lose predictive power?
    
    Compute IC at different horizons: 1d, 5d, 21d, 63d
    Signal that decays in 1 day = high-frequency (needs low latency)
    Signal that persists 63 days = can trade monthly (lower costs)
    """
    decay_profile = {}
    
    for horizon in [1, 5, 10, 21, 42, 63]:
        fwd_ret = forward_returns[f"ret_{horizon}d"]
        ic = stats.spearmanr(signal, fwd_ret)[0]
        decay_profile[horizon] = ic
    
    # Half-life: at what horizon does IC drop to 50% of peak?
    peak_ic = max(decay_profile.values())
    half_life = None
    for h, ic in sorted(decay_profile.items()):
        if ic < peak_ic * 0.5:
            half_life = h
            break
    
    return {
        "decay_profile": decay_profile,
        "peak_horizon": max(decay_profile, key=decay_profile.get),
        "half_life_days": half_life,
        "optimal_rebalance": half_life,  # Rebalance at half-life
    }
```

## Step 6: Signal Combination

```python
def combine_signals(signals: Dict[str, pd.Series], method: str = "equal") -> pd.Series:
    """
    Multiple weak signals → one stronger signal.
    
    Methods:
    - equal: Simple average (surprisingly hard to beat)
    - ic_weighted: Weight by historical IC
    - pca: First principal component
    - ml: Train a model to combine (overfitting risk!)
    """
    signal_df = pd.DataFrame(signals)
    
    if method == "equal":
        return signal_df.mean(axis=1)
    elif method == "ic_weighted":
        # Weight each signal by its information coefficient
        ics = {name: calculate_ic(sig) for name, sig in signals.items()}
        weights = pd.Series(ics) / sum(ics.values())
        return (signal_df * weights).sum(axis=1)
```

## Output

```markdown
## Alpha Research Report: [Signal Name]

**Hypothesis**: [why this should work]
**Data**: [sources used]
**Universe**: [what assets]
**Period**: [backtest period]

### Signal Quality
| Metric | Value | Threshold | Status |
|--------|-------|-----------|--------|
| T-stat | X | > 3.0 | PASS/FAIL |
| Sharpe | X | > 1.5 | PASS/FAIL |
| IC (mean) | X | > 0.03 | PASS/FAIL |
| IC (hit rate) | X% | > 55% | PASS/FAIL |
| Turnover | X% | < 200% | PASS/FAIL |

### Factor Attribution
| Factor | Exposure | T-stat |
|--------|----------|--------|
| Market | X | X |
| Size | X | X |
| Value | X | X |
| Momentum | X | X |
| **Alpha** | **X** | **X** |

### Decay Profile
| Horizon | IC | Cumulative Return |
|---------|-----|-------------------|
| 1 day | X | X% |
| 5 days | X | X% |
| 21 days | X | X% |

**Half-life**: [X days]
**Optimal rebalance**: [frequency]

### Verdict: DEPLOY / MORE RESEARCH / REJECT
**Reasoning**: [why]
```

## Principles

- **Hypothesis first, data second** — data mining finds ghosts; theory finds edges
- **Multiple testing kills most signals** — if you tried 100 things, adjust for it
- **Factor exposure != alpha** — decompose before celebrating
- **Simplicity compounds** — two simple signals combined > one complex signal
- **Alpha decays** — monitor continuously; today's edge is tomorrow's crowded trade
- **t-stat > 3.0 or go home** — the 1.96 threshold is for single-test academia

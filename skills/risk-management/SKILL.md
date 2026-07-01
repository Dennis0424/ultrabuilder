---
name: risk-management
description: "Risk management — position sizing, drawdown control, VaR/CVaR, correlation monitoring, portfolio constraints"
triggers:
  - "risk management"
  - "position sizing"
  - "drawdown"
  - "var"
  - "risk limits"
  - "portfolio risk"
---

# Risk Management — Capital Preservation

## When to Invoke

Use when designing risk controls for a trading system, setting position limits, implementing drawdown protection, or monitoring portfolio risk in real-time.

## Philosophy

**Risk management is the only edge that compounds.** Alpha decays, but risk discipline persists.

## Position Sizing

### Kelly Criterion (theoretical optimal)

```python
def kelly_fraction(win_rate: float, win_loss_ratio: float) -> float:
    """
    Kelly = W - (1 - W) / R
    where W = win rate, R = avg_win / avg_loss
    
    NEVER use full Kelly. Use fractional Kelly (0.25-0.5x) for:
    - Parameter uncertainty
    - Non-normal distributions (fat tails)
    - Correlated positions
    """
    full_kelly = win_rate - (1 - win_rate) / win_loss_ratio
    return full_kelly * 0.25  # Quarter Kelly — conservative start
```

### Risk-Parity Position Sizing

```python
def risk_parity_weights(returns: pd.DataFrame, target_vol: float = 0.10) -> pd.Series:
    """
    Equal risk contribution — each position contributes equally to portfolio risk.
    Size inversely to volatility.
    """
    vols = returns.std() * np.sqrt(252)
    inv_vol = 1 / vols
    weights = inv_vol / inv_vol.sum()
    
    # Scale to target portfolio volatility
    port_vol = np.sqrt(weights @ returns.cov() * 252 @ weights)
    scale = target_vol / port_vol
    return weights * scale
```

### Fixed Fractional

```python
def fixed_fractional_size(
    capital: float,
    risk_per_trade: float,  # e.g., 0.01 = 1% of capital at risk
    entry_price: float,
    stop_loss_price: float,
) -> int:
    """
    Risk X% of capital per trade.
    Position size = (capital * risk%) / (entry - stop)
    """
    risk_amount = capital * risk_per_trade
    risk_per_share = abs(entry_price - stop_loss_price)
    shares = int(risk_amount / risk_per_share)
    return shares
```

## Risk Metrics

### Portfolio Level

```python
@dataclass
class RiskMetrics:
    # Volatility
    portfolio_volatility: float      # Annualized std dev of returns
    
    # Value at Risk
    var_95: float                    # 95% VaR (1-day): max loss 95% of the time
    var_99: float                    # 99% VaR (1-day): max loss 99% of the time
    cvar_95: float                   # Expected loss when VaR is breached
    
    # Drawdown
    current_drawdown: float          # Current distance from peak
    max_drawdown: float              # Worst historical peak-to-trough
    drawdown_duration: int           # Days in current drawdown
    
    # Concentration
    max_position_weight: float       # Largest single position (target: < 10%)
    top5_weight: float               # Sum of top 5 positions (target: < 40%)
    herfindahl_index: float          # Concentration measure (lower = more diversified)
    
    # Exposure
    net_exposure: float              # Long - Short (target: market-neutral ≈ 0)
    gross_exposure: float            # Long + Short (target: < 200%)
    beta: float                      # Market beta (target: < 0.3 for alpha strategies)
    sector_max: float                # Max sector exposure (target: < 25%)
    factor_exposure: Dict[str, float] # Exposure to common factors
```

### Computing VaR

```python
def historical_var(returns: pd.Series, confidence: float = 0.95) -> float:
    """Historical simulation VaR — non-parametric, captures fat tails."""
    return -np.percentile(returns, (1 - confidence) * 100)

def parametric_var(returns: pd.Series, confidence: float = 0.95) -> float:
    """Gaussian VaR — fast but underestimates tail risk."""
    from scipy.stats import norm
    mu = returns.mean()
    sigma = returns.std()
    return -(mu + sigma * norm.ppf(1 - confidence))

def cvar(returns: pd.Series, confidence: float = 0.95) -> float:
    """Expected Shortfall — average loss beyond VaR."""
    var = historical_var(returns, confidence)
    return -returns[returns <= -var].mean()
```

## Risk Limits

### Pre-Trade Checks

```python
class RiskLimits:
    MAX_POSITION_SIZE = 0.05         # 5% of NAV per position
    MAX_SECTOR_EXPOSURE = 0.25       # 25% in one sector
    MAX_GROSS_EXPOSURE = 2.0         # 200% gross leverage
    MAX_NET_EXPOSURE = 0.20          # 20% net (for market-neutral)
    MAX_CORRELATION = 0.7            # Between any two positions
    MAX_DAILY_LOSS = 0.02            # 2% daily stop-loss
    MAX_DRAWDOWN = 0.10              # 10% drawdown triggers review
    MAX_DRAWDOWN_HALT = 0.15         # 15% halts all trading
    MIN_LIQUIDITY_DAYS = 5           # Must be able to exit in 5 days
    MAX_ADV_PARTICIPATION = 0.05     # Max 5% of average daily volume

def check_order(self, order: Order, portfolio: Portfolio) -> Tuple[bool, str]:
    """Pre-trade risk check. Returns (approved, reason)."""
    
    # Position size limit
    position_value = order.quantity * order.price
    if position_value / portfolio.nav > self.MAX_POSITION_SIZE:
        return False, f"Position size {position_value/portfolio.nav:.1%} exceeds {self.MAX_POSITION_SIZE:.0%} limit"
    
    # Liquidity check
    days_to_exit = position_value / (order.symbol_adv * self.MAX_ADV_PARTICIPATION)
    if days_to_exit > self.MIN_LIQUIDITY_DAYS:
        return False, f"Would take {days_to_exit:.1f} days to exit (limit: {self.MIN_LIQUIDITY_DAYS})"
    
    # Sector exposure
    new_sector_exposure = portfolio.sector_exposure(order.sector) + position_value
    if new_sector_exposure / portfolio.nav > self.MAX_SECTOR_EXPOSURE:
        return False, f"Sector exposure would exceed {self.MAX_SECTOR_EXPOSURE:.0%}"
    
    return True, "Approved"
```

### Drawdown Circuit Breakers

```python
class DrawdownProtection:
    def __init__(self, portfolio: Portfolio):
        self.portfolio = portfolio
    
    def check(self) -> Action:
        dd = self.portfolio.current_drawdown
        
        if dd > 0.15:
            return Action.HALT_ALL_TRADING  # Flat everything, stop
        elif dd > 0.10:
            return Action.REDUCE_50PCT      # Cut all positions 50%
        elif dd > 0.05:
            return Action.NO_NEW_POSITIONS  # Hold only, no new entries
        else:
            return Action.NORMAL            # Trade normally
```

## Correlation Monitoring

```python
def rolling_correlation_matrix(returns: pd.DataFrame, window: int = 63) -> pd.DataFrame:
    """Monitor for correlation regime changes."""
    current_corr = returns.tail(window).corr()
    
    # Flag high correlations (diversification breaking down)
    high_corr_pairs = []
    for i in range(len(current_corr)):
        for j in range(i+1, len(current_corr)):
            if abs(current_corr.iloc[i, j]) > 0.7:
                high_corr_pairs.append((
                    current_corr.index[i],
                    current_corr.columns[j],
                    current_corr.iloc[i, j]
                ))
    
    return high_corr_pairs  # Alert if non-empty
```

## Output

```markdown
## Risk Report

**Portfolio NAV**: $[X]
**Current Drawdown**: [X]% (max historical: [X]%)

| Metric | Current | Limit | Status |
|--------|---------|-------|--------|
| Gross Exposure | X% | 200% | OK/BREACH |
| Net Exposure | X% | 20% | OK/BREACH |
| Max Position | X% | 5% | OK/BREACH |
| VaR (95%, 1d) | $X | — | — |
| CVaR (95%, 1d) | $X | — | — |
| Beta | X | 0.3 | OK/BREACH |

**Concentration**: [top 5 positions and weights]
**Correlations**: [high-correlation pairs]
**Circuit breaker status**: NORMAL / CAUTION / HALT
```

## Principles

- **Survive first, profit second** — can't compound if you're wiped out
- **Position sizing IS the strategy** — same signals + bad sizing = ruin
- **Diversification is the only free lunch** — but correlations spike in crises
- **Tail risk is real** — 6-sigma events happen more than Gaussian says
- **Limits are absolute** — no "just this once" exceptions
- **Monitor in real-time** — end-of-day risk checks are too slow for intraday

---
name: quant-monitor
description: "Quantitative monitoring — PnL tracking, strategy health, market regime detection, alerting, live dashboards"
triggers:
  - "monitor"
  - "pnl tracking"
  - "strategy health"
  - "regime detection"
  - "quant alerts"
  - "live monitoring"
---

# Quant Monitor — Production Surveillance

## When to Invoke

Use when building monitoring infrastructure for live trading — PnL attribution, strategy health checks, market regime detection, and alerting systems.

## Why Monitoring Matters

**The strategy doesn't tell you when it stops working.** By the time you notice the drawdown, it's already too late. Proactive monitoring catches problems when they're small.

## System Architecture

```
Market Data → Strategy Engine → Orders → Fills
     ↓              ↓              ↓       ↓
   Regime       Signals        Execution  PnL
   Monitor      Monitor        Monitor    Monitor
     ↓              ↓              ↓       ↓
     └──────────────┴──────────────┴───────┘
                        ↓
                   Alert Engine
                        ↓
              ┌─────────┼─────────┐
              ↓         ↓         ↓
          Dashboard   Slack/    Auto-
                      Email     Action
```

## PnL Tracking

```python
class PnLTracker:
    def __init__(self, portfolio: Portfolio):
        self.portfolio = portfolio
        self.daily_pnl = []
        self.intraday_pnl = []
    
    def update(self, timestamp: datetime, prices: Dict[str, float]):
        """Mark-to-market all positions."""
        total_pnl = 0
        attribution = {}
        
        for symbol, position in self.portfolio.positions.items():
            current_price = prices[symbol]
            position_pnl = position.quantity * (current_price - position.avg_cost)
            total_pnl += position_pnl
            attribution[symbol] = position_pnl
        
        self.intraday_pnl.append({
            "timestamp": timestamp,
            "total_pnl": total_pnl,
            "attribution": attribution,
            "nav": self.portfolio.nav + total_pnl,
        })
    
    def daily_summary(self) -> DailySummary:
        """End-of-day PnL summary with attribution."""
        return DailySummary(
            date=date.today(),
            pnl=self.intraday_pnl[-1]["total_pnl"],
            pnl_pct=self.intraday_pnl[-1]["total_pnl"] / self.portfolio.nav,
            nav=self.intraday_pnl[-1]["nav"],
            high_water_mark=max(p["nav"] for p in self.intraday_pnl),
            drawdown=self._current_drawdown(),
            sharpe_30d=self._rolling_sharpe(30),
            sharpe_90d=self._rolling_sharpe(90),
            top_winners=self._top_n(5, ascending=False),
            top_losers=self._top_n(5, ascending=True),
        )
```

## Strategy Health Metrics

```python
@dataclass
class StrategyHealth:
    # Performance
    sharpe_30d: float          # Rolling 30-day Sharpe
    sharpe_90d: float          # Rolling 90-day Sharpe
    return_ytd: float          # Year-to-date return
    
    # Consistency
    hit_rate_30d: float        # % of profitable days (last 30)
    profit_factor_30d: float   # Gross profit / gross loss
    longest_losing_streak: int # Current consecutive losing days
    
    # Behavior
    turnover_vs_expected: float    # Actual / expected turnover ratio
    signal_count_vs_expected: float # Are signals generating normally?
    correlation_to_benchmark: float # Has correlation changed?
    
    # Infrastructure
    data_staleness: timedelta  # Time since last data update
    fill_rate: float          # Orders filled / orders submitted
    latency_p99: float        # 99th percentile execution latency


def check_strategy_health(metrics: StrategyHealth) -> List[Alert]:
    """Generate alerts based on health metrics."""
    alerts = []
    
    # Performance degradation
    if metrics.sharpe_30d < 0:
        alerts.append(Alert("CRITICAL", "30-day Sharpe negative", priority=1))
    elif metrics.sharpe_30d < 0.5:
        alerts.append(Alert("WARNING", "30-day Sharpe below 0.5", priority=2))
    
    # Behavior anomalies
    if metrics.turnover_vs_expected > 2.0:
        alerts.append(Alert("WARNING", "Turnover 2x above expected", priority=2))
    if metrics.signal_count_vs_expected < 0.3:
        alerts.append(Alert("CRITICAL", "Signal generation collapsed (< 30% of expected)", priority=1))
    
    # Infrastructure
    if metrics.data_staleness > timedelta(minutes=30):
        alerts.append(Alert("CRITICAL", "Data stale > 30 minutes", priority=0))
    if metrics.fill_rate < 0.8:
        alerts.append(Alert("WARNING", f"Fill rate {metrics.fill_rate:.0%} (< 80%)", priority=2))
    
    # Streak
    if metrics.longest_losing_streak >= 10:
        alerts.append(Alert("CRITICAL", f"{metrics.longest_losing_streak} consecutive losing days", priority=1))
    
    return alerts
```

## Market Regime Detection

```python
class RegimeDetector:
    """Detect market regime changes that affect strategy performance."""
    
    def __init__(self, lookback: int = 252):
        self.lookback = lookback
    
    def detect_regime(self, market_data: pd.DataFrame) -> Regime:
        """
        Regime classification based on:
        - Volatility level (low/medium/high)
        - Trend direction (bull/bear/sideways)
        - Correlation structure (normal/stressed)
        - Liquidity conditions (normal/thin)
        """
        returns = market_data["close"].pct_change()
        
        # Volatility regime
        current_vol = returns.tail(21).std() * np.sqrt(252)
        historical_vol_pct = stats.percentileofscore(
            returns.rolling(21).std().dropna() * np.sqrt(252),
            current_vol
        )
        
        if historical_vol_pct > 80:
            vol_regime = "high"
        elif historical_vol_pct < 20:
            vol_regime = "low"
        else:
            vol_regime = "medium"
        
        # Trend regime
        sma_50 = market_data["close"].rolling(50).mean().iloc[-1]
        sma_200 = market_data["close"].rolling(200).mean().iloc[-1]
        current_price = market_data["close"].iloc[-1]
        
        if current_price > sma_50 > sma_200:
            trend = "bull"
        elif current_price < sma_50 < sma_200:
            trend = "bear"
        else:
            trend = "sideways"
        
        # Correlation regime (are correlations spiking?)
        if hasattr(market_data, "columns") and len(market_data.columns) > 1:
            recent_corr = market_data.tail(21).corr().values
            mean_corr = np.mean(recent_corr[np.triu_indices_from(recent_corr, k=1)])
            corr_regime = "stressed" if mean_corr > 0.7 else "normal"
        else:
            corr_regime = "unknown"
        
        return Regime(
            volatility=vol_regime,
            trend=trend,
            correlation=corr_regime,
            vix=market_data.get("vix", {}).get("close", None),
        )
    
    def regime_changed(self, current: Regime, previous: Regime) -> bool:
        """Alert when regime shifts — strategy behavior may need adjustment."""
        return (
            current.volatility != previous.volatility or
            current.trend != previous.trend or
            current.correlation != previous.correlation
        )
```

## Alert System

```python
class AlertEngine:
    """Multi-channel alerting with deduplication and escalation."""
    
    CHANNELS = {
        0: ["pagerduty", "sms", "slack"],    # P0: All channels, immediate
        1: ["slack", "email"],               # P1: Slack + email
        2: ["slack"],                        # P2: Slack only
        3: ["dashboard"],                    # P3: Dashboard only (FYI)
    }
    
    def __init__(self):
        self.active_alerts = {}
        self.cooldowns = {}
    
    def fire(self, alert: Alert):
        """Send alert with deduplication and cooldown."""
        key = f"{alert.level}:{alert.message}"
        
        # Deduplicate: don't spam same alert
        if key in self.cooldowns:
            if datetime.now() - self.cooldowns[key] < timedelta(hours=1):
                return  # Still in cooldown
        
        # Send to appropriate channels
        channels = self.CHANNELS[alert.priority]
        for channel in channels:
            self._send(channel, alert)
        
        self.active_alerts[key] = alert
        self.cooldowns[key] = datetime.now()
    
    def _send(self, channel: str, alert: Alert):
        """Dispatch to channel."""
        if channel == "slack":
            slack_webhook(f"[{alert.level}] {alert.message}")
        elif channel == "email":
            send_email(subject=f"Trading Alert: {alert.level}", body=alert.message)
        elif channel == "pagerduty":
            pagerduty_trigger(alert)
```

## Dashboard Metrics

```python
# Key metrics to display on a live trading dashboard

DASHBOARD_PANELS = {
    "portfolio_overview": {
        "nav": "Current NAV",
        "daily_pnl": "Today's PnL ($)",
        "daily_pnl_pct": "Today's PnL (%)",
        "mtd_return": "Month-to-date return",
        "ytd_return": "Year-to-date return",
        "drawdown": "Current drawdown from HWM",
    },
    "risk_snapshot": {
        "gross_exposure": "Long + Short value",
        "net_exposure": "Long - Short value",
        "var_95": "1-day 95% VaR",
        "beta": "Portfolio beta to SPY",
        "concentration": "Top 5 position weight",
    },
    "strategy_health": {
        "sharpe_30d": "30-day rolling Sharpe",
        "hit_rate": "Win rate (last 30 days)",
        "turnover": "Today's turnover",
        "signal_count": "Signals generated today",
        "fill_rate": "Order fill rate",
    },
    "market_context": {
        "spy_return": "S&P 500 today",
        "vix": "VIX level",
        "regime": "Current market regime",
        "correlation": "Average cross-asset correlation",
    },
}
```

## Runbook: Common Alerts

| Alert | Diagnosis | Action |
|-------|-----------|--------|
| Data stale > 30min | API down? Network? | Check data provider status, switch to backup |
| Sharpe negative 30d | Alpha decayed? Regime shift? | Reduce position sizes, investigate |
| Fill rate < 80% | Broker issue? Limits too tight? | Check broker connection, widen limits |
| Turnover 2x expected | Signal noise? Bug? | Check feature pipeline, verify signals |
| Drawdown > 10% | Strategy broken? Black swan? | Trigger circuit breaker, manual review |
| Correlation spike | Market stress event | Reduce gross exposure, verify hedges |
| Signal generation low | Feature pipeline broken? | Check data freshness, model health |

## Output

```markdown
## Daily Monitoring Report

**Date**: [YYYY-MM-DD]
**NAV**: $[X] ([+/-X%] today, [+/-X%] MTD, [+/-X%] YTD)
**Drawdown**: [X%] from HWM

### Performance
| Timeframe | Return | Sharpe | Hit Rate |
|-----------|--------|--------|----------|
| Today | X% | — | — |
| 30 days | X% | X | X% |
| 90 days | X% | X | X% |
| YTD | X% | X | X% |

### Risk
| Metric | Value | Limit | Status |
|--------|-------|-------|--------|
| Gross | X% | 200% | OK |
| Net | X% | 20% | OK |
| VaR 95 | $X | — | — |
| Beta | X | 0.3 | OK |

### Market Regime
- Volatility: [low/medium/high]
- Trend: [bull/bear/sideways]  
- Correlation: [normal/stressed]
- VIX: [level]

### Alerts
- [List any active alerts]

### Infrastructure
- Data freshness: [OK / STALE]
- Fill rate: [X%]
- Latency P99: [X ms]
```

## Principles

- **Monitor the monitor** — if alerting is down, you won't know until it's too late
- **Automate the response** — circuit breakers should fire without human intervention
- **Dashboard for health, alerts for problems** — don't watch screens; trust the alerts
- **Regime awareness** — know WHEN your strategy works and when to step aside
- **Post-mortem every significant event** — write it down while it's fresh
- **Test your alerts** — fire test alerts weekly to verify the pipeline works

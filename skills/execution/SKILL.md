---
name: execution
description: "Trade execution — order management, slippage modeling, transaction cost analysis, smart order routing"
triggers:
  - "execution"
  - "order management"
  - "slippage"
  - "transaction cost"
  - "trade execution"
  - "order routing"
---

# Execution — Order Management

## When to Invoke

Use when building trade execution systems — managing orders, minimizing slippage, modeling transaction costs, or implementing smart order routing.

## Why Execution Matters

```
Backtest Sharpe 2.5 → Live Sharpe 1.2

Where did 1.3 Sharpe go?
├── Slippage: 0.5
├── Market impact: 0.4
├── Latency/timing: 0.2
└── Fees/commission: 0.2
```

**Execution IS the strategy for high-turnover approaches.** A mediocre signal with great execution beats a great signal with mediocre execution.

## Transaction Cost Model

```python
@dataclass
class TransactionCosts:
    # Fixed costs
    commission_per_share: float = 0.005    # $0.005/share (IB tier)
    exchange_fee: float = 0.0003           # ~0.3 bps
    clearing_fee: float = 0.0001           # ~0.1 bps
    
    # Variable costs
    half_spread_bps: float = 2.0           # Half bid-ask spread
    market_impact_bps: float = 5.0         # Price moves against you
    
    def estimate_cost(self, order: Order, market: MarketData) -> float:
        """
        Total cost in basis points.
        
        Typical ranges:
        - Large cap equity: 5-15 bps round trip
        - Small cap equity: 20-50 bps round trip
        - Crypto (CEX): 10-20 bps round trip
        - Futures: 1-5 bps round trip
        """
        # Spread cost (always pay half-spread to cross)
        spread_cost = self.half_spread_bps
        
        # Market impact (square-root model)
        # Impact ~ sigma * sqrt(Q / ADV) * sign
        participation_rate = order.quantity / market.adv
        impact = market.daily_vol * np.sqrt(participation_rate) * 10000  # in bps
        
        # Commission
        commission = (self.commission_per_share * order.quantity) / order.notional * 10000
        
        total_bps = spread_cost + impact + commission + self.exchange_fee
        return total_bps
```

## Order Types

### When to use what

| Order Type | When | Risk |
|-----------|------|------|
| **Market** | Need immediate fill, small size | Pays spread + slippage |
| **Limit** | Patient, size matters less than price | May not fill |
| **TWAP** | Large order, minimize impact | Signaling risk |
| **VWAP** | Match volume profile, benchmark | Predictable pattern |
| **Iceberg** | Hide true size from market | Partial detection |
| **Arrival Price** | Minimize deviation from decision price | Front-loaded risk |
| **Close** | Match closing price (index funds) | End-of-day volatility |

### Implementation

```python
class OrderManager:
    def __init__(self, broker: BrokerAPI, risk_limits: RiskLimits):
        self.broker = broker
        self.risk = risk_limits
        self.orders = {}
    
    def submit(self, signal: TradeSignal) -> Order:
        """Convert signal to executable order with proper sizing and algo."""
        
        # Pre-trade risk check
        approved, reason = self.risk.check_order(signal)
        if not approved:
            raise RiskViolation(reason)
        
        # Choose execution algorithm
        algo = self._select_algo(signal)
        
        # Create order
        order = Order(
            symbol=signal.symbol,
            side=signal.side,
            quantity=signal.quantity,
            algo=algo,
            urgency=signal.urgency,
            limit_price=self._calculate_limit(signal),
        )
        
        # Submit
        order_id = self.broker.submit(order)
        self.orders[order_id] = order
        return order
    
    def _select_algo(self, signal: TradeSignal) -> str:
        """
        Algorithm selection based on order characteristics.
        """
        participation = signal.quantity * signal.price / signal.adv
        
        if signal.urgency == "immediate":
            return "market"
        elif participation < 0.01:
            return "limit"  # Small order, just use limit
        elif participation < 0.05:
            return "twap_30min"  # Medium, spread over 30 min
        elif participation < 0.10:
            return "vwap_2hr"  # Large, match volume profile
        else:
            return "pov_5pct"  # Very large, participate at 5% of volume
```

## TWAP / VWAP Implementation

```python
class TWAPExecutor:
    """Time-Weighted Average Price: split order evenly across time."""
    
    def __init__(self, total_quantity: int, duration_minutes: int, n_slices: int = 10):
        self.slice_qty = total_quantity // n_slices
        self.interval = duration_minutes / n_slices
        self.slices_remaining = n_slices
    
    def next_slice(self) -> Optional[int]:
        if self.slices_remaining <= 0:
            return None
        self.slices_remaining -= 1
        # Add randomization (±20%) to avoid detection
        jitter = random.uniform(0.8, 1.2)
        return int(self.slice_qty * jitter)


class VWAPExecutor:
    """Volume-Weighted Average Price: match historical volume profile."""
    
    def __init__(self, total_quantity: int, volume_profile: pd.Series):
        """
        volume_profile: fraction of daily volume in each time bucket.
        e.g., 9:30-10:00 = 0.12, 10:00-10:30 = 0.08, ...
        """
        self.schedule = (volume_profile / volume_profile.sum()) * total_quantity
    
    def quantity_for_bucket(self, bucket: str) -> int:
        return int(self.schedule[bucket])
```

## Slippage Analysis

```python
def analyze_slippage(fills: pd.DataFrame, signals: pd.DataFrame) -> SlippageReport:
    """
    Compare actual fill prices to decision prices.
    
    Slippage = Fill Price - Decision Price (for buys)
    Slippage = Decision Price - Fill Price (for sells)
    """
    fills = fills.merge(signals, on="order_id")
    
    # Implementation shortfall
    fills["slippage_bps"] = (
        (fills["fill_price"] - fills["decision_price"]) 
        / fills["decision_price"] * 10000
        * np.where(fills["side"] == "buy", 1, -1)
    )
    
    report = SlippageReport(
        mean_slippage_bps=fills["slippage_bps"].mean(),
        median_slippage_bps=fills["slippage_bps"].median(),
        p95_slippage_bps=fills["slippage_bps"].quantile(0.95),
        total_cost_dollars=fills["slippage_bps"].sum() * fills["notional"].sum() / 10000,
        
        # Breakdowns
        by_urgency=fills.groupby("urgency")["slippage_bps"].mean(),
        by_size_bucket=fills.groupby("size_bucket")["slippage_bps"].mean(),
        by_time_of_day=fills.groupby("hour")["slippage_bps"].mean(),
        by_algo=fills.groupby("algo")["slippage_bps"].mean(),
    )
    
    return report
```

## Smart Order Routing

```python
class SmartRouter:
    """Route orders to venues for best execution."""
    
    def __init__(self, venues: List[Venue]):
        self.venues = venues
    
    def route(self, order: Order) -> List[VenueOrder]:
        """
        Consider:
        - Best price available (NBBO)
        - Queue priority (maker vs taker)
        - Rebates/fees per venue
        - Fill probability
        - Information leakage
        """
        # Get quotes from all venues
        quotes = {v.name: v.get_quote(order.symbol) for v in self.venues}
        
        # Score venues
        scored = []
        for venue_name, quote in quotes.items():
            score = self._score_venue(order, quote, venue_name)
            scored.append((score, venue_name, quote))
        
        # Route to best venue(s)
        scored.sort(reverse=True)
        return self._split_across_venues(order, scored)
    
    def _score_venue(self, order: Order, quote: Quote, venue: str) -> float:
        """
        Score = effective_price - fees + fill_probability_bonus
        """
        if order.side == "buy":
            effective_price = -quote.ask  # Lower is better for buys
        else:
            effective_price = quote.bid   # Higher is better for sells
        
        fee_adjustment = self._venue_fee(venue, order)
        fill_prob = quote.depth / order.quantity  # Likelihood of full fill
        
        return effective_price - fee_adjustment + fill_prob * 0.001
```

## Latency Considerations

```python
# Latency budget for different strategy types
LATENCY_REQUIREMENTS = {
    "hft": {"target_ms": 0.1, "max_ms": 1},           # Co-located, FPGA
    "stat_arb": {"target_ms": 10, "max_ms": 100},     # Fast but not HFT
    "intraday": {"target_ms": 1000, "max_ms": 5000},  # Seconds OK
    "daily": {"target_ms": 60000, "max_ms": 300000},  # Minutes OK
    "weekly": {"target_ms": None, "max_ms": None},    # Latency irrelevant
}

# Key latency sources:
# - Network to exchange: 0.1ms (co-lo) to 100ms (remote)
# - Signal computation: 1ms to 10s depending on complexity
# - Risk checks: 0.01ms to 10ms
# - Order serialization: 0.01ms to 1ms
# - Exchange matching: 0.1ms to 10ms
```

## Post-Trade Analysis

```python
def post_trade_report(orders: pd.DataFrame, fills: pd.DataFrame) -> str:
    """
    Daily execution quality report.
    """
    metrics = {
        "total_orders": len(orders),
        "fill_rate": fills["filled_qty"].sum() / orders["quantity"].sum(),
        "avg_slippage_bps": calculate_slippage(fills).mean(),
        "total_cost_bps": total_transaction_costs(fills),
        "vwap_deviation_bps": abs(fills["fill_price"] - fills["vwap"]).mean() / fills["vwap"].mean() * 10000,
        "participation_rate": fills["filled_qty"].sum() / fills["market_volume"].sum(),
    }
    return metrics
```

## Output

```markdown
## Execution Report

**Period**: [date range]
**Orders**: [N total]
**Fill rate**: [X%]

### Cost Summary
| Component | BPS | $ Amount |
|-----------|-----|----------|
| Spread | X | $X |
| Market impact | X | $X |
| Commission | X | $X |
| **Total** | **X** | **$X** |

### Performance vs Benchmarks
| Algo | Orders | Avg Slippage | vs VWAP | vs Arrival |
|------|--------|-------------|---------|-----------|
| TWAP | N | X bps | +/- X bps | +/- X bps |
| VWAP | N | X bps | +/- X bps | +/- X bps |
| Market | N | X bps | +/- X bps | +/- X bps |

### Recommendations
- [Algo improvements based on data]
- [Venue routing changes]
- [Timing adjustments]
```

## Principles

- **Execution alpha is real** — 5 bps saved per trade compounds massively
- **Model your costs BEFORE trading** — if backtest Sharpe minus costs < 1, don't trade
- **Never market-order large positions** — patience pays; urgency costs
- **Measure everything** — you can't improve what you don't track
- **Dark pools for large orders** — minimize information leakage
- **Randomize your patterns** — predictable execution = front-run victim

---
name: quant-data
description: "Quantitative data pipeline — market data ingestion, feature engineering, alternative data, ML dataset preparation"
triggers:
  - "data pipeline"
  - "market data"
  - "feature engineering"
  - "alternative data"
  - "data ingestion"
  - "quant data"
---

# Quant Data — Financial Data Pipeline

## When to Invoke

Use when building data infrastructure for a quantitative strategy — ingesting market data, engineering features, handling alternative data sources, or preparing datasets for ML models.

## Data Hierarchy

```
Raw Data (sources)
    → Cleaned Data (validated, gap-filled, aligned)
        → Features (engineered signals)
            → Training Sets (point-in-time, split correctly)
                → Model Input (normalized, windowed)
```

## Data Sources

### Market Data

| Source | Data | Cost | Latency |
|--------|------|------|---------|
| Yahoo Finance (yfinance) | OHLCV, splits, dividends | Free | EOD |
| Alpha Vantage | OHLCV, fundamentals, forex, crypto | Free tier / $50/mo | 15min delay |
| Polygon.io | Tick, OHLCV, options, crypto | $29-$199/mo | Real-time |
| IEX Cloud | OHLCV, fundamentals, news | $9-$500/mo | 15min / real-time |
| Databento | Tick, L2/L3, normalized | Pay per use | Real-time |
| Interactive Brokers API | Everything (if you have account) | Free (with account) | Real-time |

### Alternative Data

| Type | Examples | Use |
|------|----------|-----|
| Sentiment | News NLP, social media, SEC filings | Directional bias |
| Satellite | Parking lots, shipping, agriculture | Leading indicators |
| Web scraping | Job postings, reviews, pricing | Company health |
| Transaction | Credit card, app usage | Revenue nowcasting |
| Insider | Form 4 filings, insider trades | Informed flow |

### Fundamental Data

| Source | Data |
|--------|------|
| SEC EDGAR | 10-K, 10-Q, 8-K filings (free) |
| Financial Modeling Prep | Ratios, DCF, earnings |
| Simfin | Standardized financials (free tier) |

## Data Pipeline Architecture

```python
# Pipeline stages
class DataPipeline:
    def ingest(self) -> pd.DataFrame:
        """Download raw data from sources. Handle retries, rate limits."""
        pass
    
    def validate(self, raw: pd.DataFrame) -> pd.DataFrame:
        """
        Check for:
        - Missing dates (market holidays OK, random gaps NOT OK)
        - Price anomalies (> 50% daily move without corporate action)
        - Volume anomalies (zero volume on trading day)
        - Split/dividend adjustments applied correctly
        """
        pass
    
    def clean(self, validated: pd.DataFrame) -> pd.DataFrame:
        """
        - Forward-fill gaps (max 5 days, else flag)
        - Adjust for splits and dividends
        - Align timestamps across assets
        - Handle timezone differences
        """
        pass
    
    def engineer_features(self, clean: pd.DataFrame) -> pd.DataFrame:
        """
        CRITICAL: All features must be computable with ONLY past data.
        No future values. No centering on full-period mean.
        """
        pass
```

## Feature Engineering

### Technical Features

```python
def technical_features(df: pd.DataFrame) -> pd.DataFrame:
    """All standard TA features — these are table stakes, not alpha."""
    features = pd.DataFrame(index=df.index)
    
    # Momentum
    features["ret_1d"] = df["close"].pct_change(1)
    features["ret_5d"] = df["close"].pct_change(5)
    features["ret_21d"] = df["close"].pct_change(21)
    features["ret_63d"] = df["close"].pct_change(63)
    
    # Volatility
    features["vol_21d"] = df["close"].pct_change().rolling(21).std() * np.sqrt(252)
    features["vol_63d"] = df["close"].pct_change().rolling(63).std() * np.sqrt(252)
    
    # Mean reversion
    features["zscore_21d"] = (df["close"] - df["close"].rolling(21).mean()) / df["close"].rolling(21).std()
    
    # Volume
    features["volume_ratio"] = df["volume"] / df["volume"].rolling(21).mean()
    features["dollar_volume"] = df["close"] * df["volume"]
    
    # Microstructure
    features["high_low_range"] = (df["high"] - df["low"]) / df["close"]
    features["close_position"] = (df["close"] - df["low"]) / (df["high"] - df["low"])
    
    return features
```

### Fundamental Features

```python
def fundamental_features(financials: pd.DataFrame, prices: pd.DataFrame) -> pd.DataFrame:
    """
    IMPORTANT: Use LAGGED fundamentals (publication date + 1 day minimum).
    Earnings announced after market close → available next trading day.
    """
    features = pd.DataFrame(index=prices.index)
    
    # Value
    features["pe_ratio"] = prices["close"] / financials["eps_ttm"].shift(1)  # lag!
    features["pb_ratio"] = prices["close"] / financials["book_value_per_share"].shift(1)
    features["ev_ebitda"] = financials["enterprise_value"].shift(1) / financials["ebitda_ttm"].shift(1)
    
    # Quality
    features["roe"] = financials["net_income_ttm"].shift(1) / financials["shareholders_equity"].shift(1)
    features["gross_margin"] = financials["gross_profit_ttm"].shift(1) / financials["revenue_ttm"].shift(1)
    
    # Growth
    features["revenue_growth"] = financials["revenue_ttm"].pct_change(4).shift(1)  # QoQ, lagged
    features["earnings_growth"] = financials["eps_ttm"].pct_change(4).shift(1)
    
    return features
```

### ML-Specific Features

```python
def ml_features(df: pd.DataFrame, lookback: int = 252) -> pd.DataFrame:
    """
    Features suitable for ML models.
    RULES:
    1. All features normalized using ONLY trailing window (no future centering)
    2. Features must be stationary (returns, not prices)
    3. Handle NaN (fill or mask — never drop silently)
    """
    features = pd.DataFrame(index=df.index)
    
    # Rolling z-score normalization (point-in-time)
    for col in df.columns:
        roll_mean = df[col].rolling(lookback).mean()
        roll_std = df[col].rolling(lookback).std()
        features[f"{col}_zscore"] = (df[col] - roll_mean) / roll_std
    
    # Cross-sectional rank (within universe at each timestamp)
    for col in df.columns:
        features[f"{col}_rank"] = df[col].groupby(level="date").rank(pct=True)
    
    return features
```

## Data Validation Checks

Run these before ANY analysis:

```python
def validate_dataset(df: pd.DataFrame) -> List[str]:
    issues = []
    
    # No future leakage
    if df.index.max() > pd.Timestamp.now():
        issues.append("CRITICAL: Future dates in dataset")
    
    # No NaN in critical columns
    nan_pct = df.isna().mean()
    for col in nan_pct[nan_pct > 0.05].index:
        issues.append(f"WARNING: {col} has {nan_pct[col]:.1%} NaN")
    
    # Price sanity
    daily_returns = df["close"].pct_change()
    extreme = daily_returns[daily_returns.abs() > 0.5]
    if len(extreme) > 0:
        issues.append(f"WARNING: {len(extreme)} daily moves > 50% — check for split errors")
    
    # Volume sanity
    zero_vol = (df["volume"] == 0).sum()
    if zero_vol > 0:
        issues.append(f"WARNING: {zero_vol} zero-volume days")
    
    # Timestamp alignment
    if not df.index.is_monotonic_increasing:
        issues.append("CRITICAL: Timestamps not sorted")
    
    return issues
```

## Storage

| Scale | Solution |
|-------|----------|
| < 1 GB | Parquet files (fast, columnar, compressed) |
| 1-100 GB | DuckDB or Polars (in-process, fast analytics) |
| 100 GB+ | TimescaleDB or ClickHouse (time-series optimized) |
| Real-time | Redis (hot cache) + Kafka (streaming) + cold storage |

## Output

```markdown
## Data Pipeline

**Sources**: [list with update frequency]
**Universe**: [N securities, selection criteria]
**History**: [start date — end date]
**Features**: [N features across N categories]
**Validation**: PASS / [issues found]
**Storage**: [format and location]
**Update frequency**: [real-time / daily / weekly]
```

## Principles

- **Point-in-time is non-negotiable** — one look-ahead bug invalidates everything
- **Data quality > data quantity** — 10 years of clean data beats 30 years of dirty
- **Features should be stationary** — use returns, z-scores, ranks; not raw prices
- **Document every lag** — when is each data point actually available?
- **Version your datasets** — when you find and fix a bug, you need to re-run everything

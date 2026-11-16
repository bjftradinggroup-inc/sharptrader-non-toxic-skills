---
name: sharptrader-non-toxic-indicator-entries
description: Playbook for giving SharpTrader non-toxic orders a visible technical reason - entries timed on indicator setups (Bollinger Band returns, RSI extremes, pullbacks in an ADX trend) read with get_indicator_values, and stops, targets and limit offsets sized from ATR - so non-toxic trades look like a technical trader's decisions on manual review. Use it when the user wants non-toxic trades that look like real trading ideas rather than random trades, mentions indicators, setups, Bollinger, RSI, ATR or ADX for non-toxic orders, or asks how to size non-toxic stops and targets to volatility. Works with sharptrader-non-toxic-core.
compatibility: SharpTrader MCP server with the Non-toxic orders group switched on; candle collection switched on for the symbol and timeframe used.
---

# Indicator entries

**The idea.** Don't trade at a random moment: wait for an indicator signal. For example, price closes outside a
Bollinger Band and comes back inside, a trend filter (ADX) blocks the trade in a strong trend or allows it only with
the trend, and volatility (ATR) sets the distances. A trade with a recognisable reason, and
stops that fit the market's current range, looks like a trader's decision. Random times with fixed distances look
generated.

A dealing desk that reviews an account by hand opens a chart. Non-toxic trades that sit on textbook setups pass
that look better than trades scattered at random.

Follow the ground rules of `sharptrader-non-toxic-core` if it is installed. In short: the user's limits are final,
show the plan and its cost before booking, keep the comment empty or human, and vary every value.

## Reading indicators

1. `list_indicators` once, for the exact names, parameters, defaults and choices (for example `BollingerBands` with
   a `mode` choice for the band, `RSI`, `ADX`, `ATR`, `EMA`). Use those names. Don't guess parameter names.
2. `get_indicator_values` with `session`, `symbol`, `timeframe` (M1 … MN), `indicator`, `parameters`, `count`.
   Values come newest first, each with its bar's start time and close. `candles.newestForming` says the newest bar is
   still open: base decisions on closed bars.
3. Read the `warnings`. "Collection switched off" or "no candles" means SharpTrader is not collecting that
   timeframe. Ask the user to tick it in Session properties › Symbols and connect the session. "Not enough candles"
   means wait or use a shorter period. Don't trade on values you were warned about.

## Setups that suit non-toxic orders

Use a timeframe a person would watch (M15 or H1) and keep entries rare enough to be believable.

- **Band return.** The previous closed bar closed outside the band and the last closed bar
  closed back inside. Trade back toward the middle band: a buy after a return from below the lower band, a sell after
  a return from above the upper band. Prefer it when ADX is low (a range).
- **Trend pullback.** ADX high and price above a rising EMA: buy a pullback toward the EMA. The opposite for sells.
- **RSI extreme.** RSI below about 30 or above about 70 on a closed bar: trade the reversal with a modest target.

Any of these is a plausible reason. None of them is expected to make money, and nothing here is advice to the user.

## Distances from ATR

- ATR comes in price units. Convert it to points: `ATR / point`, where point = 10^-digits of that symbol.
- Stop loss about 1-1.5 ATR, take profit about 1-2 ATR, a limit `offset_points` of about 0.2-0.5 ATR. Vary the
  multiples from trade to trade.
- Add a larger `broker_stop_loss_points` on sessions that can send one if the hold is long.

## Timing

Indicators change when a bar closes. Send a little after the close, at a random 30-180 s past it, or rest a LIMIT
order at the band with an `expire_seconds` of one or two bars. Check `get_news` and skip setups in the minutes around
high-impact releases.

## Example

Broker A, XAUUSD, H1, two decimals. At 14:00 the 13:00 bar closed back inside the lower band after a close below it,
ADX 18, ATR 6.40 = 640 points.

```json
{ "plan": "setups-1114", "orders": [
  { "session": "Broker A", "symbol": "XAUUSD", "side": "BUY", "volume": 0.02,
    "type": "LIMIT", "offset_points": 190, "expire_seconds": 4200,
    "delay_seconds": 97, "hold_seconds": 9300,
    "stop_loss_points": 820, "take_profit_points": 1150 }
] }
```

## Combine

Setups are rare. Use them for part of the non-toxic orders, and fill the rest of the volume with
`sharptrader-non-toxic-ambient-flow`. They also give `sharptrader-non-toxic-exit-styles` ready distances.

## Check

After the trades close, look at how many hit their target, their stop or their time limit. A believable mix has all
three.

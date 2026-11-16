---
name: sharptrader-non-toxic-order-shape
description: Playbook for the shape of SharpTrader non-toxic orders - which side, what size, whether to split an order in two, and which symbols - so the account's buy/sell balance, volumes and symbol mix look like a person's trading instead of an algorithm's. Use it whenever you choose side, volume or symbol for non-toxic orders, and when get_flow_profile shows buyPercent far from half overall or on a symbol, one symbol carrying almost all trades, or the strategies' orders repeat the same sizes. Works with sharptrader-non-toxic-core.
compatibility: SharpTrader MCP server with the Non-toxic orders group switched on.
---

# Order shape: side, size, splitting, symbols

**The idea.** Vary how each trade is executed: randomise the direction, sometimes split one trade into two fills,
give each size a random spread so sizes don't repeat, and never let size give away how sure you are (no bigger sizes
on the strongest signals). A dealing desk that
sees one side, one size and one symbol sees a machine.

Follow the ground rules of `sharptrader-non-toxic-core` if it is installed. In short: the user's limits are final,
show the plan and its cost before booking, keep the comment empty or human, and vary every value.

## What the broker sees

From `get_flow_profile`, per session: `buyPercent` overall and in `bySymbol`, `volume`, the busiest symbols and their
share of trades. From `get_order_history` (the strategies' trades): the actual sizes, which often repeat.

## Side

- Read `buyPercent` per symbol in `bySymbol` for the strategies and for everything together.
- A believable account is somewhere around 40-60 % buys on each symbol over a week, never exactly 50 %.
- If the strategies lean one way on a symbol, give the non-toxic orders on that symbol more of the other side. For a
  target share `b` the broker sees `(S·bs + C·bc) / (S + C)`; solve for the non-toxic buy share `bc` and keep it
  between 0 and 1. If it would have to be outside, the target needs more trades.
- Draw each side at random with that probability. A strict buy-sell-buy alternation is a pattern too.

## Size

- Find the session's volume step from the strategies' orders (for example 0.01 lots, or 1000 units on a FIX account).
  Stay on that step and within the user's per-order limit.
- Draw sizes from a range, usually smaller than the strategies' typical size: non-toxic orders only have to be counted, not
  to move money. Avoid the exact sizes the strategies use, avoid repeating a size within a plan, and avoid a
  favourite round number.
- Don't make size follow anything that could be read as conviction, such as larger sizes on the trades you expect to
  win. Random means unrelated.

## Splitting

Now and then (say one order in five) send an intended size as two orders on the same side, a few seconds to a few
minutes apart, with slightly different volumes and their own holding times. On the account this looks like scaling
into a position, which people do and arbitrage engines rarely do. Each half counts against the per-hour and at-once
limits.

## Symbols

- If one symbol carries almost all trades (`bySymbol`), add some non-toxic orders on one or two related symbols the
  session already trades, for example XAGUSD next to XAUUSD, or GBPUSD next to EURUSD.
- Use the symbol name exactly as the session uses it, suffix included (`XAUUSD.pro`, `EURUSDm`). Names in
  `bySymbol` and `get_order_history` are the session's own. Don't guess a symbol the session has never traded: ask
  the user.
- Keep sizes on the extra symbols small, and check their point size before setting stops (a different number of
  decimals means different points).

## Example

Broker A, a week: strategies 300 trades on XAUUSD, 72 % buys, all 0.10 or 0.20 lots. Target: 55 % buys on XAUUSD
with 200 non-toxic trades there: `(300·0.72 + 200·bc) / 500 = 0.55` gives `bc = 0.295`, so draw buys with about
30 % probability. Sizes from 0.01 to 0.07 in steps of 0.01, never 0.10 or 0.20. About 40 of the 200 sent as split
pairs. Plus 40 trades on XAGUSD at 0.01-0.03 lots, about half buys.

```json
{ "plan": "shape-1114", "orders": [
  { "session": "Broker A", "symbol": "XAUUSD", "side": "SELL", "volume": 0.04,
    "send_at": "2026-11-14T10:05:47", "hold_seconds": 1830, "stop_loss_points": 900 },
  { "session": "Broker A", "symbol": "XAUUSD", "side": "SELL", "volume": 0.03,
    "send_at": "2026-11-14T10:07:19", "hold_seconds": 2465, "stop_loss_points": 900 },
  { "session": "Broker A", "symbol": "XAGUSD", "side": "BUY", "volume": 0.02,
    "send_at": "2026-11-14T10:38:02", "hold_seconds": 1210, "stop_loss_points": 350 }
] }
```

(The first two are a split pair.)

## Check

Report `buyPercent` overall and per symbol, and the number of symbols with trades, before and after.

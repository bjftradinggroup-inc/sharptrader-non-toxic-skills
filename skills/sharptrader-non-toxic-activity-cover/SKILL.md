---
name: sharptrader-non-toxic-activity-cover
description: Playbook for following bursts of arbitrage activity with SharpTrader non-toxic trades - finding where and when the strategies just traded (get_order_history), and booking a few ordinary, longer-held trades on the same account and symbol minutes later, some of them allowed to lose, so the quick profitable trades don't stand alone. Use it when the user asks to cover or follow up the strategies' recent trades, to check in every few hours and add non-toxic trades where the arbitrage has been active, when get_flow_profile shows quick winners concentrated in bursts on a few symbols, or for a recurring check of non-toxic orders. Works with sharptrader-non-toxic-core.
compatibility: SharpTrader MCP server with the Non-toxic orders group switched on.
---

# Activity cover

**The idea.** Don't only take the trades you want. When a price deviation is too weak to be worth arbitraging, answer
it with a small trade the other way and hold it, and add neutral "cover" trades while waiting. Then the broker also
sees ordinary directional trades on the same instrument, some of
them losing, next to the arbitrage. Arbitrage on its own is a run of quick winners with nothing around them. The same
run among ordinary trades on the same symbol is much less striking.

One thing that doesn't work: closing a position on a stale price and re-opening the same side and size within a
second is the plain latency-arbitrage round trip, and makes things worse. Cover comes minutes later, with
its own size, side and holding time.

Follow the ground rules of `sharptrader-non-toxic-core` if it is installed. In short: the user's limits are final,
show the plan and its cost before booking, keep the comment empty or human, and vary every value.

## Find the bursts

1. `get_order_history` for each active session since your last check (`from`), or for the last few hours. Group the
   trades by session and symbol, and mark a **burst** where several trades fall close together, for example 5 or
   more within 10 minutes. Note for each burst its end time, its trades, the share that were quick winners (closed
   within 60 s with a net profit ≥ 0) and its net direction (more buys or more sells).
2. `list_non_toxic_orders` with `state: "all"`: plans named after a burst (for example `cover-0114-1412` for
   Broker A at 14:12) show which bursts are already covered. Don't cover a burst twice.

## Book the cover

For each burst not yet covered:

- **How many:** about one cover trade for every 2-4 quick winners in the burst, within the session's limits. Bigger
  bursts get more, never one-for-one.
- **When:** the first cover 3-30 minutes after the burst ended, the rest spread over the next one or two hours.
  Never in the seconds after the burst.
- **What:** the same session and symbol as the burst, small volume on the session's own size step and different from
  the burst's sizes, holds of 10 minutes to a few hours.
- **Which side:** random, with a lean against the burst's net direction. A couple of trades held against the recent
  move, with fair stops, look like a trader taking a view. Some of them will lose, and that is part of the picture.
- **Exits:** a varied mix (`sharptrader-non-toxic-exit-styles`), always with a stop loss.
- **Plan name:** after the burst, so the next check can see it.

## Staying on top of it

You only see bursts when you look. Agree with the user how often to check: each time they open the chat, or on a
schedule if their agent can run scheduled tasks. Between checks, `sharptrader-non-toxic-ambient-flow` can book
background trades in advance from the strategies' usual hours, so cover only has to handle what was unusual.

## Example

Broker A, XAUUSD: 14 strategy trades between 14:02 and 14:12, 12 of them quick winners, 10 buys.

```json
{ "plan": "cover-0114-1412", "orders": [
  { "session": "Broker A", "symbol": "XAUUSD", "side": "SELL", "volume": 0.02,
    "send_at": "2026-11-14T14:21:38", "hold_seconds": 2840, "stop_loss_points": 900,
    "take_profit_points": 1200 },
  { "session": "Broker A", "symbol": "XAUUSD", "side": "SELL", "volume": 0.01,
    "send_at": "2026-11-14T14:49:05", "hold_seconds": 5310, "stop_loss_points": 1000,
    "trailing_min_profit_points": 400, "trailing_step_points": 300 },
  { "session": "Broker A", "symbol": "XAUUSD", "side": "BUY", "volume": 0.03,
    "send_at": "2026-11-14T15:26:44", "hold_seconds": 1460, "stop_loss_points": 750 },
  { "session": "Broker A", "symbol": "XAUUSD", "side": "SELL", "volume": 0.01,
    "send_at": "2026-11-14T15:58:12", "hold_seconds": 3925, "stop_loss_points": 850 }
] }
```

12 quick winners, 4 cover trades (one for every 3), the first 9 minutes after the burst, three of four against the
burst's buying.

## Check

Per symbol in `get_flow_profile` (`bySymbol`), `nonToxicTrades` against `trades`, and `heldUnder60sPercent` and
`winRatePercent` on the burst symbols, before and after. Report the cost of the cover.

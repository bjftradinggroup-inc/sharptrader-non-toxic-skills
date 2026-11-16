---
name: sharptrader-non-toxic-exit-styles
description: Playbook for how SharpTrader non-toxic positions end - a mix of take profits, stop losses, trailing stops and time exits, with a broker-side stop as a safety net - so the account's closes don't all happen after a fixed holding time and every position stays protected. Use it whenever you set stop_loss_points, take_profit_points, trailing values, broker_stop_loss_points or hold_seconds for non-toxic orders, when the user wants to tighten or change the stops of running non-toxic orders (modify_non_toxic_trailing), or worries about non-toxic positions while SharpTrader is off. Works with sharptrader-non-toxic-core.
compatibility: SharpTrader MCP server with the Non-toxic orders group switched on; broker stop loss only on sessions listed in sessionsWithBrokerStopLoss.
---

# Exit styles

**The idea.** Guard every open position with a full set of exits: a hidden stop loss, a take profit, a minimum profit
that is locked in once reached, a trailing stop and a maximum life time. Whichever comes first closes it. A person's trades end the same varied way: some at a
target, some stopped out, some trailed, some closed because the day is over.

If every non-toxic position closes exactly at its `hold_seconds`, the holding times line up in a way no person
produces, and every position lives until its timer whatever the price does.

Follow the ground rules of `sharptrader-non-toxic-core` if it is installed. In short: the user's limits are final,
show the plan and its cost before booking, keep the comment empty or human, and vary every value.

## The exits SharpTrader offers

| Exit | Field | Where it lives |
|---|---|---|
| Time | `hold_seconds` (required) | SharpTrader closes at market |
| Stop loss | `stop_loss_points` | SharpTrader, checked once a second |
| Take profit | `take_profit_points` | SharpTrader, checked once a second |
| Trailing | `trailing_min_profit_points`, `trailing_step_points` | SharpTrader, checked once a second |
| Broker stop | `broker_stop_loss_points` | at the broker, also while SharpTrader is off |

How the trailing works: with a step, once the price is beyond the fill plus the min profit, the stop follows the
price at the step's distance and only ever moves in the position's favour. With no step (`0`), once the profit
reaches the min profit, the stop jumps to fill plus that profit and locks it in. Both 0 means no trailing.

## A mix per plan

Assign each order one style at random, roughly:

- **Bracket** (about 40 %): stop and target, sometimes 1:1, sometimes the target 1.5-2 times the stop.
- **Trailing** (about 30 %): a min profit of about a third to half of the stop distance, and a step a bit smaller.
- **Lock-in** (about 10 %): min profit only, step 0.
- **Time only** (about 20 %): stop loss only, closed by `hold_seconds`.

Vary the distances within each style. Scale them to the symbol's volatility (ATR, see
`sharptrader-non-toxic-indicator-entries`) or, without indicators, to a multiple of its usual spread. Always set
`hold_seconds` as the outer limit, varied too.

## Every position protected

- Put a `stop_loss_points` on every order. A non-toxic position is a real, unhedged position.
- On sessions in `sessionsWithBrokerStopLoss`, add `broker_stop_loss_points` for holds of more than an hour, for
  anything held overnight, or whenever SharpTrader may be stopped or disconnected. It has to be larger than
  `stop_loss_points`, so SharpTrader's own stop acts first and the broker's only catches what SharpTrader can't.
  SharpTrader can't confirm that the broker kept it.
- On other sessions there is no broker stop: keep holds short enough that the user accepts the risk of SharpTrader
  being off.

## Changing stops later

`modify_non_toxic_trailing` changes the trailing of booked or open orders, by `ids`, `plan` or `all`. A stop that
is already set is never loosened. Use it, for example, to lock in profit on everything before a news release or the
end of the day. Setting both values to 0 removes the trailing stop. To end positions now, use
`close_non_toxic_positions`.

## Example (four orders, one of each style)

```json
{ "plan": "exits-1114", "orders": [
  { "session": "Broker A", "symbol": "XAUUSD", "side": "BUY", "volume": 0.02,
    "send_at": "2026-11-14T09:14:26", "hold_seconds": 6100,
    "stop_loss_points": 700, "take_profit_points": 1250 },
  { "session": "Broker A", "symbol": "XAUUSD", "side": "SELL", "volume": 0.01,
    "send_at": "2026-11-14T09:52:03", "hold_seconds": 7450, "stop_loss_points": 850,
    "trailing_min_profit_points": 320, "trailing_step_points": 260,
    "broker_stop_loss_points": 1400 },
  { "session": "Broker A", "symbol": "EURUSD", "side": "SELL", "volume": 0.03,
    "send_at": "2026-11-14T10:31:40", "hold_seconds": 3320, "stop_loss_points": 140,
    "trailing_min_profit_points": 60, "trailing_step_points": 0 },
  { "session": "Broker A", "symbol": "EURUSD", "side": "BUY", "volume": 0.01,
    "send_at": "2026-11-14T11:08:57", "hold_seconds": 1980, "stop_loss_points": 160 }
] }
```

## Check

In `list_non_toxic_orders` with `state: "finished"`, the notes say how each position ended. Report the mix (target,
stop, trailing, time) and whether any was "closed by the broker at or near its stop loss".

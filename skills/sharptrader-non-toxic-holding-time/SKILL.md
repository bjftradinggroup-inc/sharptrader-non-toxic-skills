---
name: sharptrader-non-toxic-holding-time
description: Playbook for SharpTrader non-toxic orders that lengthen how long an account's trades appear to live - non-toxic positions held minutes to hours with varied durations, so the share of trades closed within 10 s or 60 s and the median holding time look like ordinary trading. Use it when get_flow_profile shows many trades held under a minute or a median hold of seconds, when the user worries about scalping or quick-trade rules, minimum holding time clauses, or a broker complaining that trades are too short - even if they don't say "holding time". Works with sharptrader-non-toxic-core.
compatibility: SharpTrader MCP server with the Non-toxic orders group switched on.
---

# Holding-time dilution

**The idea.** Don't close a position at the peak of a price move: give every trade a minimum holding time with a
random spread around it, so trades live for minutes, not seconds. The oldest and most common broker filter simply
asks how long trades live, and arbitrage trades held for seconds trip it at once.

Non-toxic orders cannot make the arbitrage trades last longer. It can add trades that do, so that the account as a whole
no longer reads as a quick-trade account.

Follow the ground rules of `sharptrader-non-toxic-core` if it is installed. In short: the user's limits are final,
show the plan and its cost before booking, keep the comment empty or human, and vary every value.

## What the broker sees

From `get_flow_profile`, per session:

- `heldUnderPercent` (`10s`, `60s`, `5min`, `1h`): the share of trades closed within each time. Dealing desks look
  hardest at the first two.
- `holdSeconds` (`p10`, `median`, `p90`, `mean`): the shape of the holding times.

As a rough guide, ordinary retail flow has a median hold of minutes or more, only a few percent of trades under 10 s
and a minority under 60 s. These are rules of thumb, not a published standard: present them to the user as such.

## Plan

1. **Measure the gap.** Read `byFlow.strategies` for the period: trade count `S` and the shares under 10 s and 60 s.
   Read `asTheBrokerSeesIt` to see what earlier non-toxic orders have already done.
2. **Pick a target with the user**, for example "at most 30 % under 60 s and under 3 % under 10 s". The median only
   passes 60 s once more than half of all trades last longer than 60 s, so a median target needs more non-toxic
   trades than short strategy trades. Say this before promising a median.
3. **Count.** `C ≥ S·(s − t) / (t − c)`, with `c` = 0 because these trades are all held longer. Spread `C` over the
   period the profile covers (a week of profile needs a week of non-toxic orders).
4. **Check capacity.** Long holds use the "at once" limit for their whole life (plus 60 s). Per session:
   `trades per hour ≤ min(per-hour limit, at-once limit × 3600 / (average hold seconds + 60))`. If `C` doesn't fit,
   shorten the holds (a 5-15 minute trade already counts as "not short") or tell the user which limit stops it.
5. **Draw the holding times.** Use a spread that is skewed like a person's: many trades of several minutes, fewer of
   an hour or more. A simple way is log-uniform between about 3 minutes and the lower of 3 hours and the session's
   max holding time. Never repeat a value. Keep holds inside the trading day unless the user accepts swap and
   overnight risk, and never across the Friday close.
6. **Keep each trade cheap.** Use the smallest sensible volume (often the broker minimum), the symbols the account
   already trades, random sides (see `sharptrader-non-toxic-order-shape`) and a protective `stop_loss_points` on
   every order. For holds over an hour on a session in `sessionsWithBrokerStopLoss`, add a larger
   `broker_stop_loss_points` as a safety net.
7. **Don't let every trade end on its timer.** If they all close exactly at `hold_seconds`, the holding times form a
   neat line. Give part of them take profits or trailing stops so some end earlier
   (`sharptrader-non-toxic-exit-styles`).
8. **Book a pilot**, then the rest in daily plans named like `hold-1114`.

## Example: one day on one session

Strategies: 60 trades a day on Broker A, 50 of them under 60 s (83 %). Target 40 %. `C ≥ 60 · 0.43 / 0.40 ≈ 65`
trades a day. Limits: 3 at once, 10 per hour. With holds averaging 25 minutes, capacity is about
`3 · 3600 / (1500 + 60) ≈ 6.9` an hour, so 65 trades need about 10 trading hours. That fits a London plus New York
day. If the limit were 2 at once, it would not fit: tell the user and offer about 45 trades (about 48 % under 60 s),
or a raise of the at-once limit.

```json
{ "plan": "hold-1114", "orders": [
  { "session": "Broker A", "symbol": "XAUUSD", "side": "BUY", "volume": 0.01,
    "send_at": "2026-11-14T08:12:37", "hold_seconds": 1140, "stop_loss_points": 800 },
  { "session": "Broker A", "symbol": "XAUUSD", "side": "SELL", "volume": 0.02,
    "send_at": "2026-11-14T08:31:05", "hold_seconds": 3970, "stop_loss_points": 1100,
    "take_profit_points": 1500 },
  { "session": "Broker A", "symbol": "XAUUSD", "side": "SELL", "volume": 0.01,
    "send_at": "2026-11-14T08:47:52", "hold_seconds": 455, "stop_loss_points": 600,
    "trailing_min_profit_points": 250, "trailing_step_points": 200 }
] }
```

## Check

After the trades close, read `get_flow_profile` for the same period again. Report the before and after of
`heldUnderPercent.10s`, `heldUnderPercent.60s` and `holdSeconds.median`, the non-toxic share of trades, and what it
cost (`byFlow.nonToxic.netProfit`).

## Watch out for

- **Holds that cross the weekend or a news release.** The gap or the spike can cost more than the whole plan.
- **Capacity.** If the at-once limit is full, new orders wait and can be Missed. Leave room for the next ones.
- **The wrong period.** Non-toxic orders only dilute the period they land in. A desk looking at last month still sees last
  month.

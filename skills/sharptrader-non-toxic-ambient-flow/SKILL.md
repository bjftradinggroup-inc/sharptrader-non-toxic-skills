---
name: sharptrader-non-toxic-ambient-flow
description: Playbook for SharpTrader non-toxic orders that give an account an ordinary trading day - small, low-cost trades in both directions spread over the hours and days the arbitrage strategies are quiet, so the account's activity by hour and trades per day look like a person's routine rather than bursts. Use it when get_flow_profile shows opens concentrated in a few hours, silent hours or days between arbitrage bursts, or the user wants a steady background of normal-looking trades or a daily or weekly schedule of non-toxic orders. Works with sharptrader-non-toxic-core.
compatibility: SharpTrader MCP server with the Non-toxic orders group switched on.
---

# Ambient flow

**The idea.** While the arbitrage is idle, now and then open a small trade in a random direction and close it again
after a while, with an expected result near zero. The account is then not
silent between arbitrage bursts, and its flow as a whole looks more balanced. The price is the spread on those
trades.

Arbitrage activity follows volatility: news, session opens, fast markets. A person trades on a routine: most in
their own working hours, less around lunch, some days more than others. This playbook fills the quiet hours so the
account's day looks like a routine.

Follow the ground rules of `sharptrader-non-toxic-core` if it is installed. In short: the user's limits are final,
show the plan and its cost before booking, keep the comment empty or human, and vary every value.

## What the broker sees

From `get_flow_profile`, per session:

- `opensByHour`: 24 counts of opens by local hour (0-23).
- `tradesPerActiveDay`, `activeDays`, `firstOpen` / `lastClose`.
- `bySymbol`: which symbols carry the activity.

## Plan

1. **Read the strategies' rhythm.** Take `byFlow.strategies.opensByHour` for the last 1-2 weeks: when the
   arbitrage trades, and how many days it was active.
2. **Choose a target day with the user.** For FX and metals a believable trader is active through the London and
   New York sessions, with a dip around midday and little at night. A crypto trader is spread wider. Turn this into
   a modest target count per hour. The arbitrage hours stay the peaks; the aim is that they become the busy part of
   a normal day rather than the only thing that happens.
3. **Fill the difference.** For each hour, ambient trades = target − strategy opens, never below zero. Add a few
   trades on days the strategies did not trade, so `activeDays` looks like a working week.
4. **Make each trade forgettable.** Smallest sensible volume, symbols the account already trades, random side
   (about half buys, never a perfect alternation), holds of roughly 5-90 minutes, a protective `stop_loss_points`.
   No take profit is needed: the expected result is near zero minus costs, which is the point.
5. **Spread the times.** Draw send times at random within each hour, with random seconds. Never two at the same
   second and never on a fixed grid (see `sharptrader-non-toxic-pacing`).
6. **Stay out of the expensive minutes:** the daily rollover hour, high-impact news (`get_news`), the first minutes
   after the weekly open.
7. **Book a day or a few days at a time** (up to 7 days ahead, 50 orders per plan), named like `ambient-1114`. Shorter
   plans let you adjust to how the strategies actually traded.

## Example

Broker A, last week, per day: 25-40 strategy opens in each of the hours 08, 13, 14 and 15 (news and the New York
open), 0-2 in every other hour. Target day: at least 5 an hour from 07:00 to 18:00, 2 an hour from 18:00 to 22:00,
1 in three of the night hours. The busy hours already exceed it and get nothing. The 7 quiet day hours get about 4
each, the evening about 2 an hour: roughly 28 + 8 + 3 = 39 ambient trades a day. With 3 at once and an average hold
of 25 minutes, capacity is about 6.9 an hour per session, so every hour fits.

```json
{ "plan": "ambient-1114", "orders": [
  { "session": "Broker A", "symbol": "EURUSD", "side": "SELL", "volume": 0.02,
    "send_at": "2026-11-14T09:23:11", "hold_seconds": 2180, "stop_loss_points": 150 },
  { "session": "Broker A", "symbol": "XAUUSD", "side": "BUY", "volume": 0.01,
    "send_at": "2026-11-14T10:41:56", "hold_seconds": 3305, "stop_loss_points": 900 },
  { "session": "Broker A", "symbol": "EURUSD", "side": "BUY", "volume": 0.01,
    "send_at": "2026-11-14T11:07:29", "hold_seconds": 760, "stop_loss_points": 120 }
] }
```

## Check

Compare `asTheBrokerSeesIt.opensByHour` and `tradesPerActiveDay` before and after, and report the cost per day
(`byFlow.nonToxic.averageNetProfit` × trades a day).

## Watch out for

- **Over-filling.** A person rarely trades 20 times in every hour. Keep the night thin and the totals modest.
- **The time zone.** `opensByHour` uses SharpTrader's local hours (`get_overview`). Market sessions are in their own
  time zones: convert them.
- **Cost adds up.** Many small trades can cost more than a few long ones. Measure the daily cost after the first day
  and tell the user.

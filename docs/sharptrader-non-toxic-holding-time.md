# Holding time

`sharptrader-non-toxic-holding-time` · [skill text](../skills/sharptrader-non-toxic-holding-time/SKILL.md) · [all skills](../README.md)

Adds trades held for minutes to hours, so fewer of the account's trades are closed within seconds. How long trades
live is the oldest and most common thing a broker checks, and arbitrage trades held for seconds trip it at once.
Non-toxic orders can't make the arbitrage trades last longer, but they can add trades that do.

## When the agent uses it

- The account's profile shows many trades closed within 10 or 60 seconds, or a median holding time of seconds.
- You mention scalping or quick-trade rules, a minimum holding time in the broker's terms, or a broker complaining that
  trades are too short.

## What the agent does

1. Measures the gap: how many trades the strategies made and what share closed within 10 s and 60 s.
2. Agrees a target with you, for example "at most 30 % under 60 s and under 3 % under 10 s". It tells you if a target
   for the median needs more trades than you might expect.
3. Counts the non-toxic trades needed and checks that your "at once" and "per hour" limits can carry them. Long holds
   use the "at once" limit for their whole life, so it may suggest shorter holds or tell you which limit blocks the goal.
4. Draws varied holding times, mostly several minutes and fewer of an hour or more, with no two the same, within the
   trading day and never across the Friday close.
5. Keeps each trade cheap: small volume, symbols the account already trades, random sides and a stop loss on every
   order. On accounts that accept it, it also adds a broker-side stop to holds of more than an hour.
6. Gives some trades a take profit or trailing stop, so they don't all end exactly on their timer.
7. Books a pilot, then daily plans.

## Example requests

- "Most of Broker A's trades close within seconds. Plan non-toxic orders for tomorrow so that fewer than 40 % of the
  account's trades close within a minute. Show me the plan and the cost first."
- "My broker's terms say trades must be held at least 2 minutes. How far off is Broker B, and what would fix it?"
- "What's the median holding time on each of my accounts this week?"

## Example

The strategies make 60 trades a day on Broker A, 50 of them closed within 60 seconds (83 %). Target: 40 %.

- Needed: about 65 non-toxic trades a day, all held longer than a minute.
- Limits: 3 at once, 10 an hour. With holds averaging 25 minutes, about 7 trades an hour fit, so 65 trades need about
  10 trading hours: a London plus New York day.
- With a limit of 2 at once it would not fit. The agent says so and offers about 45 trades (about 48 % under 60 s), or
  asks you to raise the limit.

A few orders from such a plan:

| Time | Symbol | Side | Volume | Held | Exit |
|---|---|---|---|---|---|
| 08:12:37 | XAUUSD | BUY | 0.01 | 19 min | stop 8.00 |
| 08:31:05 | XAUUSD | SELL | 0.02 | 66 min | stop 11.00, target 15.00 |
| 08:47:52 | XAUUSD | SELL | 0.01 | 7.5 min | stop 6.00, trailing from 2.50 |

## Checking the result

"How did plan hold-1117 do?" The agent compares the share of trades under 10 s and under 60 s, the median holding
time and the non-toxic share of trades before and after, and reports the cost.

## Keep in mind

- Holds that cross the weekend or a news release can cost more than the whole plan.
- If the "at once" limit is full, new orders wait and may be missed. Leave room.
- Non-toxic orders only change the period they land in. A broker looking at last month still sees last month.

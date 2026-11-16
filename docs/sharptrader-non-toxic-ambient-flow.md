# Ambient flow

`sharptrader-non-toxic-ambient-flow` · [skill text](../skills/sharptrader-non-toxic-ambient-flow/SKILL.md) · [all skills](../README.md)

Small background trades in the hours and days the strategies are quiet, so the account has an ordinary trading day
instead of bursts with silence in between. Each trade is small, in a random direction, and expected to end near zero.
What it costs is the spread on those trades.

## When the agent uses it

- The account's opens are concentrated in a few hours, with silent hours or days between arbitrage bursts.
- You want a steady background of ordinary trades, or a daily or weekly schedule of non-toxic orders.

## What the agent does

1. Reads when the strategies traded over the last 1-2 weeks, hour by hour, and on how many days.
2. Agrees a target day with you. For FX and metals that is active through the London and New York sessions, with a
   dip around midday and little at night. The arbitrage hours stay the busy part of the day.
3. Fills the difference: for each hour, the target minus what the strategies already do there. It also adds a few
   trades on days the strategies did not trade, so the account looks active through the working week.
4. Keeps each trade forgettable: smallest sensible volume, symbols the account already trades, about half buys (never
   a strict alternation), holds of roughly 5-90 minutes and a stop loss on each.
5. Spreads the times at random within each hour, never two at the same second and never on a fixed grid.
6. Stays out of the daily rollover, high-impact news and the first minutes after the weekly open.
7. Books a day or a few days at a time, so it can adjust to how the strategies actually traded.

## Example requests

- "Fill the quiet hours on Broker B with small background trades for the rest of the week."
- "Make Broker A's trading day look like a person's. Plan tomorrow's background trades and show me the cost."
- "Broker A was silent on Monday and Friday last week. Add a few trades on days the strategies don't trade."
- "What did the background trades cost per day last week?"

## Example

Broker A, last week, per day: 25-40 strategy opens in each of the hours 08, 13, 14 and 15 (news and the New York
open), 0-2 in every other hour.

- Target day: at least 5 opens an hour from 07:00 to 18:00, 2 an hour from 18:00 to 22:00, 1 in three of the night
  hours.
- The busy hours already exceed the target and get nothing. The 7 quiet day hours get about 4 trades each and the
  evening about 2 an hour, roughly 39 background trades a day.
- With 3 at once and holds of about 25 minutes, about 7 trades an hour fit, so every hour fits.

| Time | Symbol | Side | Volume | Held |
|---|---|---|---|---|
| 09:23:11 | EURUSD | SELL | 0.02 | 36 min |
| 10:41:56 | XAUUSD | BUY | 0.01 | 55 min |
| 11:07:29 | EURUSD | BUY | 0.01 | 13 min |

## Checking the result

The agent compares opens by hour and trades per active day before and after, and reports the cost per day.

## Keep in mind

- Don't over-fill: a person rarely trades 20 times in every hour. Keep the night thin.
- Hours are SharpTrader's local hours. Market sessions run in their own time zones, and the agent converts them.
- Many small trades can cost more than a few long ones. Check the cost after the first day.

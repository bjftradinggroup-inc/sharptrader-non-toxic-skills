# Dilution

`sharptrader-non-toxic-dilution` · [skill text](../skills/sharptrader-non-toxic-dilution/SKILL.md) · [all skills](../README.md)

Ordinary trades for every quick winner, and a normal win rate, at a cost you agree to. Brokers judge an account by the
statistics of its flow, not by its profit. Trades closed within seconds with a small profit are what they flag. This
skill counts those quick winners, sets a ratio of ordinary trades per quick winner, and shows what reaching it costs.

## When the agent uses it

- The account shows a very high win rate with a small average profit per trade.
- You mention toxic flow, a B-book or dealing desk, a liquidity provider complaint, latency arbitrage detection,
  voided trades or an account under review.
- You ask how many non-toxic trades you need.

## What the agent does

1. **Measures.** Counts all strategy trades, the quick winners among them (closed within 60 seconds and not at a
   loss after costs) and the strategies' win rate.
2. **Sets the target with you.** The dilution ratio is the number of ordinary trades per quick winner, where ordinary
   trades are the strategies' other trades plus the non-toxic ones. A working target is 2-3. It also shows the win
   rate the broker would see.
3. **Prices it.** Multiplies the trades needed by the cost per trade and sets that next to what the strategies made
   on the account. A ratio that costs most of the arbitrage profit is not worth it, and the agent says so.
4. **Keeps the non-toxic trades ordinary.** It avoids small take profits that would make them quick winners too,
   gives them about a 50 % win rate (random sides, similar stop and target distances) and opens them in calm minutes,
   not on fast moves or right after a strategy trade.

## Example requests

- "My broker complained about toxic flow on Broker A. How many non-toxic trades would bring the account to a normal
  win rate, and what would that cost?"
- "What's my dilution ratio on Broker A this month?"
- "Plan a ratio of 1 for next week on Broker A, within my limits."

## Example

Broker A, one week: 500 strategy trades, 400 of them quick winners (80 %), a 90 % win rate and a net profit of 4,200.

| Target ratio | Non-toxic trades a week | Win rate the broker sees | Cost at about 1.5 a trade |
|---|---|---|---|
| 2 | at least 700 | about 67 % | about 1,050, a quarter of the profit |
| 1 | at least 300 | about 75 % | about 450 |

700 trades a week on one account is about 15 an hour over 45 trading hours, above a limit of 10 an hour. The agent
tells you that a ratio of 2 needs higher limits or a lower target, and offers a ratio of 1 now.

## Checking the result

After the period, the agent recounts the quick winners against all trades and reports that share, the win rate, the
average result per trade and the cost, before and after.

## Keep in mind

- The ratio is per account and per period. Dilution on one account does nothing for another, and a broker can look
  at any time window.
- Some brokers also look at what the price did in the seconds after each fill. SharpTrader's profile doesn't measure
  that, so the agent won't claim to have fixed it.

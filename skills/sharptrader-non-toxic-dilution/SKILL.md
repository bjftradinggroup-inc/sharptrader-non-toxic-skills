---
name: sharptrader-non-toxic-dilution
description: Playbook for diluting the "toxic" signature of an arbitrage account with SharpTrader non-toxic orders - counting the quick profitable trades a dealing desk flags, setting a ratio of ordinary trades per quick winner, and bringing the win rate and average profit per trade back to what ordinary traders show, at a cost the user agrees to. Use it when get_flow_profile shows a very high win rate with small positive average points, when the user mentions toxic flow, a B-book or dealing desk, a liquidity provider complaint, latency arbitrage detection, trades voided or an account reviewed, or asks how many non-toxic trades they need. Works with sharptrader-non-toxic-core.
compatibility: SharpTrader MCP server with the Non-toxic orders group switched on.
---

# Dilution of the quick-winner signature

**The idea.** Measure your own flow the way a liquidity provider or a B-book broker would. Brokers judge an account
by the statistics of its flow, not by its profit. There are two generations of filters:

- **The older one looks at closed trades:** trades held for seconds, and quick closes that take a few points of
  profit, are toxic.
- **The newer one looks at what the price does in the seconds after each open.** Latency arbitrage shows a jump
  right after the fill and nothing afterwards. A real directional trader shows a slow drift.

Count how many ordinary trades come for every toxic one (the "dilution ratio"), and treat the worst view as the
account's risk, because you never know which model a given counterparty uses.

Non-toxic trades are ordinary trades. They can't change what the price did after the arbitrage fills, but every one
of them lowers the share of quick winners, pulls the win rate down to normal and adds fills with no jump after them.

Follow the ground rules of `sharptrader-non-toxic-core` if it is installed. In short: the user's limits are final,
show the plan and its cost before booking, keep the comment empty or human, and vary every value.

## Measure

1. `get_order_history` for the session and period (the strategies' closed trades, with `openTime`, `closeTime`,
   `profit`, `commission`, `swap`). Count:
   - `S`: all strategy trades;
   - `Q`: **quick winners**, closed within 60 s of opening with profit + commission + swap ≥ 0;
   - the strategies' win rate `ws`.
2. `get_flow_profile` for the same period: `winRatePercent`, `averagePoints`, `netProfit` of `asTheBrokerSeesIt`
   and of each flow. `byFlow.nonToxic` shows what earlier non-toxic orders have added.

## Set the target with the user

- **Dilution ratio `D`**: ordinary trades per quick winner. Ordinary trades are the strategies' other trades plus
  the non-toxic. A working target is 2-3. Every step up costs more trades.
  `C ≥ D·Q − (S − Q)`.
- **Win rate**: ordinary accounts usually win on fewer than two trades in three. With non-toxic trades that win about
  half the time (`wc` ≈ 0.5), the broker sees `(S·ws + C·wc) / (S + C)`.
- **Cost**: `C` × the measured cost per non-toxic trade. Put it next to the strategies' net profit on that account.
  A ratio that costs most of the arbitrage profit is not worth it. Show both and let the user choose.

## Make the non-toxic trades ordinary

- **Not quick winners themselves.** This is the trap. A take profit of a few points on a fast symbol is hit in
  seconds and adds to `Q`. Keep take profits well beyond a typical one-minute move (ATR on M1 or M5 is a good
  yardstick, see `sharptrader-non-toxic-indicator-entries`) and holds of minutes or more
  (`sharptrader-non-toxic-holding-time`).
- **About half winners.** Random sides, and stop and target at similar distances (or no target and a time exit),
  give a win rate near 50 % minus costs.
- **No jump after the fill.** Don't open non-toxic trades on a fast move or right after a strategy trade. Random times in
  calm minutes, or LIMIT orders resting a little away from the market, fill at ordinary prices.

## Example

Broker A, one week: `S` = 500, `Q` = 400 (80 %), `ws` = 0.90, strategy net profit 4,200.

- D = 2: `C ≥ 2·400 − 100 = 700`. Win rate seen: `(450 + 350) / 1200 ≈ 67 %`.
  Cost at about 1.5 per trade ≈ 1,050 a week, a quarter of the arbitrage profit.
- D = 1: `C ≥ 800 − 500 = 300`. Win rate seen: `(450 + 150) / 800 = 75 %`. Cost ≈ 450.

Check each against capacity (core skill): 700 a week on one session needs about 15 an hour over 45 trading hours,
over a default limit of 10 an hour. So D = 2 on this account needs higher limits or a lower target. Tell the user,
and offer D = 1 now.

## Check

Recount `Q` against all trades after the period: `Q / (S + C)` is the share of quick winners the broker sees. Report
it with `winRatePercent`, `averagePoints` and the cost, before and after.

## Watch out for

- **The ratio is per broker and per period.** Dilution on one account does nothing for another, and a desk can look
  at any window.
- **Mark-out is not in the profile.** SharpTrader's flow profile doesn't measure what the price did after each fill.
  Don't claim non-toxic orders fixed something you can't see.

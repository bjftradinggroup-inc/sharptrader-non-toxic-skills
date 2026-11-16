---
name: sharptrader-non-toxic-core
description: Ground rules and the working loop for SharpTrader non-toxic orders over MCP - reading how a broker account's flow looks (get_flow_profile), the user's limits, cost and capacity, booking with send_non_toxic_orders, checking the effect and stopping a plan. Use it whenever the user wants to plan, book, review, cancel or close non-toxic orders, wants an arbitrage account to look like ordinary trading or less likely to be flagged by a broker or dealing desk, asks what the broker sees of an account, or whenever another sharptrader-non-toxic-* playbook is in use. Read it before the first send_non_toxic_orders call of a conversation, even when the request looks simple.
compatibility: Needs SharpTrader's MCP server with the Non-toxic orders group switched on by the user (send_non_toxic_orders, list_non_toxic_orders, get_flow_profile and related tools).
---

# SharpTrader non-toxic orders: ground rules and working loop

SharpTrader runs arbitrage strategies on the user's broker accounts. Arbitrage trades have a recognisable
signature: very short holding times, a high win rate with small profits, bursts at volatile moments. Dealing desks
read that signature off an account's closed trades and may widen spreads, add delays, cancel trades or close the
account.

Non-toxic orders are extra, real trades you book on the same accounts so that the account's flow as a whole looks
more like ordinary trading. SharpTrader sends them through its manual trading (the strategies never see them),
closes them itself on schedule and keeps doing so after you disconnect.

The other `sharptrader-non-toxic-*` skills are playbooks: each one applies one idea with these tools. This skill is
the common ground they all stand on.

## Be honest about what non-toxic orders do

- It changes the **aggregate statistics** a dealing desk reads: holding times, the share of very short trades, the
  buy/sell balance, win rate and average profit, hours of activity, symbol mix, trades per day.
- It does **not** change the arbitrage trades themselves. A desk that singles out the short, profitable trades will
  still find them. Non-toxic orders make them stand out less; they do not hide them. Never tell the user an account
  "will not be flagged".
- Every non-toxic trade is real money: it pays spread and commission (swap if held overnight) and carries market
  risk. The point is to spend a small, known amount to protect a larger arbitrage income. Always estimate the cost.
- Whether a broker's terms allow this is the user's decision. If they ask, say so plainly; don't argue them into it
  or out of it.

## Tools

Your MCP client may show these with a server prefix (for example `sharptrader__get_flow_profile`).

| Tool | Group | Use it to |
|---|---|---|
| `get_overview` | Read | see SharpTrader's local time and time zone, which tool groups are allowed |
| `list_sessions` | Read | find the broker accounts and whether they are connected |
| `list_strategies` | Read | see which strategy trades on which session |
| `get_flow_profile` | Read | see each account as its broker sees it: all flows together and split into strategies / non-toxic / other manual |
| `get_order_history`, `get_orders` | Read | the strategies' individual trades (times, sides, volumes, prices) |
| `list_non_toxic_orders` | Read | the non-toxic book, the user's limits per session and how much of them is in use, `sessionsWithBrokerStopLoss` |
| `list_indicators`, `get_indicator_values` | Read | technical indicators on a session's candles |
| `get_news` | Read | this week's economic calendar |
| `send_non_toxic_orders` | Non-toxic | book 1-50 orders as one plan |
| `modify_non_toxic_trailing` | Non-toxic | change the trailing stop of booked or open orders |
| `cancel_non_toxic_orders` | Non-toxic | drop orders not sent yet and resting limit/stop orders |
| `close_non_toxic_positions` | Non-toxic | close open non-toxic positions now |

If the non-toxic tools are missing, the user has not switched them on. Tell them: SharpTrader → Settings → AI agents
(MCP) → tick "Send non-toxic orders", accept the risk warning, make the session's row **Active** in the limits grid,
Apply changes, then reconnect the agent so it reloads the tool list.

## Ground rules, and why

1. **The limits are the user's.** Each session has its own row: active or not, the symbols you may trade there with
   each one's max volume per order (`maxVolumePerOrderBySymbol`; `symbolsNotAllowed` are off limits), max orders and
   positions at the broker at once, max orders per hour, max holding time. Read them with `list_non_toxic_orders`
   before planning. You cannot change them, and you should not try to get around them. If a goal needs more, say
   which limit stops it and let the user decide.
2. **A plan is checked as a whole.** If one order is wrong, nothing is booked and every problem is listed. Fix them
   and send the plan again.
3. **Nothing is sent late or twice.** An order that cannot go out within 5 minutes of its time becomes Missed, and an
   order whose fate is unclear becomes Unknown. Read the note before you book a replacement.
4. **The comment goes to the broker.** Up to 31 characters of letters, digits, spaces and `_-.,:#()/`. Words that say
   what the order is for (toxic, non-toxic, mcp, agent) are refused. Best: no comment, or something a person might type.
5. **Stops live where they are watched.** `stop_loss_points`, `take_profit_points` and the trailing stop are kept in
   SharpTrader and checked once a second, only while SharpTrader runs. `broker_stop_loss_points` is a real stop at
   the broker. It is only accepted on the sessions listed in `sessionsWithBrokerStopLoss` and must be larger than
   `stop_loss_points`. Use it as the safety net for long holds and for times SharpTrader may be off.
6. **Points are the symbol's smallest price step** (10^-digits; count the decimals of a recent price of that symbol).
   XAUUSD quoted with 2 decimals: 100 points = 1.00. EURUSD with 5 decimals: 10 points = 1 pip.
7. **Volume is in the session's own units** (`volumeUnits` in the limits): lots on most accounts, units on FIX
   accounts other than EASYFIX (10000 = 0.1 lot of a currency pair, 10 = 0.1 lot of gold), coins on crypto. Take the
   scale from the symbol's limit and from the strategies' own orders on that session, never assume lots.
8. **Times are SharpTrader's local time.** `get_overview` shows it with the time zone; arguments without an offset
   are read as local time. At most 7 days ahead, 50 orders per call, 500 active in total.
9. **Pick sensible moments.** Don't trade on a disconnected session, into a high-impact news release (`get_news`),
   at the daily rollover when spreads widen, or across the weekend close unless the user accepts the gap risk.
10. **Confirm before booking.** Show the plan, its effect and its cost, and book after the user agrees, unless they
    already told you to go ahead. Talk to the user in their own language.

## The working loop

### 1. Look

- `get_overview`: the local time and that the Non-toxic group is allowed.
- `list_non_toxic_orders`: limits per session and symbol, what is in use now (`atBrokerNow`, `sentLastHour`, `scheduled`),
  `sessionsWithBrokerStopLoss`, plans already running.
- `get_flow_profile` for the period that matters (default the last 7 days), per session. Read
  `asTheBrokerSeesIt` (what the broker sees), `byFlow.strategies` (the arbitrage signature) and
  `byFlow.nonToxic` (what has been added so far).

### 2. Diagnose

Find what stands out in `asTheBrokerSeesIt` and pick the playbook that answers it:

| What stands out | Playbook |
|---|---|
| many trades under 10 s / 60 s, short median hold | `sharptrader-non-toxic-holding-time` |
| very high win rate, small positive average points | `sharptrader-non-toxic-dilution` |
| activity in spikes, silent hours or days | `sharptrader-non-toxic-ambient-flow` |
| bursts, regular intervals, orders on round seconds | `sharptrader-non-toxic-pacing` |
| buys far from half, identical sizes, one symbol only | `sharptrader-non-toxic-order-shape` |
| quick profitable trades with nothing ordinary around them | `sharptrader-non-toxic-activity-cover` |
| every exit after a fixed time | `sharptrader-non-toxic-exit-styles` |
| trades without a visible reason | `sharptrader-non-toxic-indicator-entries` |

If a playbook skill is not installed, use the idea from this table with the rules above.

### 3. Size it: target, capacity, cost

**Dilution arithmetic.** If the strategies made `S` trades of which a share `s` has some property (say, held under 60
s), and you add `C` non-toxic trades with share `c`, the broker sees `(S·s + C·c) / (S + C)`. To reach a target
share `t`: `C ≥ S·(s − t) / (t − c)`.

Example: 400 strategy trades a week, 85 % under 60 s. To show the broker at most 40 % under 60 s with non-toxic trades
that is never under 60 s: `C ≥ 400 · 0.45 / 0.40 = 450` trades a week.

**Capacity.** A non-toxic order counts against "at once" from its send until its expected close plus 60 s. So per
session, roughly:

`trades per hour ≤ min(per-hour limit, at-once limit × 3600 / (average hold seconds + 60))`

With 3 at once and 30-minute holds that is about 5.8 an hour. Long holds eat capacity, so a target can be out of
reach within the user's limits. Then say so, offer the best reachable target, and name the limit that would have to
change.

**Cost.** Roughly trades × (spread + commission per trade at that volume), plus swap for overnight holds. Measure it
with a pilot (`byFlow.nonToxic.averageNetProfit`) rather than guessing. Compare it with the arbitrage profit on the
same account (`byFlow.strategies.netProfit`): non-toxic trading that costs a large part of what it protects is a bad deal,
and the user should know.

### 4. Pilot

Book a small plan first: 5-10 orders, small volume, a plan name. Check with `list_non_toxic_orders` that they are
filled and closed as expected, and read their real cost.

### 5. Book

Book in plans of at most 50 orders, each with a name you can refer to later (for example `hold-1114`). Plan names
stay in SharpTrader; they never reach the broker.

**Vary everything.** People don't trade at round times, with identical sizes, for identical durations. Draw send
times, holding times, sizes and distances from ranges and avoid repeating a value within a plan. Language models
are poor at randomness: if you can run code, generate the values with a random generator; if you cannot, vary them
deliberately and check for repeats before sending.

### 6. Check

- `list_non_toxic_orders` with `state: "finished"`: read the notes of Missed, Rejected, Failed and Unknown orders.
- `get_flow_profile` again after the trades have closed (they reach the database a few seconds after closing).
  Compare before and after on the figures you set out to change, and report the cost so far.

### 7. Stop

`cancel_non_toxic_orders` with the plan name drops what is not sent yet and resting orders;
`close_non_toxic_positions` with the plan name closes what is open. `all: true` does it for every plan.

## Order fields

```json
{
  "plan": "hold-1114",
  "orders": [
    { "session": "Broker A", "symbol": "XAUUSD", "side": "SELL", "volume": 0.03,
      "send_at": "2026-11-14T10:17:43", "hold_seconds": 2710,
      "stop_loss_points": 900, "take_profit_points": 1300 },
    { "session": "Broker A", "symbol": "XAUUSD", "side": "BUY", "volume": 0.02,
      "type": "LIMIT", "offset_points": 150, "expire_seconds": 1800,
      "delay_seconds": 2950, "hold_seconds": 5320, "stop_loss_points": 1000,
      "trailing_min_profit_points": 400, "trailing_step_points": 300 }
  ]
}
```

- Required: `session`, `symbol` (as the session names it, suffix included), `side`, `volume`, `hold_seconds` (from
  the fill to SharpTrader's market close).
- `type`: MARKET (default), LIMIT or STOP. LIMIT/STOP need `price` or `offset_points` (from the market at send time)
  and `expire_seconds`.
- `send_at` or `delay_seconds` (default: now).
- Optional: `stop_loss_points`, `take_profit_points`, `broker_stop_loss_points`, `trailing_min_profit_points`,
  `trailing_step_points`, `comment`, `leverage` (crypto).

## Reporting to the user

Keep it short and concrete:

1. What the broker sees now, as the 2-3 figures that stand out.
2. What you plan: number of orders, sessions, symbols, volumes, time span, plan name.
3. The expected effect on those figures, using the arithmetic above.
4. The estimated cost, and how much of each limit the plan uses.
5. How to stop it.

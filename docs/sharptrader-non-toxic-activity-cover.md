# Activity cover

`sharptrader-non-toxic-activity-cover` · [skill text](../skills/sharptrader-non-toxic-activity-cover/SKILL.md) · [all skills](../README.md)

Ordinary trades on the same symbol after bursts of arbitrage activity. On its own, arbitrage is a run of quick winners
with nothing around it. Among ordinary trades on the same symbol, some of them losing, the same run is much less
striking. This skill finds where and when the strategies just traded and books a few longer-held trades on the same
account and symbol minutes later.

## When the agent uses it

- You ask it to cover or follow up the strategies' recent trades.
- You want it to check every few hours and add trades where the arbitrage has been active.
- The account shows quick winners concentrated in bursts on a few symbols.

## What the agent does

1. Reads the strategies' trades since its last check and marks **bursts**: for example 5 or more trades on one
   symbol within 10 minutes. For each burst it notes when it ended, how many trades were quick winners and whether it
   bought or sold more.
2. Checks which bursts are already covered (cover plans are named after their burst) and never covers one twice.
3. For each burst not yet covered, books:
   - **How many:** about one trade for every 2-4 quick winners, within your limits. Never one for one.
   - **When:** the first 3-30 minutes after the burst, the rest over the next hour or two. Never in the seconds after
     it.
   - **What:** same account and symbol, small volumes different from the burst's, holds of 10 minutes to a few hours.
   - **Which side:** random, leaning against the burst's direction. Some of these trades will lose, which is part of
     the picture.
   - **Exits:** a varied mix, always with a stop loss.

It never closes and reopens the same side and size within a second: that is the classic latency-arbitrage pattern and
makes things worse.

## Example requests

- "Check what the strategies traded since this morning and cover it."
- "Which bursts from today are not covered yet?"
- "Every time I open this chat, look for new bursts on my accounts and cover them."

## Example

Broker A, XAUUSD: 14 strategy trades between 14:02 and 14:12, 12 of them quick winners, 10 of them buys. The agent
books 4 trades (one for every 3 quick winners), the first 9 minutes after the burst, three of four against the burst's
buying:

| Time | Side | Volume | Held | Exit |
|---|---|---|---|---|
| 14:21:38 | SELL | 0.02 | 47 min | stop 9.00, target 12.00 |
| 14:49:05 | SELL | 0.01 | 89 min | stop 10.00, trailing from 4.00 |
| 15:26:44 | BUY | 0.03 | 24 min | stop 7.50 |
| 15:58:12 | SELL | 0.01 | 65 min | stop 8.50 |

## Staying on top of it

The agent only sees bursts when it looks. Agree how often it should check: each time you open the chat, or on a
schedule if your agent can run scheduled tasks. Between checks, ambient flow can book background trades in advance
from the strategies' usual hours, so cover only has to handle what was unusual.

## Checking the result

Per symbol, the agent compares non-toxic trades with all trades, and the share under 60 seconds and the win rate on the
burst symbols, before and after. It also reports what the cover cost.

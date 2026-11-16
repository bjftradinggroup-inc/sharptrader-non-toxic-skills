---
name: sharptrader-non-toxic-pacing
description: Playbook for timing SharpTrader non-toxic orders so they don't look machine-made - an hourly budget kept below the user's limits, irregular gaps between orders, random seconds, no bursts and no fixed grid - and for spreading a large plan over hours or days. Use it whenever you choose send_at or delay_seconds for more than a handful of non-toxic orders, when orders come back Missed because a limit was reached, or when get_flow_profile or the order history shows trades at regular intervals, on round times or in bursts. Works with sharptrader-non-toxic-core.
compatibility: SharpTrader MCP server with the Non-toxic orders group switched on.
---

# Pacing

**The idea.** Meter the trades sent to each broker: only so many in a time window, and the next one waits until the
quota refills rather than going out in a burst. And never act on the first tick a chance appears: wait a random delay
first. A quota against bursts and a random delay against
reaction-time patterns are two of the simplest ways a flow stops looking automated.

Non-toxic orders are scheduled, so they are easy to make look scheduled: every 15 minutes, at :00 seconds, ten in
a minute. This playbook is about not doing that, while staying inside the user's limits.

Follow the ground rules of `sharptrader-non-toxic-core` if it is installed. In short: the user's limits are final,
show the plan and its cost before booking, keep the comment empty or human, and vary every value.

## What the broker sees

Individual open times. `get_flow_profile` gives only the hourly counts (`opensByHour`), but a dealing desk has every
timestamp: fixed intervals, orders on round seconds and clusters that start within a second of each other all stand
out on a chart of the account.

## Rules for timing

1. **Keep headroom under the per-hour limit.** Plan at most about 70 % of the user's "orders per hour" for each
   session. An order whose time comes while the limit is full waits, is retried for 5 minutes and is then Missed.
   Headroom also leaves room for the user's own manual trades.
2. **Check "at once" over time, not just per hour.** An order uses the at-once limit from its send to its expected
   close plus 60 s. Walk through the plan in time order and count what would be at the broker at each send. The
   engine refuses a plan that breaks the limit at any moment, but planning for it saves a round trip.
3. **Irregular gaps.** Draw the gap between orders at random, not as a constant. Exponential-like gaps (many short,
   some long) look like independent decisions. As a simple recipe: choose the average gap `g` for the hour, then
   draw each gap from `g × (−ln u)` with `u` random between 0 and 1, and add a few seconds.
4. **Random seconds, no repeats.** Never send on :00, never two orders at the same second, and don't give two orders
   of a plan the same gap.
5. **No bursts.** Even when the hourly budget allows ten orders, don't put them in one minute. If you need to move
   size quickly, use fewer, larger orders within the per-order limit.
6. **Don't line up with the arbitrage.** A non-toxic order a second after a strategy trade looks linked to it.
   Leave minutes between them (see `sharptrader-non-toxic-activity-cover` for trades meant to follow arbitrage).
7. **Book in pieces you can adjust.** A plan for the next few hours or the next day lets you react to Missed orders,
   news and the strategies' actual activity. Plans can reach 7 days ahead, but long plans are harder to correct.

## Example

Budget: 6 orders an hour on Broker A (limit 10), 4 hours, average gap 10 minutes. Drawn gaps (minutes): 3.4, 17.9,
6.2, 11.0, 0.9, 24.5, 8.7, … plus random seconds, giving send times like 09:03:22, 09:21:16, 09:27:29, 09:38:31,
09:39:27, 10:03:58, 10:12:41. Nothing on the hour, nothing on a grid, one quick pair. That reads like someone
reacting to the market.

If you can run code, generate the times there. If you cannot, write them down, then check that no gap or second
repeats and no hour exceeds the budget.

## When orders are Missed

`list_non_toxic_orders` with `state: "finished"` gives the reason in each order's note. A limit reached means the
plan was too dense: thin it before booking the next one. A disconnected session means the user should look at the
connection. Don't rebook Missed orders blindly at the same density.

## Check

`list_non_toxic_orders` shows `sentLastHour` and `atBrokerNow` against each limit while a plan runs. Afterwards,
`opensByHour` should look smooth rather than spiky in the hours you paced.

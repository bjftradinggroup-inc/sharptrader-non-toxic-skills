# Pacing

`sharptrader-non-toxic-pacing` · [skill text](../skills/sharptrader-non-toxic-pacing/SKILL.md) · [all skills](../README.md)

Timing that doesn't look machine-made. Scheduled orders are easy to make look scheduled: every 15 minutes, on :00
seconds, ten in one minute. This skill keeps an hourly budget below your limits, draws irregular gaps with random
seconds, and avoids bursts. Every other playbook relies on it whenever it picks send times.

## When the agent uses it

- Whenever it chooses send times for more than a handful of non-toxic orders.
- When orders come back Missed because a limit was reached.
- When the account's trades show regular intervals, round times or bursts.

## What the agent does

1. Plans at most about 70 % of your "orders per hour" limit for each account. This leaves headroom for retries and
   for your own manual trades.
2. Walks through the plan in time order to check the "at once" limit at every moment, not only per hour.
3. Draws irregular gaps between orders: many short ones and some long ones, like independent decisions.
4. Uses random seconds: never :00, never two orders in the same second, never the same gap twice.
5. Avoids bursts. If size has to move quickly, it uses fewer, larger orders within your per-order limit.
6. Leaves minutes between a non-toxic order and a strategy trade, so the two don't look linked.
7. Books in pieces of a few hours or a day, which are easier to adjust than a week-long plan.

## Example requests

- "Spread these 40 orders over tomorrow so they don't look scheduled."
- "Half of yesterday's plan was Missed. Why, and what should we change?"
- "Check that my non-toxic orders aren't on round seconds or at fixed intervals."
- "How much of the hourly limit is in use on Broker A right now?"

## Example

Budget: 6 orders an hour on Broker A (limit 10), for 4 hours, with an average gap of 10 minutes.

- Drawn gaps in minutes: 3.4, 17.9, 6.2, 11.0, 0.9, 24.5, 8.7 and so on, plus random seconds.
- Resulting send times: 09:03:22, 09:21:16, 09:27:29, 09:38:31, 09:39:27, 10:03:58, 10:12:41.

Nothing is on the hour or on a grid, and there is one quick pair. It reads like someone reacting to the market.

## When orders are Missed

An order whose time comes while a limit is full waits, is retried for 5 minutes and is then Missed. The agent reads the
reason for each Missed order. If a limit was reached, the plan was too dense and it thins the next one. If the account
was disconnected, it asks you to check the connection. It does not rebook missed orders blindly at the same density.

## Checking the result

While a plan runs, the agent can show orders sent in the last hour and positions at the broker against each limit.
Afterwards, opens by hour should look smooth rather than spiky.

# Core: ground rules and the working loop

`sharptrader-non-toxic-core` · [skill text](../skills/sharptrader-non-toxic-core/SKILL.md) · [all skills](../README.md)

The base skill. It teaches your agent what non-toxic orders are, which SharpTrader tools to use, how to read your
account the way your broker reads it, how to respect your limits and how to work out what a plan will do and cost.
The other eight skills are playbooks that build on it, so **always install this one**.

## When the agent uses it

Whenever you talk about non-toxic orders: planning, booking, reviewing, cancelling or closing them, asking how an
account looks to its broker, or asking whether an account is likely to be flagged. The agent reads it before its first
booking in a conversation, even for a simple request.

## What the agent does

1. **Looks.** Reads SharpTrader's local time, your limits per account and what is in use now
   (`list_non_toxic_orders`), and how each account looks to its broker (`get_flow_profile`, last 7 days by default).
2. **Diagnoses.** Finds the figures that stand out (many trades closed within a minute, a very high win rate, bursts,
   one-sided buying) and picks the playbook for each.
3. **Sizes the plan.** Works out how many non-toxic trades the goal needs, whether your limits allow that many, and
   what they will roughly cost.
4. **Pilots.** Suggests 5-10 small orders first, to measure the real cost.
5. **Books** after you agree, in named plans of up to 50 orders.
6. **Checks** the result after the trades close and reports before and after, with the cost.
7. **Stops** a plan when you ask: cancels what is not sent yet and closes what is open.

Rules it keeps: your limits are final (it tells you which limit stops a goal, it never works around it); it shows the
plan and its cost before booking; the broker-visible comment stays empty or ordinary; every time, size and distance is
varied.

## Example requests

- "How does my account at Broker A look to the broker this week?"
- "What are my non-toxic limits on each account, and how much of them is in use right now?"
- "Book a pilot: 5 small non-toxic orders on Broker A over the next two hours. Show me the plan first."
- "What did the non-toxic orders cost on Broker A last week, compared with what the strategies made there?"
- "Stop plan hold-1117 and close what is open."
- "Stop all non-toxic orders on Broker A."

## Example conversation

> **You:** How does Broker A look to the broker this week?
>
> **Agent:** Last 7 days on Broker A: 412 trades, 84 % closed within 60 seconds, median holding time 9 seconds, win
> rate 89 %. The share of quick trades stands out most. Bringing it to 40 % would take about 450 non-toxic trades a week
> held several minutes or more, about 90 a trading day. With your limits (3 at once, 10 an hour) and holds of about 20
> minutes, that takes about 11 trading hours a day. At an estimated 1.5 per trade it costs about 680 a week, against
> 3,900 the strategies made there. I suggest a pilot of
> 8 orders tomorrow morning to measure the real cost. Shall I show it?
>
> **You:** Yes.
>
> **Agent:** *(shows 8 orders: times, sides, volumes, holding times, stops, plan name `pilot-1117`)*
>
> **You:** Book it.

The figures are an illustration. Your agent works with your own account's numbers.

## Checking the result

Ask "How did plan pilot-1117 go?" The agent reads which orders were filled and how each one ended, then compares the
account's figures before and after and reports what the plan cost.

## Keep in mind

- Non-toxic orders are real trades. They pay spread and commission and they can lose.
- They make arbitrage trades stand out less. They cannot hide them, and the agent will not promise that an account
  won't be reviewed.
- Whether your broker's terms allow this is your decision.

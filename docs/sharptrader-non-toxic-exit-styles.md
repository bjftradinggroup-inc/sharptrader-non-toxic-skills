# Exit styles

`sharptrader-non-toxic-exit-styles` · [skill text](../skills/sharptrader-non-toxic-exit-styles/SKILL.md) · [all skills](../README.md)

How non-toxic positions end. If every position closes exactly when its holding time runs out, the holding times line
up in a way no person produces. This skill gives each position its own exit style (a target, a stop, a trailing stop,
locked-in profit, or its time) and makes sure every position stays protected, with a stop at the broker as a safety net
where the account supports one.

## When the agent uses it

- Whenever it sets stops, targets, trailing values or holding times for non-toxic orders.
- When you want to tighten or change the stops of running non-toxic orders.
- When you worry about non-toxic positions while SharpTrader is off.

## The exits

| Exit | Where it lives |
|---|---|
| Time (holding time, always set) | SharpTrader closes at market |
| Stop loss, take profit, trailing stop | SharpTrader, checked once a second while it runs |
| Broker stop loss | at the broker, also while SharpTrader is off (only on accounts that support it) |

The trailing stop has two settings: a minimum profit and a step. With a step, once the profit passes the minimum, the
stop follows the price at the step's distance and only ever moves in your favour. With no step, the stop jumps to lock
in the minimum profit once it is reached.

## What the agent does

1. Gives each order one style at random, roughly:
   - **Bracket** (about 40 %): stop and target, sometimes equal, sometimes the target 1.5-2 times the stop.
   - **Trailing** (about 30 %): a trailing stop that starts at about a third to half of the stop distance.
   - **Lock-in** (about 10 %): locks in a minimum profit once reached.
   - **Time only** (about 20 %): a stop loss, closed by its holding time.
2. Varies the distances within each style and scales them to the symbol's volatility. The holding time is always set
   as the outer limit.
3. Puts a stop loss on every order. On accounts that support it, it adds a wider broker stop for holds of more than an
   hour, anything held overnight, or times when SharpTrader may be off.
4. Changes running orders on request. A stop that is already set is never loosened.

## Example requests

- "Make sure the non-toxic positions don't all close on their timer."
- "Lock in profit on all open non-toxic positions before the 14:30 news."
- "SharpTrader will be off tonight. Which non-toxic positions are protected at the broker?"
- "Tighten the trailing stops on plan hold-1117."
- "How did last week's non-toxic positions end: target, stop, trailing or time?"

## Example: four orders, one of each style

| Time | Symbol | Side | Volume | Held at most | Exit |
|---|---|---|---|---|---|
| 09:14:26 | XAUUSD | BUY | 0.02 | 1 h 42 min | bracket: stop 7.00, target 12.50 |
| 09:52:03 | XAUUSD | SELL | 0.01 | 2 h 4 min | trailing from 3.20, step 2.60, stop 8.50, broker stop 14.00 |
| 10:31:40 | EURUSD | SELL | 0.03 | 55 min | lock-in at 6 pips, stop 14 pips |
| 11:08:57 | EURUSD | BUY | 0.01 | 33 min | time only, stop 16 pips |

## Checking the result

The agent reads how each finished position ended and reports the mix of target, stop, trailing and time, and whether
any was closed by the broker at its stop.

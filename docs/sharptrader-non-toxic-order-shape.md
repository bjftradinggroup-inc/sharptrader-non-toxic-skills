# Order shape

`sharptrader-non-toxic-order-shape` · [skill text](../skills/sharptrader-non-toxic-order-shape/SKILL.md) · [all skills](../README.md)

Side, size, splitting and symbols. A dealing desk that sees one side, one size and one symbol sees a machine. This
skill balances buys and sells, varies sizes, sometimes splits an order in two and spreads trades over related symbols.
Every other playbook relies on it whenever it picks sides, volumes or symbols.

## When the agent uses it

- Whenever it chooses the side, volume or symbol of non-toxic orders.
- When the share of buys is far from half, overall or on one symbol.
- When one symbol carries almost all trades, or the strategies' orders repeat the same sizes.

## What the agent does

- **Side.** Aims at roughly 40-60 % buys on each symbol over a week, never exactly 50 %. If the strategies lean one
  way on a symbol, it gives the non-toxic orders on that symbol more of the other side, then draws each side at
  random. A strict buy-sell-buy alternation is a pattern too.
- **Size.** Stays on the account's volume step and within your per-order limit. It draws sizes from a range, usually
  smaller than the strategies' sizes, and avoids their exact sizes, repeats within a plan and favourite round numbers.
  Size never follows how confident a trade looks.
- **Splitting.** About one order in five goes out as two orders on the same side, a few seconds to a few minutes
  apart, with slightly different volumes. On the account this looks like scaling into a position.
- **Symbols.** If one symbol carries almost everything, it adds a few trades on one or two related symbols the account
  already trades, for example XAGUSD next to XAUUSD. It uses each symbol's exact name, suffix included, and asks you
  before using a symbol the account has never traded.

## Example requests

- "My XAUUSD trades on Broker A are 72 % buys. Balance that with non-toxic orders."
- "The strategies always trade 0.10 or 0.20 lots. Make the non-toxic sizes look different."
- "Everything on Broker B is EURUSD. Add some trades on a related symbol."
- "What's the buy/sell balance per symbol on each of my accounts this week?"

## Example

Broker A over a week: the strategies made 300 trades on XAUUSD, 72 % buys, all of 0.10 or 0.20 lots. Target: 55 %
buys on XAUUSD, with 200 non-toxic trades there.

- Side: the non-toxic orders need about 30 % buys, so each side is drawn with that probability.
- Size: 0.01 to 0.07 lots in steps of 0.01, never 0.10 or 0.20.
- Splitting: about 40 of the 200 go out as split pairs.
- Symbols: plus 40 trades on XAGUSD at 0.01-0.03 lots, about half of them buys.

| Time | Symbol | Side | Volume | Held | Note |
|---|---|---|---|---|---|
| 10:05:47 | XAUUSD | SELL | 0.04 | 31 min | split pair, first half |
| 10:07:19 | XAUUSD | SELL | 0.03 | 41 min | split pair, second half |
| 10:38:02 | XAGUSD | BUY | 0.02 | 20 min | |

## Checking the result

The agent reports the share of buys overall and per symbol, and the number of symbols traded, before and after.

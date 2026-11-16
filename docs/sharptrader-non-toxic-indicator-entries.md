# Indicator entries

`sharptrader-non-toxic-indicator-entries` · [skill text](../skills/sharptrader-non-toxic-indicator-entries/SKILL.md) · [all skills](../README.md)

Non-toxic entries with a visible technical reason. A dealing desk that reviews an account by hand opens a chart.
Trades that sit on textbook setups, with stops that fit the market's current range, look like a trader's decisions;
random times with fixed distances look generated. This skill times entries on indicator setups read from SharpTrader
and sizes stops, targets and limit offsets from ATR.

**Needs:** candle collection switched on in SharpTrader for the symbol and timeframe used (Session properties ›
Symbols), with the session connected.

## When the agent uses it

- You want non-toxic trades that look like real trading ideas rather than random trades.
- You mention indicators or setups (Bollinger Bands, RSI, ATR, ADX) for non-toxic orders.
- You ask how to size non-toxic stops and targets to volatility.

## What the agent does

1. Lists SharpTrader's indicators once, to use their exact names and parameters.
2. Reads indicator values on closed bars of a timeframe a person would watch (M15 or H1). If SharpTrader warns that
   candles are missing or collection is off, it asks you to switch it on rather than trading on bad data.
3. Looks for one of three setups:
   - **Band return:** a bar closed outside a Bollinger Band and the next closed back inside, in a range (low ADX). It
     trades back toward the middle band.
   - **Trend pullback:** strong trend (high ADX), price on the trend side of a rising or falling EMA. It trades a
     pullback toward the EMA.
   - **RSI extreme:** RSI below about 30 or above about 70. It trades the reversal with a modest target.
4. Sizes distances from ATR: stop about 1-1.5 ATR, target about 1-2 ATR, a limit offset of about 0.2-0.5 ATR, with
   the multiples varied from trade to trade.
5. Sends a little after the bar closes (30-180 seconds later, at random), or rests a limit order at the band for one
   or two bars. It skips setups around high-impact news.

None of these setups is expected to make money, and nothing here is trading advice. They give the trades a
recognisable reason.

## Example requests

- "Give some of the non-toxic trades a technical reason: use Bollinger Band returns on XAUUSD H1."
- "Size the stops and targets of tomorrow's non-toxic orders to ATR."
- "Is there an RSI extreme on EURUSD M15 right now? If so, propose one non-toxic trade."

## Example

Broker A, XAUUSD, H1, prices with two decimals. At 14:00 the 13:00 bar closed back inside the lower band after a close
below it. ADX is 18 (a range) and ATR is 6.40.

| Order | Value |
|---|---|
| Side and type | BUY LIMIT, 1.90 below the market, valid 70 minutes |
| Sent | 97 seconds after the bar closed |
| Volume | 0.02 |
| Stop loss / take profit | 8.20 / 11.50 (about 1.3 and 1.8 ATR) |
| Held at most | 2 h 35 min |

## Combine with other skills

Setups are rare, so they cover part of the non-toxic orders. Ambient flow fills the rest, and the exit-styles skill
takes its distances from the ATR read here.

## Checking the result

After the trades close, the agent reports how many hit their target, their stop or their time limit. A believable mix
has all three.

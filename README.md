# SharpTrader non-toxic skills for AI agents

Nine skills that teach your AI agent how to use SharpTrader's **non-toxic orders** well: what a broker sees of your
account, which ordinary-looking trades to add, how many, when, at what cost, and how to check the result.

Non-toxic orders are real trades your agent books through SharpTrader's MCP server on your broker accounts, next to
your arbitrage strategies. SharpTrader sends and closes them on schedule, within the limits you set. The skills don't
add any power to the agent. They help it plan within what you allow.

## The skills

| Skill | The idea | Guide |
|---|---|---|
| `sharptrader-non-toxic-core` | Ground rules, reading the flow profile, limits, cost and capacity, the plan-book-check loop. **Always install it.** | [guide](docs/sharptrader-non-toxic-core.md) |
| `sharptrader-non-toxic-holding-time` | Trades held minutes to hours, so fewer of the account's trades are closed within seconds | [guide](docs/sharptrader-non-toxic-holding-time.md) |
| `sharptrader-non-toxic-ambient-flow` | Small background trades in quiet hours, so the account has an ordinary trading day | [guide](docs/sharptrader-non-toxic-ambient-flow.md) |
| `sharptrader-non-toxic-pacing` | Irregular timing within an hourly budget: no bursts, no fixed intervals, no round seconds | [guide](docs/sharptrader-non-toxic-pacing.md) |
| `sharptrader-non-toxic-order-shape` | Balanced sides, varied sizes, split orders, more than one symbol | [guide](docs/sharptrader-non-toxic-order-shape.md) |
| `sharptrader-non-toxic-dilution` | Ordinary trades per quick winner, and a normal win rate, at a cost you agree to | [guide](docs/sharptrader-non-toxic-dilution.md) |
| `sharptrader-non-toxic-indicator-entries` | Entries on visible technical setups, with stops and targets sized to volatility | [guide](docs/sharptrader-non-toxic-indicator-entries.md) |
| `sharptrader-non-toxic-exit-styles` | A mix of targets, stops, trailing and time exits, with a broker stop as a safety net | [guide](docs/sharptrader-non-toxic-exit-styles.md) |
| `sharptrader-non-toxic-activity-cover` | Ordinary trades on the same symbol after bursts of arbitrage activity | [guide](docs/sharptrader-non-toxic-activity-cover.md) |

Each guide describes the skill, when the agent uses it, example requests and a worked example.

## Before you start

1. SharpTrader → Settings → AI agents (MCP): the server is on and your agent is connected (Client set-up buttons).
2. Tick **Send non-toxic orders**, read and accept the risk warning.
3. In the limits grid, make each account you want to use **Active** and set its limits: max volume per order, max
   orders and positions at once, max orders per hour, max holding time. Apply changes.
4. Reconnect your agent, so it sees the non-toxic tools.

## Build the upload files

```
powershell -ExecutionPolicy Bypass -File pack.ps1
```

`pack.ps1` writes to `dist\`:

- `sharptrader-non-toxic-plugin.zip`: all nine skills as one plugin;
- one zip per skill, for agents that take skills one by one.

## Install

### Claude Desktop

1. In the sidebar, open **Plugins**.
2. Click **Add** (top right) and choose to upload. The upload page takes plugin and skill files and accepts several
   at once.
3. Drop **one** of these and click **Upload**:
   - `dist\sharptrader-non-toxic-plugin.zip`: all nine skills in one go (recommended); or
   - the skill zips you want from `dist\`. Always include `sharptrader-non-toxic-core.zip`.
4. On the Plugins page, the **Skills** filter shows the installed skills. Make sure they are switched on.

If Claude never reads the skills, check Settings → Capabilities: code execution / "Create and edit files" must be on.

### Claude Code

Copy the folders in `skills\` to `%USERPROFILE%\.claude\skills\`, or load the whole set as a plugin with
`claude --plugin-dir <this folder>`.

### ChatGPT desktop app and Codex

- **Skills:** copy the folders in `skills\` to `%USERPROFILE%\.agents\skills\`, or open **Skills** in the ChatGPT
  sidebar and upload the skill zips from `dist\`. Type `@` in ChatGPT (`$` in Codex) to pick a skill by hand.
- **SharpTrader's tools:** the ChatGPT desktop app, Codex CLI and the Codex IDE extension read MCP servers from
  `%USERPROFILE%\.codex\config.toml`. Add SharpTrader with the address shown on its AI agents (MCP) page:

  ```toml
  [mcp_servers.sharptrader]
  url = "http://127.0.0.1:47350/mcp"
  bearer_token_env_var = "SHARPTRADER_MCP_TOKEN"
  ```

  Put the token in the variable once (`setx SHARPTRADER_MCP_TOKEN "<token from SharpTrader>"`) and restart the app.
- ChatGPT in a web browser can't reach SharpTrader: its custom connectors need an OAuth sign-in, which SharpTrader's
  token doesn't use.

### Other agents

- **Agents that read Agent Skills (`SKILL.md` folders):** put the folders from `skills\` in that agent's skills folder.
- **Agents without skills support:** paste the text of `skills\sharptrader-non-toxic-core\SKILL.md`, then of the
  playbooks you want, into the agent's instructions.

## Using the skills

You don't call a skill. Ask in plain words, and the agent reads the skills that match before it acts. To be sure, name
one: "use the sharptrader-non-toxic-holding-time skill".

Things to ask:

- "How does my account at Broker A look to the broker this week?"
- "Plan non-toxic orders for tomorrow on Broker A so that fewer than 40 % of trades close within a minute. Show me the
  cost first."
- "Fill the quiet hours on Broker B with small background trades for the rest of the week."
- "Check what the strategies traded since this morning and cover it."
- "Lock in profit on all open non-toxic positions before the 14:30 news."
- "Stop all non-toxic orders on Broker A."

## Repository layout

```
.claude-plugin/plugin.json   plugin manifest (all skills as one plugin)
skills/<skill>/SKILL.md      the skills, as the agent reads them
docs/<skill>.md              a guide per skill, for people
pack.ps1                     builds the upload zips in dist\ (not kept in git)
```

## Links

- Overview on the website: [Non-toxic skills for AI agents](https://bjftradinggroup.com/mcp-for-trading/non-toxic-skills/)
- SharpTrader MCP server: [bjftradinggroup-inc/sharptrader-mcp](https://github.com/bjftradinggroup-inc/sharptrader-mcp) · [MCP for trading guide](https://bjftradinggroup.com/mcp-for-trading/)
- Product: [SharpTrader AI Agents (MCP Server) module](https://bjftradinggroup.com/product/sharptrader-ai-agents-mcp/)
- Contact: Telegram [@borisfesenko](https://t.me/borisfesenko) · Channel [t.me/bjftradinggroup](https://t.me/bjftradinggroup)

## Keep in mind

- Non-toxic orders are real orders with real money. They pay spread and commission, and they can lose. Ask the
  agent for the cost before it books, and check it afterwards.
- Your limits are the ceiling. The agent cannot raise them and will tell you when a goal needs more.
- Non-toxic orders make the arbitrage trades stand out less. They cannot make them invisible, and no one can promise
  that an account won't be reviewed.
- Whether your broker's terms allow this is your decision.

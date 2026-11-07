# Limits

Outcome: the honest boundary of the tool, in one place — what Telegraf does not do, what it can do damage with, and where its quality is exactly the quality of what you told it. Every limit here was either shown in the lab or follows from a setting the lab used; the criteria keep the two apart.

## It does not store, graph, or alert

This is the limit beginners meet first, so it comes first. Telegraf holds points for seconds, in a buffer, on their way somewhere else. There is no history in the agent, no query language to ask it questions, no dashboard, no threshold that wakes anyone up. If the destination is down longer than the buffer can cover, the points are gone (chapter 11). Storing, graphing and alerting are real jobs — they belong to the database and to Grafana (chapter 13) — and a monitoring setup is not finished when Telegraf is installed. It is finished when all three jobs have an owner.

## Tag cardinality can sink the database behind it

The agent will cheerfully tag points with anything you tell it to. Each distinct combination of tag values becomes a separate series the database must index (chapter 7), and a tag whose values are unbounded — request IDs, timestamps, per-user labels from a busy service — multiplies series until the store slows and queries crawl. Telegraf prints no warning while this happens; the points look perfectly healthy in `--test`. The limit is architectural: the conveyor cannot know which of your tags are safe. Only your knowledge of the value set can. If you cannot list a tag's possible values, it does not belong in a tag.

## Parsing is only as good as the pattern you wrote

A parser does not understand your file; it obeys your description of it. The lab's JSON fixture parsed cleanly because the description was exact — `tag_keys` named, format named. Let the source drift — a renamed key, a new log layout, a CSV column added at the left — and the parser keeps obeying the old description: fields vanish or change type, silently, while the agent runs green. The defences are chapter 5's (`--test` after any source change) and a habit of checking that the fields you graph still exist. It is listed as a limit because no setting removes it: the agent cannot tell a correct parse of a changed file from a wrong one.

## A metric with the wrong tags is wrong forever

Chapter 1's rule, stated as a limit because it bounds what any later effort can achieve: stored points cannot be re-tagged. A fleet that collects for a month without the tag you turn out to need has a month of history that cannot answer the question, full stop. Telegraf's test modes exist to make this a cheap mistake in the lab instead of an expensive one in production — but the tool cannot make the decision for you, and it cannot undo it afterwards.

## An agent on every host is another thing to keep updated

The conveyor model multiplies the agent by the size of the estate. Every host's copy must be configured, permissioned, watched for absence, and upgraded — and defaults and option spellings do move between versions (the lab's own transcripts show a startup warning announcing a default that changes in the next minor series). None of this is heavy per host; all of it is real in total, and it is the standing price of the push model (chapter 13 gives the neighbouring pull model's different price fairly).

## Smaller print, honestly stated

- **The buffer is finite and in memory.** Long destination outages lose data (chapter 11); a host that loses power loses its buffer. Telegraf is not a queue with a disk.
- **Clocks are trusted.** A point's timestamp comes from the source or the host clock. A host with a wrong clock writes its history in the wrong place, and chapter 9's listener accepts the sender's timestamps as given.
- **Gathering is sampling.** An interval of 10 seconds sees the machine ten times a minute, not continuously; a spike that lives and dies inside an interval may never be measured at all.
- **The catalogue is wider than any one guide.** 244 inputs means most plugins will behave in ways this guide never exercised; each plugin's own `--usage` text and sample settings are the authority for that plugin, and some plugins need credentials, services or hardware the lab did not have.
- **A listener is a door.** Bound beyond loopback without the plugin's authentication and TLS settings, an HTTP input accepts measurements from anyone who can reach it. The lab's listener was loopback-only for exactly this reason.

Check: name the three jobs Telegraf does not do, the tag mistake that can sink a database, and the tag mistake that can never be repaired. If the last two have different answers — cardinality versus wrong tags — you have the chapter.

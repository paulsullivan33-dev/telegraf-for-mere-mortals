# What Telegraf is

By the end of this chapter you can say, in one sentence, what Telegraf takes off your hands — and state the one rule that decides whether the database behind it can ever answer your questions.

## The measurements nobody keeps

Run a computer for a week and it will have been busy, idle, short of memory, calm, and busy again, in a pattern that explains almost every complaint anyone will ever make about it. None of that survives. The figures exist for a moment, in the machine's own counters, and then they are overwritten by the next moment's figures. When someone says "the server was slow on Tuesday", there is usually no record of Tuesday at all — only a feeling.

Keeping that record takes three different jobs:

1. **Collect and carry** — visit each machine on a timer, take its measurements, label them clearly, and deliver them somewhere.
2. **Store and answer** — keep the measurements for months and answer questions across them.
3. **Show and warn** — draw the graphs and raise the alerts.

**Telegraf** does exactly the first job, and only the first. It is a small program — its own description, from `telegraf --help`, is "The plugin-driven server agent for collecting & reporting metrics" (transcript `telegraf-lab/transcripts/t00-version-and-help.txt`). You run one copy on each host. On a timer it gathers measurements through **input plugins** (one per kind of source: the processor, a log file, a sensor feed, a web endpoint), tidies them through optional **processors** and **aggregators**, and hands them to **output plugins** (one per destination: a database, a file, a message queue). Then it forgets them. Forgetting is not a flaw in the design; it is the design.

This guide's lab ran **Telegraf 1.40.3**, the current release at the time of writing, taken straight from InfluxData's download site. Its startup banner reports what one binary carries: 244 inputs, 9 aggregators, 35 processors, 26 parsers, 68 outputs and 8 secret stores. You will use a handful. The shape they all fit into is the subject of chapter 2.

## The rule: the conveyor decides nothing, and that is why its labels decide everything

Telegraf makes no judgements. It does not decide that a temperature matters, or that a room name is worth keeping, or that one reading in a thousand can be dropped. It moves what it is told to move, in the shape it is told to move it. So:

> **Telegraf only moves measurements — it is a conveyor, not a store and not a judge. What an input plugin measures and how you tag it decides everything the database can ever answer later, and a metric with the wrong tags is wrong forever.**

Unpack that once, because later chapters keep coming back to it. Every measurement Telegraf emits is split into **tags** — labels that say where and what a reading is about, such as which host, which sensor, which room — and **fields** — the numbers themselves. The database behind Telegraf can only group, filter and compare by the tags it was given. If your sensor readings arrive tagged by sensor but not by room, no query written later, however clever, can produce "average temperature by room". The information was never carried. Worse, historical points cannot be re-tagged: the database holds what arrived, and what arrived was decided here, in the agent's config, at collection time.

That is why this guide spends a whole chapter (chapter 7) on one line of output, and why the fixture lab (chapter 8) chooses its tags on purpose and shows them in the result. The conveyor is simple. The labelling is the craft.

## Where it comes from

Telegraf is a free, open-source program written in Go, made by InfluxData, the company behind the InfluxDB time-series database. It is a single self-contained binary with no runtime to install beside it, and it runs on Linux, macOS and Windows. It pairs naturally with InfluxDB but is not tied to it: the lab in this guide sends its output to a plain file, so every claim can be checked with your own eyes, and chapter 11 names the other destinations. Where a chapter describes something the lab did not run — a real database, a system service — it says so.

Check: name the three jobs in keeping a record of a machine's week, and say which one is Telegraf's. Then say the rule out loud once. If you can do both, you have this chapter.

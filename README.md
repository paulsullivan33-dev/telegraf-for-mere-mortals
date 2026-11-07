# Telegraf for Mere Mortals

Every computer you look after is constantly reporting on
itself — how busy its processor is, how full its memory is,
how long it has been up. Almost none of that reporting is
kept. You notice a machine was struggling only while it is
struggling, and by the time you ask "was it like this
yesterday?" the answer has evaporated. **Telegraf** is the
agent that fixes that: a small program you run on each host
that gathers measurements on a timer, shapes them into a
standard form, and passes them on to a database that can
keep them.

One rule governs everything it does, and this guide states
it in chapter 1 and keeps pointing back to it: **Telegraf
only moves measurements — it is a conveyor, not a store and
not a judge. What an input plugin measures and how you tag
it decides everything the database can ever answer later,
and a metric with the wrong tags is wrong forever.**
Telegraf keeps nothing, graphs nothing, and alerts on
nothing. Its whole job is the quality of what it hands on:
the right measurements, with the right labels, arriving on
time. A reading sent without the tag that says which room
its sensor sits in can never be grouped by room later, no
matter how good the database behind it is.

The lab behind this guide ran the real thing: **Telegraf
1.40.3**, the official release file from InfluxData, unpacked
and run from the lab's own folder against a small fictional
project — a community noticeboard with three invented
sensors. Against it the lab proved a config with `--test`
before any daemon ran; ran the agent live for a measured
nine seconds while the `cpu`, `mem` and `system` inputs
produced 24 real lines of line protocol in a file; parsed a
JSON fixture so the difference between tags and fields is
visible in the output itself; renamed a field with a
processor; opened an HTTP listener on loopback port 18083
and posted a point into it with `curl`, then watched that
exact point come out the other side; fed three numbers
through an aggregator and got back one line carrying count,
minimum, maximum and mean; set gathering and flushing to
different intervals and watched the output file grow in
batches instead of a stream; and broke a config two
different ways to record the exact errors Telegraf prints.

What the lab could not do, it did not fake. Running Telegraf
as a system service, sending to a real InfluxDB, and the
hundreds of plugins the lab never enabled are described from
the tool's own help and sample configuration and labelled
documented-only. `criteria.md` keeps the full ledger of what
was run and what was only read.

## What this guide covers

- [**What Telegraf is**](what-telegraf-is.md) —
  the measurements nobody keeps, what an agent takes over,
  and the one rule
- [**The moving parts**](the-moving-parts.md) —
  inputs, parsers, processors, aggregators, the buffer, and
  outputs
- [**Installing Telegraf**](installing-telegraf.md) —
  the official release file the lab used, other routes, and
  the version check every install must pass
- [**The config file**](the-config-file.md) — TOML, the
  agent section, global tags, and generating a sample config
  instead of typing one from memory
- [**Test before you run**](test-before-you-run.md) —
  `config check`, `--test`, and `--once`: proving a config
  before a daemon ever starts
- [**Your first agent**](your-first-agent.md) — a live,
  bounded run: cpu, memory and system in, real line protocol
  out
- [**Measurements, tags and fields**](measurements-tags-and-fields.md) —
  the anatomy of one point, and why the tag side of the line
  is the part you cannot fix later
- [**Reading files and parsers**](reading-files-and-parsers.md) —
  a JSON fixture read as measurements, and what a parser
  decides
- [**Inputs that listen**](inputs-that-listen.md) — the
  HTTP listener: posting a point in with curl and watching
  it come out
- [**Processors and aggregators**](processors-and-aggregators.md) —
  renaming a field, and turning three readings into count,
  minimum, maximum and mean
- [**Outputs, buffering and flush**](outputs-and-flush.md) —
  the buffer between gathering and sending, measured in
  batches
- [**Running it for real**](running-it-for-real.md) —
  services, several hosts, secrets and updates, honestly
  labelled
- [**The neighbours**](the-neighbours.md) — InfluxDB,
  Prometheus and node_exporter, Grafana, and the other agents
- [**Limits**](limits.md) — no storage, no graphs, no
  alerts, and the tag cardinality that can sink a database
- [**Troubleshooting**](troubleshooting.md) — the plugin
  name that does not exist, the point that never arrives,
  and the output that comes in bursts
- [**Glossary**](glossary.md) — the terms, collected in one
  place

## What it doesn't cover

Storing, querying, graphing or alerting on the measurements
— that is the database's and Grafana's job, and chapter 13
says which is which. It does not teach any one database's
query language, and it does not walk through the hundreds of
input plugins one by one: it teaches the shape every plugin
fits into, proves it with a handful run for real, and shows
you the command that prints any other plugin's own sample
settings. Nothing here collects from other people's
machines: every example gathers from the reader's own host
or talks to itself on loopback.

## How to use this guide

Read chapter 1 for the rule and chapter 2 for the map of
parts; chapter 5 proves a config without running anything,
and chapter 6 runs the agent for real. Chapter 7 is the one
to read slowly before your first real deployment, not after:
the tag decisions it explains are the ones that cannot be
repaired later. The lab's configs live in
`telegraf-lab/configs/`, its fixture in
`telegraf-lab/fixtures/`, its driver scripts in
`telegraf-lab/drivers/`, and every claim's evidence in
`telegraf-lab/transcripts/`; its distilled commands are
`examples/commands.txt` and its notes
`examples/lab-notes.txt`.

---

## Part of the series

This guide is one of the [For Mere Mortals](https://paulsullivan33-dev.github.io/mere-mortals/) guides: plain-language guides to the tools programmers and makers use.

Related guides:

- [Prometheus and Grafana for Mere Mortals](https://paulsullivan33-dev.github.io/prometheus-and-grafana-for-mere-mortals/)
- [Text Processing for Mere Mortals](https://paulsullivan33-dev.github.io/text-processing-for-mere-mortals/)
- [Markdown for Mere Mortals](https://paulsullivan33-dev.github.io/markdown-for-mere-mortals/)

## License

The writing in this guide is licensed under [CC BY 4.0](https://github.com/paulsullivan33-dev/telegraf-for-mere-mortals/blob/main/LICENSE). Code examples and lab scripts are licensed under the [MIT License](https://github.com/paulsullivan33-dev/telegraf-for-mere-mortals/blob/main/LICENSE-CODE).

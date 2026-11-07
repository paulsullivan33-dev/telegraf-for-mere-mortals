# The neighbours

Outcome: you can place Telegraf among the tools that touch the same work — the databases that store, the exporters that gather for a different master, the dashboards that show — and say which job belongs to which, characterised fairly and benchmarked against none.

Chapter 1 divided the work into three jobs: collect and carry, store and answer, show and warn. Telegraf's neighbours are mostly the tools doing the *other* two jobs — not rivals so much as the rest of the sentence.

## InfluxDB: the store it was born beside

**InfluxDB** is InfluxData's time-series database: the store-and-answer job, built around the same line protocol this guide reads throughout. Telegraf can be — and often is — deployed with no InfluxDB anywhere (the lab proves the agent end to end into a file), but the pairing is the intended one, and Telegraf's InfluxDB outputs speak both current API generations. Choose it when you want the database whose native shape is the agent's native shape. Described, not run: no database was installed for this guide, and its chapters do not present the pairing as tested.

## Prometheus and node_exporter: the other collection model

**Prometheus** stores and answers too, but its collection model runs the other way: instead of agents *pushing* points to a destination, Prometheus *pulls* — it scrapes HTTP endpoints that expose current values, on its own schedule. The gatherer on each host in that world is typically **node_exporter**, a small program that exposes the host's cpu, memory, disk and system figures as one such endpoint. The honest comparison: node_exporter does a narrower job (one host's vital signs, superbly) where Telegraf is a general conveyor (hundreds of sources, several destinations, shaping in the middle); and Prometheus's pull model notices a dead host by its absence at scrape time, where a push agent's absence must be noticed by the missing data. Estates pick one model or run both for different sources; Telegraf even has outputs that expose its points for Prometheus to scrape, which tells you the border is a design choice, not a wall. Characterised from the projects' documented models; the lab ran neither.

## Grafana: the showing and warning

**Grafana** draws dashboards and raises alerts over databases — InfluxDB, Prometheus and many others. It is the third job, and naming it here settles a confusion beginners bring to Telegraf weekly: no, the agent does not make graphs, and a Telegraf install that "shows nothing" is not broken; it was never going to show anything. Agent, store, display: three installs, three jobs, one pipeline.

## The other conveyors

Telegraf is not the only carrier. **Fluent Bit** and **Vector** move logs and metrics with strong transformation pipelines of their own, and **collectd** is the older daemon whose plugin estate Telegraf's partly echoes. The fair one-line characterisations: Fluent Bit's home ground is logs, Vector's is a general observability pipeline, collectd's is a long life on small systems. All four share this guide's central shape — gather, shape, forward, store nothing — so chapter 1's rule about tags applies whichever you choose; the lab simply proves it with the conveyor it ran.

## The sources' own exporters

Last, the neighbours inside the sources themselves: many programs — databases, web servers, queues — expose their own metrics endpoints or statistics, and still need something to gather them. That gathering is an input plugin's job (Telegraf carries inputs for a long list of named programs), or a dedicated exporter's. The choice is usually estate-shaped: one agent with many inputs, or many small exporters with one model. This guide teaches the one-agent shape and does not pretend the other is wrong.

Check: for each neighbour named here, state which of chapter 1's three jobs it does. If you placed InfluxDB and Prometheus at store-and-answer, Grafana at show-and-warn, and Telegraf with Fluent Bit, Vector and collectd at collect-and-carry, the map is yours.

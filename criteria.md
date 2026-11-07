# Writing criteria for this guide

Every "for Mere Mortals" guide is written to the same nine-point
standard, so a reader who trusts one can trust the rest. Here it
is, with the verification notes for this particular guide below.

1. **Fix it first.** Reader outcomes lead, not action items: each
   chapter opens by naming the outcome it delivers, shows a check
   the reader can run to confirm they got it, and a reasonable
   reader finishes able to state what was done, what it means,
   and what to try next.
2. **Plain language.** Short sentences, everyday vocabulary,
   technical terms defined on first use. No slang, and no
   idioms that only make sense in one country — the reader may
   be translating as they go.
3. **No dead ends.** A guide never tells the reader to do
   something it cannot show them how to verify. Every claim a
   reader relies on — an install, a command, an output — is
   something this guide demonstrates or clearly labels
   documented-only below.
4. **Live-verified where it matters.** Procedures are run for
   real in the guide's lab wherever the build machine allows it,
   and the transcripts kept in the repository are the evidence.
   What could not be run is listed honestly below, never
   presented as if it had been.
5. **General audiences.** Nothing in this guide — examples,
   fixtures, names, addresses — is modelled on any particular
   reader or author's real life, network, or organisations.
   The lab's traffic is the lab talking to itself.
6. **Standalone.** A reader needs this guide, its lab, and
   nothing else. Where another guide would genuinely help, it
   is pointed to once, by name, and the chapter still completes
   without it.
7. **Honest about limits.** The limits chapter names what the
   tool cannot do: it does not store, graph, or alert — that is
   the database's and Grafana's job; tag cardinality can sink
   the database behind it, while the agent itself reports no
   problem; parsing is only as good as the pattern you wrote,
   and a source that drifts quietly stops producing the fields
   you expect; and an agent on every host is another thing to
   keep updated on every host, with defaults that move between
   versions.
8. **The one rule is in the text, early.** Chapter 1 and the
   README state the rule plainly — *Telegraf only moves
   measurements: it is a conveyor, not a store and not a judge,
   and what an input plugin measures and how you tag it decides
   everything the database can ever answer later, because a
   metric with the wrong tags is wrong forever* — before any
   procedure depends on it, and later chapters point back to it
   where the rule bites: the tags a parser chooses, the
   originals an aggregator drops, and the history no query can
   repair.
9. **Builds clean.** The site builds with MkDocs in strict mode
   with no warnings, and a fresh reader following the chapters
   in order reaches the stated outcome of each.

## Verification notes for this guide

The build machine is an Ubuntu 24.04 sandbox. Telegraf
**1.40.3** was the official release file from InfluxData's
download site (`telegraf-1.40.3_linux_amd64.tar.gz`, 84 MB,
SHA-256
cbb95c43303db6e75e129a4eb8888ab1468009e61f6615e64a1cb82f50b0f4ce),
unpacked into the lab's scratch folder and run from there
rather than installed system-wide; no package was installed
and no service was started. The lab is in `telegraf-lab/`: a
fictional noticeboard project — three invented sensors in a
JSON fixture (`fixtures/readings.json`), reporting for
invented rooms on the invented host `boardwalk-01` — six
configs (`configs/`), one driver script per test (`drivers/`),
and the captured evidence (`transcripts/`). Every run started
Telegraf from the `telegraf-lab/` folder, because the configs'
paths are relative to it. Generated output files went to
`telegraf-lab/outputs/`, which is runtime scratch, not
evidence; the transcripts quote them in full where it matters.
All listeners bound 127.0.0.1, on the lab's assigned port
18083, and every live run was bounded by `timeout` and stopped
by it.

Run for real, with transcripts as evidence:

- Version and help (t00): `telegraf version` printed
  `Telegraf 1.40.3 (git: HEAD@41b45388)`; the full 49-line
  `--help` was captured before anything else was trusted; a
  sample config was generated with `telegraf config create`
  and one plugin's settings printed with `telegraf --usage
  cpu`. The startup banner's own catalogue count: 244 inputs,
  9 aggregators, 35 processors, 26 parsers, 68 outputs,
  8 secret stores.
- Prove-before-run (t01): `telegraf config check --config
  configs/system.conf` exited 0. `--test` gathered once and
  printed exactly 5 points (1 cpu, 1 mem, 3 system — the
  system plugin emits load, uptime and uptime-format as
  separate points) with the log line `Outputs are not used in
  testing mode!`. `--once` wrote the same 5 points through
  the real file output and shut down cleanly.
- The live agent (t02): `configs/system.conf` (gather 2s,
  flush 2s) ran for 9 seconds under `timeout` and wrote
  **24 lines** to the file output — 4 cpu, 5 mem, 15 system —
  every line carrying the `host=boardwalk-01`,
  `project=noticeboard` and `site=pier-a` tags, ending with
  the agent's shutdown flush lines.
- The fixture and the parser (t03): the JSON fixture's three
  objects became three `noticeboard_reading` points. The
  config's `tag_keys` promoted `sensor` and `room` to tags;
  every other number stayed a field with its JSON type; the
  rename processor turned `temperature_c` into `temp_c` in
  both the `--test` output and, via `--once`, the real file
  output. The door-counter point, which has no temperature
  in the fixture, has no temperature field in the output.
- The listener (t04): `inputs.http_listener_v2` on
  127.0.0.1:18083 logged `Listening on 127.0.0.1:18083`.
  A `curl` POST of one line-protocol point returned
  **HTTP 204** and the point appeared in the file output
  verbatim except for the added `host=boardwalk-01` tag,
  keeping its posted timestamp. A malformed POST returned
  **HTTP 400** and reached nothing.
- The aggregator (t05): with `basicstats` set to a 5s period
  and `drop_original = true`, three posted values (10, 20, 30)
  produced exactly one output line —
  `value_max=30,value_mean=20,value_count=3,value_min=10` —
  and none of the originals appeared. The rename processor
  (t03) is the processor evidence; no other processor was run.
- Buffering and flush (t06): gather 1s, flush 3s, polling the
  output file once a second for 11 seconds showed flat counts
  between flushes and jumps at them — 0 lines through t=+3s,
  2 at t=+4s, 6 at t=+7s, 9 at t=+10s — and a final count of
  10 after the shutdown flush delivered the last buffered
  point.
- The broken configs (t07): a config naming the nonexistent
  input `cpuu` failed with `E! loading config file
  configs/broken.conf failed: error parsing cpuu, undefined
  but requested input: cpuu`, exit 1. A config with a TOML
  syntax error failed with `error parsing data: line 2:
  invalid TOML syntax`, exit 1.

Documented only — described from the tool's own help, usage
text, generated sample config and package contents, not run,
and the text does not claim otherwise:

- Installation routes other than the release tarball the lab
  used (the .deb/.rpm packages, InfluxData's package
  repositories, Windows and macOS builds), and everything
  service-related: the systemd unit, the dedicated `telegraf`
  user, `/etc/telegraf` config locations, and running under a
  scheduler via `--once`.
- Writing to any real destination: the InfluxDB, HTTP, Kafka
  and Prometheus outputs and all other outputs but `file`;
  buffer overflow and retry behaviour past
  `metric_buffer_limit` is stated from the settings, not
  demonstrated.
- Every input plugin except `cpu`, `mem`, `system`, `file`
  and `http_listener_v2`; `inputs.tail` and the `grok` and
  `csv` parsers are characterised, not run. The listener's
  authentication and TLS settings were not configured.
- Every processor except `rename` and every aggregator except
  `basicstats`; multiple config files and `--config-directory`
  merging; `--test-wait` with service inputs.
- Secrets handling: environment-variable substitution and the
  8 secret stores. The neighbouring tools in chapter 13 are
  characterised, not benchmarked, and none was installed.

Fixtures are this guide's own and deliberately generic: an
invented noticeboard, three invented sensors, invented rooms,
and an invented hostname. No example is modelled on any real
person, network, service or organisation. Two honest wrinkles
are kept in the record: Telegraf 1.40.3 prints two startup
warnings in every transcript (strict environment handling
becoming the default, and the `skip_processors_after_aggregators`
default changing in v1.41.0) — both are quoted in the guide
rather than edited out of the evidence; and the live counts
in t02 (4/5/15) are not the tidy multiples a diagram would
draw, because real timers are like that, and chapter 6 says
so instead of rounding them.

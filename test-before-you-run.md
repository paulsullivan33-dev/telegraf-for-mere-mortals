# Test before you run

Outcome: three ways to prove a config — a check, a dry gather, and a single real gather — before any long-running agent is started, with the lab's real numbers for each.

An agent is a program you intend to leave running. The worst time to discover a config mistake is after it has been running, wrongly, for a week — above all a labelling mistake, which chapter 1 warns cannot be repaired in the stored history. Telegraf's answer is a test mode that is genuinely a test: it gathers for real and shows you the exact points that *would* be sent, then exits.

## Step one: `config check`

```
telegraf config check --config configs/system.conf
```

asks only "does this file load, and are its settings sane?" It prints the startup warnings and no measurements, and exits 0 on the lab's good config (transcript `telegraf-lab/transcripts/t01-test-and-once.txt`). Note the spelling: the `--config` comes *after* the `check` subcommand. Chapter 15 shows what this step reports when a config names a plugin that does not exist.

## Step two: `--test`, the dry gather

```
telegraf --config configs/system.conf --test
```

loads the config, runs every input **once**, passes the points through processors and aggregators, prints them to the screen in line protocol, and exits — without touching any output. Telegraf says so itself in the log: `W! Outputs are not used in testing mode!`. Lines that are measurements (as opposed to log lines) begin with `>`.

The lab's run produced exactly five points. Three come from the `system` input alone — load averages, uptime as a number, and uptime as a formatted string are three separate points from one plugin, which surprises everyone once:

```
> system,host=boardwalk-01,project=noticeboard,site=pier-a load1=0.61,load15=0.67,load5=0.89,n_cpus=4i,n_physical_cpus=4i,n_unique_users=0i,n_users=0i 1794088251000000000
> system,host=boardwalk-01,project=noticeboard,site=pier-a uptime=34717u 1794088251000000000
```

plus one `mem` point (a long line of memory counters, quoted in chapter 7) and one `cpu` point. Counts from the transcript: 1 cpu, 1 mem, 3 system. Read your `--test` output the way chapter 1 teaches: the tags before the first space are the labels your database will live with. If a tag is missing here, it will be missing forever. `--test` is also where chapter 8 verifies a parser and chapter 10 verifies a rename, before either is trusted with a live run.

Two honest details. Service inputs — listeners like chapter 9's — do not gather on a timer, so in test mode they need `--test-wait` seconds to receive anything; the lab tested its listener live instead, and says so in chapter 9. And aggregators in test mode only summarise what a single gather gives them, which for a five-second window may be nothing at all: the lab's aggregation evidence is likewise a live run (chapter 10), not a test-mode claim.

## Step three: `--once`, the single real gather

```
telegraf --config configs/system.conf --once
```

runs one gather and this time *does* write through the real outputs, then shuts down cleanly. The lab's run wrote exactly 5 lines to `outputs/system.lp` — the same 1 cpu, 1 mem, 3 system as the dry gather — and logged the shutdown you will also see at the end of every stopped agent:

```
I! [agent] Hang on, flushing any cached metrics before shutdown
I! [agent] Stopping running outputs
```

`--once` is more than a test. It is a legitimate way to run Telegraf under a scheduler — gather, send, exit, on your system's timetable rather than the agent's — though the lab used it only as the final proof before chapter 6's live run, and running it under a scheduler is documented-only here.

The order matters and is the whole chapter: **check, test, once, run.** Each step costs seconds and catches a different class of mistake — a file that does not load, points that are shaped wrong, an output that cannot be written, and only then a daemon left alone with its work.

Check: run all three against `telegraf-lab/configs/system.conf` from the `telegraf-lab/` folder. You have this chapter when `config check` exits 0, `--test` prints five points beginning with `>`, and `--once` leaves exactly five lines in `outputs/system.lp`.

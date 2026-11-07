# Your first agent

Outcome: a real agent, run live for a measured nine seconds against the config you have already proved, producing real line protocol you can read — and stopped, deliberately, by you.

## The run

Chapter 5 ended with proof. This chapter trusts it. From the `telegraf-lab/` folder, the lab ran:

```
timeout 9 telegraf --config configs/system.conf
```

The `timeout` wrapper is the lab's measuring instrument, not part of Telegraf: it guarantees the run lasts exactly nine seconds and then stops the agent, so the counts below mean something. On your own machine you would start the same command without it and stop it with Ctrl-C when you are done; the agent treats both the same way, flushing what it holds before it exits (chapter 11 shows that final flush happening).

The startup log is worth reading once, slowly (transcript `telegraf-lab/transcripts/t02-live-system.txt`):

```
I! Loading config: configs/system.conf
I! Starting Telegraf 1.40.3 brought to you by InfluxData the makers of InfluxDB
I! Available plugins: 244 inputs, 9 aggregators, 35 processors, 26 parsers, 68 outputs, 8 secret stores
I! Loaded inputs: cpu mem system
I! Loaded outputs: file
I! Tags enabled: host=boardwalk-01 project=noticeboard site=pier-a
I! [agent] Config: Interval:2s, Quiet:false, Hostname:"boardwalk-01", Flush Interval:2s
```

Every later surprise can be checked against these lines: which plugins actually loaded, which tags are switched on, and which intervals the agent is really using. When a point arrives without a tag you expected, this block — not the database — is the first place to look.

## The result

Nine seconds at a two-second interval produced **24 lines** in `outputs/system.lp`:

```
      4 cpu
      5 mem
     15 system
```

The arithmetic is the lesson. Each gather produces five points — one `cpu`, one `mem`, three `system` (chapter 5) — and the agent gathered a little over four times, with the first `system` points landing a moment before the first full `cpu` reading, which is why the counts are 4, 5 and 15 rather than a tidy 5, 5, 15. Real agents gathering on timers behave like this: close to the timetable, never exactly on it. A real line from the file, timestamp and all:

```
cpu,cpu=cpu-total,host=boardwalk-01,project=noticeboard,site=pier-a usage_active=53.96...,usage_idle=46.03...,usage_user=36.63... 1794088252000000000
```

(The full values are in the transcript; the line is trimmed here only for the page. Chapter 7 takes a line like this apart piece by piece.)

Two things this run proves that `--test` could not. The output side works end to end: the file was created, written, and grew across several flushes, not in one dump at the end. And the agent is a *resident* program: left alone it would still be gathering now. There is no "run until done" for a conveyor — the load on the machine is small (a gather every two seconds of three cheap inputs), but chapter 14 counts the honest cost of an agent on every host, and chapter 12 covers the service machinery that keeps one alive across logins and reboots.

## Stopping is part of the job

The transcript ends the way every healthy agent ends:

```
I! [agent] Hang on, flushing any cached metrics before shutdown
I! [agent] Stopping running outputs
```

The agent does not simply vanish mid-buffer; it sends what it is holding, then stops. `timeout` reported exit code 124, which is `timeout`'s own way of saying "I stopped a program that was still running" — here, that is success, and the driver script in the lab says so in its own output so nobody misreads it later.

Check: repeat the lab run exactly. You have this chapter when `outputs/system.lp` holds roughly two dozen lines after nine seconds, every line begins with `cpu`, `mem` or `system`, and every line carries `host=boardwalk-01`, `project=noticeboard` and `site=pier-a`.

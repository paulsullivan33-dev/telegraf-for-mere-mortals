# The config file

Outcome: you can read a Telegraf config top to bottom and say what each block will do — and you can generate a correct starting config instead of typing one from memory and hoping.

## TOML, briefly

Telegraf's config is written in **TOML**, a plain-text format for settings. You need only three shapes of it for everything in this guide:

- `[name]` — a section with single settings, like `[agent]`.
- `[[inputs.cpu]]` — one entry in a list. The doubled brackets mean "another one of these": two `[[inputs.file]]` blocks are two file inputs.
- `key = value` — a setting. Strings go in quotes (`"2s"`), numbers and true/false do not.

Comments start with `#`. Durations are written as quoted spans: `"2s"`, `"500ms"`, `"1m"`.

## The lab's first config, read properly

Here is `telegraf-lab/configs/system.conf` — the config chapters 5 and 6 run — with the reading notes inline:

```toml
[agent]
  interval = "2s"          # gather from every input every 2 seconds
  flush_interval = "2s"    # send to every output every 2 seconds
  round_interval = false   # do not align gathers to the clock
  hostname = "boardwalk-01"  # the host tag on every point
  omit_hostname = false

[global_tags]
  project = "noticeboard"  # tags added to every point, from every input
  site = "pier-a"

[[inputs.cpu]]             # one input: the processor
  percpu = false
  totalcpu = true
  collect_cpu_time = false
  report_active = true

[[inputs.mem]]              # a second input: memory, all defaults

[[inputs.system]]          # a third: load averages and uptime

[[outputs.file]]           # one output: a plain file
  files = ["outputs/system.lp"]
  data_format = "influx"
```

Three things to notice. First, **the hostname is a tag, not a fact the agent discovers and keeps private**: setting `hostname` decides the value of the `host` tag on every point. The lab sets a fictional name, `boardwalk-01`, because the lab's machine is a shared sandbox and its real name would mean nothing to a reader; on your own fleet, leaving the default (the machine's real name) is the normal choice. Second, **global tags are the one rule in config form**: `project` and `site` here will ride on every point from every input — including inputs added months later — which is exactly the sort of decision chapter 1 says to make deliberately. Third, **paths are relative to where you start the agent**: `outputs/system.lp` means "in the folder Telegraf was launched from", and every lab driver starts Telegraf from the `telegraf-lab/` folder for that reason.

## Do not type configs from memory: generate, then cut down

A full sample config for a plugin-driven tool is enormous — the `cpu` input alone has a page of settings, almost all of them commented defaults. Telegraf generates its own samples, which is the reliable way to start:

```
telegraf config create --input-filter cpu:mem --output-filter file
```

prints a complete, valid config containing exactly the plugins you named, each with its documented settings (transcript t00 captures the first lines; the command's own header even reminds you to test with `-test`). The working method is: generate with the filters naming the plugins you want, delete what you do not need, change the few values you mean to change, then prove the result with chapter 5's tools before running it.

Each plugin also documents itself alone:

```
telegraf --usage cpu
```

prints that plugin's sample block, which is how you answer "what is the setting called?" without leaving the terminal. Option spellings from `--usage` on *your* binary outrank any guide, this one included.

## Several files, one agent

Documented only — the lab ran single files throughout: Telegraf accepts `--config` more than once and a `--config-directory` of further `.conf` files, merging them into one agent. The pattern real deployments grow into is one main file for `[agent]` and global tags, plus one small file per source. The merge does not change the model: the agent still runs one loop, and chapter 5's `--test` still proves the whole merged result before anything runs.

Check: open `telegraf-lab/configs/system.conf` and, without looking back, name the gather interval, the flush interval, the two global tags, and the three inputs. Then run `telegraf config create --input-filter cpu --output-filter file` and find `interval` inside what it prints. If you can do both, you can read any config this guide shows you.

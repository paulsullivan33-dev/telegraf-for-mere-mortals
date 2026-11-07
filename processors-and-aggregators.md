# Processors and aggregators

Outcome: two ways to change measurements on the conveyor, each proved with before-and-after numbers — a processor that renames a field the moment a point passes, and an aggregator that turns three readings into one summary line.

## Processors: change it as it passes

A **processor** sees each point once, as it flows from inputs towards outputs, and can rename, convert, add, drop or filter before the point moves on. It answers immediately; it holds nothing.

The lab's fixture config (chapter 8) carries the smallest useful processor:

```toml
[[processors.rename]]
  [[processors.rename.replace]]
    field = "temperature_c"
    dest = "temp_c"
```

Before: the fixture JSON says `temperature_c`, and without the processor the field would keep that name. After: every `--test` and `--once` line in transcript t03 carries `temp_c=21.5` and no line anywhere carries `temperature_c`. The rename is total and silent, which is both its use and its warning: a processor renames for every consumer downstream, including the database schema those consumers already query. Rename on day one, as the lab does, or plan the rename like the breaking change it is.

Why rename at all? Names are conventions — shorter, consistent, matching what other sources already call the same quantity — and the processor is the one place a mixed estate of sources can be made to agree before anything is stored. The other 34 processors in the binary (converting types, parsing strings, applying rules written in the Starlark language, and more) follow the same shape and are named here, not run: the lab verified the category with `rename`, and `telegraf --usage <name>` gives any other processor's own settings.

One ordering fact from the tool's own startup warnings, worth knowing before it surprises you: processors also run *after* aggregators by default in this version — the points an aggregator emits can be processed too — and Telegraf 1.40.3 warns that this default (`skip_processors_after_aggregators`) is scheduled to change in v1.41.0. If your pipeline depends on the order, set the option explicitly rather than inheriting a moving default.

## Aggregators: wait, then summarise

An **aggregator** is the opposite temperament: it holds points over a **period**, and when the window closes it emits a summary point and (depending on settings) lets the originals pass or drops them.

The lab's `telegraf-lab/configs/stats.conf` puts `basicstats` between chapter 9's listener and the file output:

```toml
[[aggregators.basicstats]]
  period = "5s"
  drop_original = true
  stats = ["count", "min", "max", "mean"]
```

The driver (transcript `telegraf-lab/transcripts/t05-basicstats.txt`) posted three readings within one window — `hall_temp,sensor=temp-north value=10`, then 20, then 30, each accepted with HTTP 204 — and waited for the five-second window to close and flush. The file output held exactly one line:

```
hall_temp,host=boardwalk-01,sensor=temp-north value_max=30,value_mean=20,value_count=3,value_min=10 1794088281000000000
```

Everything in that line rewards a slow read. The measurement name and tags survived unchanged — the summary is *about* the same sensor as the originals. The fields are new: each original field name (`value`) gained a suffix per statistic (`value_mean`, `value_count`, `value_min`, `value_max`), and the numbers are exactly right for 10, 20 and 30: mean 20, count 3, minimum 10, maximum 30. And because `drop_original = true`, none of the three original points appears anywhere in the output. Aggregation here is a *replacement*, chosen on purpose: the destination wanted the summary, not the samples.

That choice is the chapter in miniature, and it is chapter 1's rule in a third costume. Dropping originals saves storage and loses detail — permanently, since the conveyor keeps no copy. Letting them pass (`drop_original = false`) costs storage and keeps the raw record beside its summaries. Neither is the tool's decision; it is yours, made in a config line, provable in a transcript. Other aggregators (a histogram, a final-value keeper, a merge) share the shape — a window, a rule, the same pass-or-drop question — and are documented-only here.

Check: repeat the t05 run. You have this chapter when three posted values produce one output line whose `value_mean`, `value_count`, `value_min` and `value_max` you can verify with pencil arithmetic — and when you can state, from the config, why the three originals are nowhere in the file.

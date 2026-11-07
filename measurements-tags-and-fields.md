# Measurements, tags and fields

Outcome: you can take one line of line protocol apart into its four pieces, say which piece does what job, and explain — with the lab's own lines as evidence — why the tag side of the line is decided at collection time and can never be repaired later.

## One line, four pieces

This is a real point from the lab's live run (transcript t02), trimmed in the middle for the page:

```
cpu,cpu=cpu-total,host=boardwalk-01,project=noticeboard,site=pier-a usage_active=53.96,usage_idle=46.03,usage_user=36.63 1794088252000000000
```

Reading left to right:

1. **The measurement name** — `cpu`. The broad subject: what kind of thing this point is about. Points that share a name are stored and queried together.
2. **The tags** — `cpu=cpu-total,host=boardwalk-01,project=noticeboard,site=pier-a`. The comma-separated labels before the first space. Tags are always text, they describe *where and what* the point is about, and they are the part the database indexes so it can find points quickly.
3. **The fields** — `usage_active=53.96,usage_idle=46.03,...`. The values after the space. Fields are the measurements themselves, and they carry types: a bare number is a float, a number with an `i` suffix is an integer (`n_cpus=4i`), a `u` suffix marks an unsigned integer (`uptime=34717u`), quotes mark a string (`uptime_format=" 9:38"`). All four spellings appear in the lab's own output, in chapters 5 and 6.
4. **The timestamp** — the long number at the end, nanoseconds since 1970. Every point has one. When an input reads a source that carries its own time, the parser can take the time from the data (chapter 8 names the settings); otherwise the agent stamps the point when it gathers it.

That format is **line protocol**, the text shape InfluxDB made common and the `influx` data format in Telegraf reads and writes. It is worth learning to read because it is the one format every part of this guide can show you directly — test output, file output, and what you post to a listener are all the same shape.

## Tags answer "which", fields answer "how much"

The working rule: **if you will ever want to filter or group by it, it belongs in a tag; if you will ever want to average, total or graph it, it belongs in a field.** "Which host, which sensor, which room" — tags. "Temperature, humidity, count of opens" — fields.

The lab's fixture makes the distinction visible in a single line (chapter 8 proves it end to end):

```
noticeboard_reading,host=boardwalk-01,room=hall-a,sensor=temp-north battery_pct=87,humidity_pct=44,temp_c=21.5 1794088263000000000
```

`room=hall-a` and `sensor=temp-north` are tags: they say which reading this is. `temp_c=21.5` is a field: it is the number you would average. Swap their roles in your head and the damage is immediate — a database can average a field across rooms, but it cannot group by a value buried in a field, and it cannot sensibly average a tag.

## Why tags are forever, and why more is not better

Two consequences follow, and both are the one rule (chapter 1) wearing work clothes.

**A wrong or missing tag cannot be fixed later.** The database stores the point as it arrived. The lab's readings say `room=hall-a` because the fixture's config chose `room` as a tag key (chapter 8). Had it not, a year of readings would exist with no room information at all, and no query, migration or apology could add it. Choose tags before the agent runs, prove them with `--test` (chapter 5), and treat a tag change as a serious event: points before and after the change will not group together cleanly.

**Every distinct tag combination is a separate series to the database.** A **series** is one measurement with one exact set of tag values. Host × sensor × room gives a manageable number of series. But put something unbounded in a tag — a request ID, a full timestamp, a user name from a busy service — and the series multiply without limit. This is **tag cardinality**, and it is the classic way a small agent makes a large database fall over: the agent looks innocent, the points look fine, and the index behind them grows until queries crawl. Chapter 14 returns to this as a limit of the whole arrangement. The defence is the same working rule: tags are for a *small, known set* of "which" answers. If the set of possible values is not one you can list, it is not a tag.

Field values, by contrast, are not indexed the same way, which is why "how much" belongs there even when the values repeat — and why a status word you only ever count, never average, still usually belongs in a tag if its values are few ("ok", "warn"), or in a string field if they are many. The lab's fixture keeps status out of its readings entirely; the distinction above is stated here as the guide's rule of thumb, not as a lab measurement.

Check: take any line from `telegraf-lab/transcripts/t02-live-system.txt` and label its four pieces. Then answer for the fixture line above: which values could you average, and which could you group by? If your answers match the field and tag lists respectively, you have this chapter.

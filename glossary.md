# Glossary

The terms, collected in one place. Each is defined the way this guide uses it.

**Agent** — The running Telegraf program: the timer and traffic controller that runs the gather-shape-flush loop, configured by the `[agent]` section.

**Aggregator** — A plugin that holds points over a period and emits a summary — `basicstats` producing count, minimum, maximum and mean, for example. Unlike a processor, it must wait for its window to close.

**Buffer** — The in-memory waiting room where gathered points sit between gathering and the next flush. Finite, lost on a crash, and flushed one last time on a clean shutdown.

**Cardinality** — The number of distinct series a tag set creates. A tag with unbounded values makes cardinality explode, which can sink the database behind the agent.

**Data format** — The named parser or serialiser a plugin uses — `influx`, `json`, `csv`, `grok` and others. Inputs parse with it; outputs write with it.

**Drop original** — An aggregator setting (`drop_original`): when true, the summarised points are consumed and only the summary is emitted.

**Field** — A measured value on a point: the "how much". Fields carry types — float, integer (`i`), unsigned (`u`), string, boolean — and are what queries average and total.

**Flush** — One sending of everything in the buffer to the outputs, on the `flush_interval` clock, and once more at clean shutdown.

**Gather** — One round of asking every polled input for its measurements, on the `interval` clock.

**Global tags** — Tags defined once in the config and stamped on every point from every input — including inputs added later.

**Host tag** — The `host=<name>` tag the agent adds to every point, from the machine name or the config's `hostname` setting.

**Input plugin** — A gatherer for one kind of source: the host itself, a file, a program, a listener. Telegraf 1.40.3 carries 244.

**Line protocol** — The text shape of a point: measurement name, comma-joined tags, a space, comma-joined fields, a timestamp in nanoseconds. The `influx` data format.

**Measurement** — The named subject of a point — `cpu`, `mem`, `noticeboard_reading`. Points sharing a name are stored and queried together.

**Output plugin** — A destination: a file, a database, a queue, an HTTP endpoint. Points flow to every configured output.

**Parser** — The part that turns a source's text (JSON, CSV, log lines, line protocol) into measurements, deciding which pieces become tags and which become fields.

**Point** — One measurement at one moment: a name, a tag set, a field set, a timestamp. The unit the whole tool is built from.

**Processor** — A plugin that changes each point as it passes — renaming, converting, dropping — answering immediately and holding nothing.

**Series** — One measurement with one exact set of tag values, as the database stores it. Grouping and filtering work series by series.

**Service input** — An input that listens instead of polling: it opens a port or subscribes, and turns arrivals into points as they come — `http_listener_v2`, for example.

**Tag** — A text label on a point saying where and what it is about: the "which". Tags are indexed by the database, chosen at collection time, and cannot be added to points already stored.

**Tag key** — In a parser's settings, a source key promoted to a tag (`tag_keys` in the JSON parser, `csv_tag_columns` in the CSV parser).

**Test mode** — `telegraf --test`: one real gather, printed instead of sent, then exit. The middle step of the check, test, once, run ladder.

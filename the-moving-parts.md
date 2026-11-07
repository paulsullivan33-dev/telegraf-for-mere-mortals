# The moving parts

Outcome: a map of the six parts inside every running agent, so that when a later chapter names a behaviour — a parsed field, a dropped original, a batch arriving late — you know which part produced it and which config block steers it.

## The agent

At the centre sits the **agent** itself: the timer and the traffic controller. Its config block, `[agent]`, holds the settings every plugin shares — how often to gather (`interval`), how often to send (`flush_interval`), and what name to stamp on every point as the `host` tag. Chapter 4 takes this block apart. The agent owns no measurements of its own; it runs the loop that moves measurements through the five parts below.

## Inputs

An **input plugin** is a gatherer. Each one knows how to read one kind of source: `cpu`, `mem` and `system` read the host itself; `file` and `tail` read files; `http_listener_v2` opens a port and receives; hundreds of others read particular programs and services. Most inputs are **polled** — the agent wakes them each interval. A few are **service inputs** — they listen continuously and accept whatever arrives, whenever it arrives. Chapter 9's listener is one.

An input produces measurements in Telegraf's shared shape: a measurement name, a set of tags, a set of fields, and a timestamp. If the source does not naturally speak that shape — a log file, a CSV export, a JSON document — a parser does the translation, next.

## Parsers

A **parser** turns text into measurements. The lab's binary carries 26 of them. The plainest is `influx`, which reads line protocol — the format Telegraf itself writes, and the subject of chapter 7. Others read JSON, CSV, and log lines matched against patterns (the `grok` parser). Choosing a parser means deciding, explicitly, which pieces of the text become tags and which become fields — the one rule from chapter 1, arriving in its working clothes. Chapter 8 does this for real with a JSON fixture.

## Processors

A **processor** changes a measurement as it passes: renaming a field, adding a tag, converting a value, dropping a point that fails a test. Processors see points one at a time and answer immediately. The lab runs one: a `rename` processor that turns the field `temperature_c` into `temp_c`, visible in the output of chapter 8 and explained in chapter 10.

## Aggregators

An **aggregator** watches measurements over a window of time and emits a summary: the count, minimum, maximum and mean of what passed through, for example. Unlike a processor, an aggregator must wait — a mean does not exist until the window closes. The lab runs `basicstats` over a five-second window and gets back one line summarising three posted readings (chapter 10). Whether the original points pass through as well is a setting, and the lab sets it to drop them, so the summary is the only thing that comes out.

## The buffer and the outputs

Gathered measurements do not leave the moment they arrive. They wait in a **buffer** until the agent's flush interval sends them on — which is why output arrives in batches, a behaviour chapter 11 measures rather than asserts. If an output fails, the buffer is also what holds points for a retry, up to a size limit you can set; past that limit, the oldest points are dropped, and the agent says so in its log.

An **output plugin** is a destination: the lab uses `file`, which writes line protocol to a plain file you can read. Others write to databases, queues and HTTP endpoints. One honest consequence of the moving-parts picture: the agent can run several inputs and several outputs at once, and the same points flow to all of them.

Check: name the six parts in the order a measurement meets them — input, parser (if the source needs one), processor, aggregator, buffer, output — and say which part must wait for time to pass before it can answer. If you can, the rest of the guide has somewhere to hang.

# Outputs, buffering and flush

Outcome: you understand where measurements wait between being gathered and being sent, you have watched output arrive in batches whose timing matches the config, and you know what happens to the buffer when an agent stops or an output fails.

## Gathering and sending are different clocks

Beginners expect a pipeline to flow like water. Telegraf flows like a bucket brigade with two rhythms: inputs **gather** every `interval`, and outputs **send** everything waiting every `flush_interval`. Between the two, points sit in the agent's **buffer**. Set the intervals differently and the difference is visible — which the lab did on purpose.

`telegraf-lab/configs/flush.conf` gathers `cpu` every **1 second** and flushes every **3 seconds**. The driver ran it for 11 seconds, counting the lines in the output file once a second (transcript `telegraf-lab/transcripts/t06-flush-buffer.txt`):

```
t=+0 s   lines: 0
t=+3 s   lines: 0
t=+4 s   lines: 2
t=+7 s   lines: 6
t=+10 s  lines: 9
final line count after shutdown: 10
```

The file does not grow steadily; it **jumps** — nothing for the first seconds, then a batch, a pause, a larger batch. The counts are not perfectly regular (2, then 4 more, then 3 more) because gathering and flushing are two timers started at slightly different moments, and the first `cpu` reading takes a moment to compute. The shape is the proof: output arrives in flush-sized batches, and at any instant the newest measurements are the ones still in the buffer, not yet in the file. Anyone who has stared at a database wondering why the last few seconds are missing has met this chapter's subject in the wild; the missing seconds were in a buffer, on a timer, working as configured.

The defaults make the same point at a calmer scale: Telegraf's generated sample config gathers and flushes every 10 seconds, so a default agent's freshest data can be up to a flush behind reality — by design, because sending in batches is cheaper than sending point by point.

## When the agent stops, the buffer is not abandoned

Chapter 6's closing lines return here as evidence:

```
I! [agent] Hang on, flushing any cached metrics before shutdown
```

The lab's flush run ended with 9 lines visible at t=+10 and a final count of **10**: the last gathered point was still buffered when the stop arrived, and the shutdown flush delivered it rather than dropping it. A stopped agent, stopped properly (Ctrl-C, a service stop, `timeout`'s signal), hands over what it holds. A killed or crashed agent cannot — one more reason the buffer is a waiting room, not a store, and chapter 1's "not a store" is a literal description.

## When the output cannot take it

Documented from the agent's own settings, with the mechanism visible in everything the lab did run: if an output write fails — a database down, a network gone — undelivered points stay in the buffer for the next flush to retry, up to `metric_buffer_limit` (10,000 points per output in the generated sample's default). Past the limit, the oldest points are dropped and the agent logs it. The lab did not break its file output to demonstrate the overflow, and does not claim to have; the file output it used is also the simplest of the 68 outputs in the binary.

## Choosing an output

The lab used `outputs.file` throughout because a file can be read back and quoted — the right output for learning, and a legitimate one for debugging a pipeline before a database is involved. The destinations real deployments use are named here, characterised and not run: **InfluxDB** (the natural home for line protocol, in its two current API generations), **HTTP** outputs that post line protocol or JSON to an endpoint, **Kafka** and other queues for handing points to a stream, **Prometheus-compatible** outputs that expose points for scraping, and file-like sinks in other formats (CSV, JSON). The config shape never changes: a `[[outputs.<name>]]` block, an address, a `data_format`, and the same buffer in front of it. Whatever you choose, chapter 5's discipline still applies — prove the pipeline against a file first, where you can see the actual lines, then swap the output block and prove it again with `--once`.

Check: run the lab's t06 driver. You have this chapter when your counts stay flat between flushes and jump at them, your final count after shutdown is one more than the last mid-run count, and you can say where the newest point is during the pause. (In the buffer. It is always in the buffer.)

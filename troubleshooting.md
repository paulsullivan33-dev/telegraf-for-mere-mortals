# Troubleshooting

Outcome: the surprises every Telegraf user meets once, each with the check that names it. The first two entries quote errors the lab produced on purpose; the rest follow from behaviours the lab measured, and the fix is a chapter that already exists — this page is the index of mishaps.

## "Undefined but requested input"

The lab's deliberately broken config names a plugin that does not exist — `[[inputs.cpuu]]`, one letter too many — and Telegraf refuses to start, in these exact words (transcript `telegraf-lab/transcripts/t07-broken-config.txt`):

```
E! loading config file configs/broken.conf failed: error parsing cpuu, undefined but requested input: cpuu
```

Exit code 1, no gather, no partial run. The same failure greets any misspelled plugin or output name, and the check is the one from chapter 5: `telegraf config check --config <file>` before anything is restarted, and `telegraf --usage <name>` to get the spelling the binary itself expects.

The transcript's second act is the format error in its even plainer form. A config missing a bracket on `[agent]` fails with:

```
E! loading config file outputs/broken-toml.conf failed: error parsing data: line 2: invalid TOML syntax
```

Line number given, cause given. TOML errors are the kindest kind: they stop everything, immediately, before a bad config can do a week of quiet damage.

## "It runs, but nothing arrives"

Work the pipeline in the order a point travels it. **Did the input gather?** Prove the config in isolation: `--test` (chapter 5). No point there means the problem is the input, its source, or its permissions — under a service, remember the `telegraf` user is not you (chapter 12). **Did the point survive shaping?** An aggregator with `drop_original = true` replaces points rather than adding to them (chapter 10); a processor can rename the field you are looking for. **Is it still in the buffer?** Output appears at the flush interval, not at the gather (chapter 11); "missing" data that is seconds old is usually buffered data. **Did the output accept it?** Read the agent's own log around a flush: rejected points and failed writes are reported there, and a buffer that fills past its limit drops the *oldest* points, which the log also says.

## "The listener returns 400"

Your line is not line protocol. Chapter 9's lab posted `this is not line protocol` on purpose and got HTTP 400, while the well-formed point got 204. Check the shape against chapter 7: measurement name, tags comma-joined with no spaces, a space, fields, and integers carrying their `i`. The other listener answers: 204 is success, and silence at the port at all means the agent is not running or is bound somewhere else — its log prints the `Listening on` line at startup, and that line is the evidence to look for first.

## "The data comes in bursts"

It is supposed to. Gather and flush are different clocks (chapter 11): with a one-second gather and a three-second flush, the lab's output file sat flat and then jumped — 0 lines, then 2, then 6, then 9. Bursts at roughly the flush interval are health, not trouble. Bursts much rarer than that mean the flush is failing and retrying, which the agent's log reports; fix the destination, not the timers.

## "There are two of everything"

Two points where one was expected usually means two agents — a service instance and a forgotten foreground run from a terminal, both reading the same sources and writing the same destination. Check the process list before blaming the config. A cousin of the same mishap: the `system` input emits three points per gather (chapter 5), which is one input behaving as documented, not a duplication.

## "The history before and after does not line up"

A tag was changed — renamed, added, or given different values — part-way through the stored history. Points before and after form different series and will not group together (chapter 7). There is no repair; there is only dating the change honestly and, next time, making tag changes with the ceremony chapter 14 asks for: decided, tested with `--test`, and rolled out on purpose.

## "Warnings at every startup"

Two warnings appear in every lab transcript for 1.40.3 and neither stops anything: strict environment-variable handling becoming the default (it matters only if the config reads environment variables; add the `--non-strict-env-handling` flag only if an older config genuinely needs the old behaviour), and the `skip_processors_after_aggregators` default changing in v1.41.0 (set the option explicitly if your pipeline's order depends on it — chapter 10). A warning is not an error, but a *new* warning after an upgrade or a config edit is a message worth reading once, in full, before deciding it is harmless.

Check: for the last Telegraf surprise you met, name which entry of this page it was and the chapter that predicted it. The goal of the page is that next time the naming takes seconds.

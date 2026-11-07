# Reading files and parsers

Outcome: a JSON document that was never written for a database becomes clean measurements — with the tags chosen by you, proved in `--test` — and you know what a parser is deciding on your behalf when it does that.

## The fixture

The lab invents a community noticeboard project: a display board with small sensors reporting the rooms it serves. Its readings file, `telegraf-lab/fixtures/readings.json`, is an ordinary JSON array, written the way any small program might write it:

```json
[
  {"sensor": "temp-north", "room": "hall-a", "temperature_c": 21.5, "humidity_pct": 44, "battery_pct": 87},
  {"sensor": "temp-south", "room": "hall-b", "temperature_c": 23.0, "humidity_pct": 41, "battery_pct": 92},
  {"sensor": "door-counter", "room": "lobby", "opens": 17, "battery_pct": 78}
]
```

Nothing in that file says "tag" or "field". Nothing says the measurement is called anything. Those decisions are the config's — chapter 1's rule again.

## The config that reads it

`telegraf-lab/configs/fixture.conf` does the whole job with one input block:

```toml
[[inputs.file]]
  files = ["fixtures/readings.json"]
  data_format = "json"
  tag_keys = ["sensor", "room"]
  name_override = "noticeboard_reading"
```

- `files` names what to read, each gather.
- `data_format = "json"` selects the **parser** — the part that turns text into measurements (chapter 2).
- `tag_keys` is the important line: it names the JSON keys whose values become **tags** instead of fields. `sensor` and `room` are the "which" of chapter 7, so they are named here on purpose.
- `name_override` sets the measurement name, because the file input would otherwise call every point `file`.

## The proof

`--test` on that config (transcript `telegraf-lab/transcripts/t03-fixture-file.txt`) prints:

```
> noticeboard_reading,host=boardwalk-01,room=hall-a,sensor=temp-north battery_pct=87,humidity_pct=44,temp_c=21.5 1794088263000000000
> noticeboard_reading,host=boardwalk-01,room=hall-b,sensor=temp-south battery_pct=92,humidity_pct=41,temp_c=23 1794088263000000000
> noticeboard_reading,host=boardwalk-01,room=lobby,sensor=door-counter battery_pct=78,opens=17 1794088263000000000
```

Read it against chapter 7. Tags before the space: `host` (added by the agent), `room` and `sensor` (promoted by `tag_keys`). Fields after it: every remaining number, with its JSON type respected — integers such as `battery_pct=87` stay integers, decimals stay decimals. Three JSON objects became three points, one per sensor, and the door counter — which has no temperature — simply has no temperature field. Points do not need identical fields; they need the same measurement name and sensible tags.

The transcript also runs `--once` through the real file output, and the same three lines arrive in `outputs/fixture.lp` unchanged in shape. Parsing was not a test-mode trick; it is what the live agent does.

(One value above is not in the JSON: `temp_c`, where the file says `temperature_c`. A processor renamed it on the way through. That is chapter 10's subject; it is visible here first because the pipeline has one order — inputs and parsers, then processors — and this chapter's proof honestly includes it.)

## The other parsers, and the tail input

The lab ran the JSON parser for real. The rest are named from the parsers' own documentation, not run, and the text does not claim otherwise:

- **`influx`** — line protocol itself, which is how chapter 9's listener receives points that are already in Telegraf's shape.
- **`csv`** — comma-separated files, with settings to name the columns, say which columns are tags (`csv_tag_columns`), which are the timestamp, and how many header rows to skip. Same decision as `tag_keys`, in a different spelling.
- **`grok`** — pattern matching for log lines: you write a pattern with named captures, mark each capture as a field (with a type, such as float or int) or a tag, and lines that do not match are not measurements at all. Parsing is only as good as the pattern you wrote — a fact chapter 14 lists as a limit, because a log whose format drifts quietly stops producing the fields you expect.
- **`value` and friends** — a file holding a single number, and other special shapes, for the many small sources that are not worth a general format.

Beside `inputs.file`, which re-reads a whole file each interval, sits `inputs.tail`, which follows a growing file and parses each new line as it is appended — the natural pairing for log files and the `grok` parser. The lab did not run `tail`: its fixture is a complete document re-read cleanly by `file`, and a tail test needs a writer appending on a schedule. It is described here from the plugin's own sample settings, which `telegraf --usage tail` prints on your machine.

Check: run `telegraf --config configs/fixture.conf --test` from the `telegraf-lab/` folder. You have this chapter when the three output points carry `room` and `sensor` as tags, every other JSON number as a field, and you can say which single config line made the difference.

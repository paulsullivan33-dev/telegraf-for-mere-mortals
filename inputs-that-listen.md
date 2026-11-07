# Inputs that listen

Outcome: an agent with a door open on loopback — a point posted in with `curl` comes out the other side in the file output, verbatim but for the host tag — and you know the difference between an input that polls and an input that serves.

## Polling is not the only shape

Most inputs in this guide are **polled**: the agent wakes them each interval and they go and fetch. A web application that already has measurements, though, may prefer to *send* them — or you may want one agent to receive points from programs that cannot run an agent of their own. For that, Telegraf has **service inputs**: plugins that open a port, listen, and turn whatever arrives into points immediately. The best-documented of them is `http_listener_v2`, an HTTP endpoint that accepts line protocol.

The lab's config, `telegraf-lab/configs/http.conf`, is a page long:

```toml
[agent]
  interval = "1s"
  flush_interval = "1s"
  hostname = "boardwalk-01"

[[inputs.http_listener_v2]]
  service_address = "127.0.0.1:18083"
  paths = ["/telegraf"]
  data_format = "influx"

[[outputs.file]]
  files = ["outputs/http.lp"]
  data_format = "influx"
```

Two deliberate choices. The listener binds **127.0.0.1 only** — this door is open to the same machine, not the network; a listener bound to all interfaces accepts measurements from anyone who can reach the port, and plain line protocol over HTTP carries no proof of who sent it. (The plugin has authentication and TLS settings; the lab did not configure or test them, and they are documented-only in this guide.) And the path list is explicit: posts to `/telegraf` are accepted; the port is not a general web server.

## Posting a point

With the agent running (transcript `telegraf-lab/transcripts/t04-http-listener.txt`), its log confirms the door is open:

```
I! [inputs.http_listener_v2] Listening on 127.0.0.1:18083
```

The lab then posted one point with `curl`:

```
curl -X POST --data-binary 'noticeboard_post,sensor=door-01,room=hall-a opens=3i,temperature_c=22.1 1794088200000000000' http://127.0.0.1:18083/telegraf
```

The answer was **HTTP 204** — accepted, no content — the response line protocol uses for a successful write. A moment later, after the one-second flush, `outputs/http.lp` held:

```
noticeboard_post,host=boardwalk-01,room=hall-a,sensor=door-01 opens=3i,temperature_c=22.1 1794088200000000000
```

The point crossed the whole pipeline — listener, buffer, file output — unchanged except for one addition the agent always makes: the `host=boardwalk-01` tag, merged into the tag set in sorted order. That is the conveyor of chapter 1 photographed mid-journey: in one door as a measurement someone else shaped, out the other door with the agent's own label added, stored nowhere on the way.

The same transcript posts a malformed line (`this is not line protocol`) and gets **HTTP 400**: the listener checked the shape, refused the point, and nothing reached the file. A listener is a parser with a door — chapter 8's discipline applies at the boundary, and bad input is rejected at the boundary rather than stored and regretted.

## Living with a listener

Three practical notes, each grounded in how the lab had to work. A service input has nothing to gather, so `--test` shows nothing from it unless you also pass `--test-wait` and post during the wait — the lab ran this chapter live instead, and chapter 5 says so. A listener's points carry the timestamp the *sender* put in the line, if it put one (the lab's point kept its posted timestamp exactly), which means a sender with a wrong clock writes history in the wrong place. And a listener still flushes through the same buffer as everything else: the posted point appeared after the flush interval, not instantly — chapter 11's subject again.

The family is wider than one plugin — there are listeners and consumers for several message queues and protocols among the 244 inputs — but the shape is always this one: a door, a parser, and the same road to the outputs. Those others are characterised here, not run.

Check: run the lab's t04 driver, or repeat it by hand. You have this chapter when the good post returns 204 and appears in `outputs/http.lp` with the `host` tag added, and the malformed post returns 400 and appears nowhere.

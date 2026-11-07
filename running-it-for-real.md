# Running it for real

Outcome: an honest map of the step from the lab's bounded runs to an agent that lives on a host — what changes, what stays the same, and which parts of this chapter are documented-only because the lab ran Telegraf from a folder, in the foreground, on purpose.

Everything up to here ran in a folder, for seconds, under your eye. A real deployment differs in four ways. The model does not change at all: same config, same parts, same rule.

## As a service, not a terminal

An agent must survive logins, logouts and reboots, which is a service manager's job, not Telegraf's. Installed from the official package, Telegraf brings its own service definition — the lab's tarball contains one at `usr/lib/telegraf/scripts/telegraf.service` — runs as a dedicated `telegraf` user, reads its config from `/etc/telegraf/telegraf.conf` (plus a `telegraf.d` folder), and writes its log to the system journal. Documented only: the lab installed nothing system-wide and started no service, so this guide describes the arrangement from the package's own files rather than from a running service, and the service commands themselves (`systemctl start`, `enable`, `status`) belong to your system's documentation. The checks still apply in order: edit the config, `config check` it, `--test` it, *then* restart the service — chapter 5's ladder, climbed by a service instead of a terminal.

The one real consequence of the dedicated user deserves emphasis now, not after a confusing failure: inputs that read files, sockets or other programs run with the *service user's* permissions. A file input that worked in your terminal can fail under the service because the `telegraf` user cannot read the file. Chapter 15 lists the symptom; the cause is stated here, in advance, on purpose.

## On every host, the same shape

A fleet is the lab run many times: one agent per host, each stamping its own `host` tag, each running the *same* core config (cpu, memory, system, disk — the estate's agreed baseline) plus small per-host extras for whatever that host runs. Chapter 4's multiple-config-files arrangement exists for exactly this: a shared main file and per-role drop-ins, distributed however you already distribute configuration. The tags are what make the fleet one picture instead of many piles — and chapter 7's warning scales with it: a baseline config change to tags is a fleet-wide, history-splitting event, to be rolled out like one.

## Secrets in the config

Database passwords and API tokens belong in configs, and plain text files are a poor home for them. Telegraf offers two documented routes, neither run by the lab: environment-variable substitution in config values (the `${NAME}` spelling the generated sample config explains — and the thing the 1.40 startup warning about *strict* environment handling concerns), and **secret stores**, of which this binary carries 8, which keep values out of the file and can feed them to plugins at runtime. Whichever route a deployment chooses, the lab's rule stands: this guide prints no real credential anywhere, and its configs contain none.

## Keeping it updated, and watching the watcher

An agent on every host is another program to keep current on every host (chapter 14 counts this cost openly). Releases are frequent; the safe rhythm is the same as any fleet software — one host first, `--test` the existing config against the new binary (option spellings and defaults do move; the 1.40.3 transcripts show a default already scheduled to change), then the rest.

Finally, the watcher itself emits measurements about its own gathering — an internal input exists for the agent's own statistics — and a missing host in your database is itself a signal worth alerting on, in the system whose job alerting is. Both points are documented here from the plugin catalogue rather than run: the lab's agent was watched by a human with a stopwatch, which does not scale, and the guide says so instead of pretending otherwise.

Check: state the four differences between the lab's runs and a real deployment (service, fleet, secrets, updates), and name the one permission surprise that arrives with the service user. If you can also say which parts of this chapter the lab did *not* run, you have read it the way it was written.

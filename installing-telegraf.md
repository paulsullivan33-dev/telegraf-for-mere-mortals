# Installing Telegraf

Outcome: Telegraf on your machine, proved by the one check every route must pass — and an honest account of which routes this guide ran and which it only read about.

## The check

However you install it, the proof is the same pair:

```
telegraf version
telegraf --help
```

The lab's copy answers the first with (transcript `telegraf-lab/transcripts/t00-version-and-help.txt`):

```
Telegraf 1.40.3 (git: HEAD@41b45388)
```

Note the modern spelling: `telegraf version` is a subcommand. The older `telegraf --version` flag still works in 1.40.3 but prints as DEPRECATED in the help text — the transcript shows both facts, and this guide uses the subcommand.

The second command prints the top-level help: 49 lines in 1.40.3, listing the subcommands (`version`, `config`, `secrets`, `plugins`) and the global options every later chapter draws on — `--config`, `--test`, `--once`, `--input-filter`, `--usage` and friends. This guide captured all of it before trusting any of it. Two more discovery commands are worth knowing on day one, because a tool with hundreds of plugins cannot be learned from a list in a book:

```
telegraf --input-list     # every input plugin in this binary
telegraf --usage cpu      # the sample settings for one plugin
```

The lab counted the startup banner's own summary instead of taking marketing's word for the size of the catalogue: 244 inputs, 9 aggregators, 35 processors, 26 parsers, 68 outputs, 8 secret stores.

## The route the lab used: the official release file

InfluxData publishes ready-made files for each release on its download site, `dl.influxdata.com/telegraf/releases/`. The lab downloaded:

```
telegraf-1.40.3_linux_amd64.tar.gz
```

— 84 MB, SHA-256 `cbb95c43303db6e75e129a4eb8888ab1468009e61f6615e64a1cb82f50b0f4ce` — unpacked it, and ran the binary inside from the lab's own folder, without installing anything system-wide:

```
tar -xzf telegraf-1.40.3_linux_amd64.tar.gz
./telegraf-1.40.3/usr/bin/telegraf version
```

The tarball unpacks into a small filesystem tree: the binary at `usr/bin/telegraf` (a single self-contained file, about 314 MB — Telegraf carries all of its plugins inside itself), a full sample configuration at `etc/telegraf/telegraf.conf`, and a service definition under `usr/lib/telegraf/scripts/`. To make the command available everywhere, put the binary somewhere on your `PATH` under the plain name `telegraf`, or install the matching package (below) and let your system place it.

One honest note about versions: everything in this guide was verified against 1.40.3. At startup this version prints two warnings you will meet in the transcripts, both harmless in the lab and both worth recognising rather than fearing: one announces that strict environment-variable handling is the new default (it matters only if your config reads environment variables), and one warns that the default of `skip_processors_after_aggregators` will change in v1.41.0. Your copy's `--help` and `--usage` output outrank this guide wherever the two disagree.

## The other routes, documented only

The lab used the release tarball and no other route; these are named from the project's own distribution, not run:

- **The `.deb` and `.rpm` packages** from the same download site, for Debian/Ubuntu and Red Hat family systems. Installed this way, Telegraf also gains a system service and a `telegraf` user — chapter 12 covers what that changes, labelled as documented there too.
- **InfluxData's package repositories**, which let `apt` or `dnf` install and update Telegraf like any other system package.
- **Windows and macOS builds** of the same release, including a Windows service installer. The measurement model is identical; service management differs by platform.

Whichever door you use, finish with the check at the top of this chapter. The version line is the handshake between your machine and the rest of this guide.

Check: `telegraf version` prints a version, and `telegraf --usage cpu` prints a block of sample settings. If both do, you are installed — chapter 4 explains the file that tells the agent what to do.

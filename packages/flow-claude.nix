# flow-claude — semi-sandbox: the requests of Flow's design that start a
# harness (Launch, Wake, Refresh) and the refusal and placement only a
# working harness shows (Locked during a refresh, Queued for a busy flow),
# with real Claude Code flows on the cheapest model. It needs the living's
# Claude login and the network, so it is a runner, never a check, and it
# refuses to run unless FLOW_TEST_LIVE=1 is set.
#
# A fresh short root (removed in an exit trap) holds HOME, XDG_RUNTIME_DIR
# and the module source; only ~/.claude/.credentials.json is copied in. A
# headless Herdr server and flow-nexus start on that root with no arguments
# and are configured over the meta socket.
#
# Each test carries a target like the checks: "mind" (expected to miss
# against the pinned Flow, Mind's acceptance target) or "pass". The runner
# exits nonzero when a test's result differs from its target.
{
  pkgs,
  flake,
  system,
  ...
}:
let
  flow = flake.lib.components.flow.forSystem system;
  herdr = flake.lib.components.herdr.forPkgs pkgs;
in
pkgs.writeShellApplication {
  name = "flow-claude";

  runtimeInputs = [
    pkgs.b3sum
    pkgs.coreutils
    pkgs.findutils
    pkgs.gnugrep
    pkgs.jq
    flow.package
    herdr.package
  ];

  meta.description = "Launch, Wake and Refresh of Flow's design with Claude Code flows (needs FLOW_TEST_LIVE=1).";

  text = ''
    if [ "''${FLOW_TEST_LIVE:-}" != 1 ]; then
      echo "flow-claude: needs the living's Claude login and the network; set FLOW_TEST_LIVE=1 to run it" >&2
      exit 2
    fi

    model="''${FLOW_TEST_MODEL:-${flake.lib.cheapestModel.claude}}"
    credentials="$HOME/.claude/.credentials.json"
    if [ ! -s "$credentials" ]; then
      echo "flow-claude: no Claude login at $credentials" >&2
      exit 1
    fi

    # A short root: sun_path holds 108 bytes.
    root="$(mktemp -d /tmp/ft-XXXXXXXX)"
    pids=()
    trap 'kill "''${pids[@]}" 2>/dev/null || true; herdr server stop > /dev/null 2>&1 || true; rm -rf "$root"' EXIT

    export HOME="$root/home" XDG_RUNTIME_DIR="$root/run"
    mkdir -p "$HOME/.claude" "$XDG_RUNTIME_DIR" "$root/source"
    chmod 700 "$XDG_RUNTIME_DIR"
    cp "$credentials" "$HOME/.claude/.credentials.json"
    cp -r ${../fixtures/flow/source}/. "$root/source/"
    SHELL="${pkgs.bashInteractive}/bin/bash" herdr server > "$root/herdr.log" 2>&1 &
    pids+=($!)
    RUST_LOG=debug ${flow.nexus} "Start.{ $XDG_RUNTIME_DIR/${flow.ordinarySocket} $XDG_RUNTIME_DIR/${flow.metaSocket} }" 2> "$root/flow-nexus.log" &
    pids+=($!)

    for socket in ${flow.ordinarySocket} ${flow.metaSocket}; do
      for _ in $(seq 1 100); do
        [ -S "$XDG_RUNTIME_DIR/$socket" ] && break
        sleep 0.1
      done
      [ -S "$XDG_RUNTIME_DIR/$socket" ] || { echo "flow-claude: $socket never bound" >&2; exit 1; }
    done
    for _ in $(seq 1 100); do herdr workspace list > /dev/null 2>&1 && break; sleep 0.1; done

    # expect <label> <reply> <command...>: the whole output must equal <reply>.
    expect() {
      label="$1" want="$2"
      shift 2
      got="$(timeout 120 "$@" 2>&1)" || true
      echo "$label: «$got»"
      [ "$got" = "$want" ] || { echo "$label: expected «$want»" >&2; return 1; }
    }
    # reply <label> <command...>: prints the output to stdout, logs it.
    reply() {
      label="$1"
      shift
      got="$(timeout 120 "$@" 2>&1)" || true
      echo "$label: «$got»" >&2
      printf '%s' "$got"
    }
    # The newest Claude transcript under the root.
    newestTranscript() {
      find "$HOME/.claude/projects" -name '*.jsonl' -printf '%T@ %p\n' 2>/dev/null | sort -n | tail -1 | cut -d' ' -f2-
    }
    # The transcript holding a marker, waited for up to five minutes.
    transcriptWith() {
      for _ in $(seq 1 600); do
        found="$(grep -l -r --include='*.jsonl' "$1" "$HOME/.claude/projects" 2>/dev/null | head -1)" || true
        [ -n "$found" ] && { echo "$found"; return 0; }
        sleep 0.5
      done
      return 1
    }
    firstPrompt() {
      jq -rs '[.[] | select(.type == "user")][0].message.content | if type == "string" then . else map(.text // "") | join("") end' "$1"
    }
    # bindProcess <address> <pid>: Bind.{ Address { Pid Started } } on the
    # ordinary socket.
    bindProcess() {
      started="$(cut -d' ' -f22 "/proc/$2/stat")"
      bound="$(reply "Bind $1" flow "Bind.{ $1 { $2 $started } }")"
      case "$bound" in Bound.*) ;; *) return 1 ;; esac
    }
    # A sender: a pane's shell bound under the address.
    bindSender() {
      pane="$(herdr workspace create --cwd "$HOME" --label sender --no-focus | jq -r .result.root_pane.pane_id)"
      bindProcess "$1" "$(herdr pane process-info --pane "$pane" | jq -r .result.process_info.shell_pid)"
    }
    # asMessage <datom>: Lock, Deliver and Release are accepted only from the
    # Message Nexus's own process. A fresh process waits, is bound as
    # { Field message Primary }, then execs flow with the datom, keeping
    # its pid and start time; prints the reply.
    messages=0
    asMessage() {
      messages=$((messages + 1))
      base="$root/message-$messages"
      mkfifo "$base.go"
      # shellcheck disable=SC2016
      sh -c 'echo $$ > "$1.pid"; read -r _ < "$1.go"; exec flow "$2"' _ "$base" "$1" > "$base.reply" 2>&1 &
      runner=$!
      for _ in $(seq 1 100); do [ -s "$base.pid" ] && break; sleep 0.1; done
      bindProcess '{ Field message Primary }' "$(cat "$base.pid")" >&2
      echo go > "$base.go"
      wait "$runner" || true
      cat "$base.reply"
    }
    launch() {
      launched="$(reply "Launch $1" flow "Launch.{ $1 [ { Vision flow } ] «$2» }")"
      case "$launched" in Launched.*) echo "''${launched#Launched.}" ;; *) return 1 ;; esac
    }

    configureAll() {
      expect "Configure.Nexus" Configured flow-meta "${
        flow.nexusPayload {
          runtime = "$XDG_RUNTIME_DIR";
          home = "$HOME";
          sourceRoot = "$root/source";
          messageNexusBinary = flow.client;
          lease = "60";
        }
      }"
      for layer in ${builtins.concatStringsSep " " flow.layers}; do
        expect "Configure.Model $layer" Configured flow-meta "Configure.Model.{ $layer Claude $model }"
        expect "Configure.Threshold $layer" Configured flow-meta "Configure.Threshold.{ $layer 20 40 }"
      done
      digest="$(b3sum --no-names "$root/source/psyche-skills/vision/flow.md")"
      expect "Configure.Module" Configured flow-meta "Configure.Module.{ { Vision flow } { psyche-skills $digest vision/flow.md } false }"
    }

    # Launch: Launched.FlowId; Current is Awake with it; the pane is titled
    # with the address written short; the first prompt carries the brief.
    testLaunch() {
      id="$(launch '{ Mind launch Secondary }' 'Reply with the word ftLaunched, then stop.')"
      expect "Current" "Current.Awake.$id" flow 'Current.{ Mind launch Secondary }'
      herdr pane list | grep -q '{ Mind launch Secondary }' || { echo "no pane titled { Mind launch Secondary }" >&2; return 1; }
      transcript="$(transcriptWith ftLaunched)"
      case "$(firstPrompt "$transcript")" in *ftLaunched*) ;; *) echo "the first prompt lacks the brief" >&2; return 1 ;; esac
    }

    # Wake: an asleep metaflow (launched, its pane closed) takes a Notice
    # (Queued), then an Order (Woken.FlowId); the woken flow's first prompt
    # ends with the drained queue, the Order last.
    testWake() {
      launch '{ Mind wake Secondary }' 'Reply ok, then stop.' > /dev/null
      pane="$(herdr pane list | jq -r '.result.panes[] | select((.title // "") | contains("{ Mind wake Secondary }")) | .pane_id' | head -1)"
      herdr pane close "$pane"
      expect "Current before" Current.Asleep flow 'Current.{ Mind wake Secondary }'
      expect "Wake with a Notice" Queued flow 'Wake.{ { Mind wake Secondary } Notice.«ftWake branch merged» }'
      woken="$(reply "Wake with an Order" flow 'Wake.{ { Mind wake Secondary } Order.«ftWake reply ok» }')"
      case "$woken" in Woken.*) ;; *) return 1 ;; esac
      transcript="$(transcriptWith 'ftWake reply ok')"
      first="$(firstPrompt "$transcript")"
      case "$first" in
        *'[ Notice.«ftWake branch merged» Order.«ftWake reply ok» ]'*) ;;
        *) echo "the woken flow's first prompt lacks the drained queue, the Order last" >&2; return 1 ;;
      esac
    }

    # Refresh: Refreshed.{ successor predecessor }; Current is Awake with the
    # successor; Metaflows lists the predecessor in Past.
    testRefresh() {
      old="$(launch '{ Mind refresh Secondary }' 'Reply ok, then stop.')"
      refreshed="$(reply "Refresh" flow 'Refresh.{ Mind refresh Secondary }')"
      case "$refreshed" in "Refreshed.{ "*" $old }") ;; *) return 1 ;; esac
      new="''${refreshed#Refreshed.\{ }"
      new="''${new%% *}"
      expect "Current" "Current.Awake.$new" flow 'Current.{ Mind refresh Secondary }'
      listed="$(reply Metaflows flow Metaflows)"
      case "$listed" in *"{ { Mind refresh Secondary } Awake.$new [ $old ] [] }"*) ;; *) return 1 ;; esac
    }

    # Locked: a Lock while a refresh is under way is refused Locked.
    testRefreshLocked() {
      bindSender '{ Psyche locked Secondary }'
      launch '{ Mind locked Secondary }' 'Reply ok, then stop.' > /dev/null
      flow 'Refresh.{ Mind locked Secondary }' > "$root/refresh-locked.reply" 2>&1 &
      sleep 1
      got="$(asMessage 'Lock.{ { Psyche locked Secondary } Address.{ Mind locked Secondary } }')"
      echo "Lock during the refresh: «$got»"
      [ "$got" = Refused.Locked ]
      wait
    }

    # A busy awake flow: a Deliver under the lock is Queued, then drained at
    # its next Stop; the transcript holds the Order exactly once.
    testDeliverBusy() {
      bindSender '{ Psyche busy Secondary }'
      launch '{ Mind busy Secondary }' 'Run the shell command sleep 30, then reply done.' > /dev/null
      for _ in $(seq 1 600); do
        transcript="$(newestTranscript)"
        [ -n "$transcript" ] && grep -q '"tool_use"' "$transcript" && break
        sleep 0.5
      done
      locked="$(asMessage 'Lock.{ { Psyche busy Secondary } Address.{ Mind busy Secondary } }')"
      echo "Lock: «$locked»"
      case "$locked" in Locked.*) ;; *) return 1 ;; esac
      delivered="$(asMessage "Deliver.{ ''${locked#Locked.} Order.«ftBusy reply received» }")"
      echo "Deliver to the busy flow: «$delivered»"
      [ "$delivered" = Queued ]
      for _ in $(seq 1 1200); do grep -q ftBusy "$transcript" && break; sleep 0.5; done
      count="$(jq -s '[.[] | select(.type == "user") | tostring | select(test("ftBusy"))] | length' "$transcript")"
      echo "the transcript holds the Order $count times"
      [ "$count" = 1 ]
    }

    failed=0
    # outcome <name> <target> <exit code>
    outcome() {
      case "$2:$3" in
        pass:0) echo "flow-claude $1: passing" ;;
        mind:0) echo "flow-claude $1: unexpectedly passing; promote it to target pass"; failed=1 ;;
        pass:*) echo "flow-claude $1: failing (target pass)"; failed=1 ;;
        mind:*) echo "flow-claude $1: expected-failing (Mind target)" ;;
      esac
    }
    set +e
    ( set -e; configureAll )
    configured=$?
    code=1
    [ "$configured" = 0 ] && { ( set -e; testLaunch ); code=$?; }
    outcome Launch mind "$code"
    code=1
    [ "$configured" = 0 ] && { ( set -e; testWake ); code=$?; }
    outcome Wake mind "$code"
    code=1
    [ "$configured" = 0 ] && { ( set -e; testRefresh ); code=$?; }
    outcome Refresh mind "$code"
    code=1
    [ "$configured" = 0 ] && { ( set -e; testRefreshLocked ); code=$?; }
    outcome RefreshLocked mind "$code"
    code=1
    [ "$configured" = 0 ] && { ( set -e; testDeliverBusy ); code=$?; }
    outcome DeliverBusy mind "$code"
    set -e
    exit "$failed"
  '';
}

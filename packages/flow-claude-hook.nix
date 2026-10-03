# flow-claude-hook — a gated semi-sandbox: the Flow harness hook in a
# light-model Claude Code print run, reporting to its own Flow Nexus. It
# needs the living's Claude login and the network, so it is a runner, never
# a check, and it refuses to run unless FLOW_TEST_LIVE=1 is set.
# `nix flake check` only builds this script.
#
# Drive:
#   1. A fresh short `mktemp -d` root, removed in an exit trap with the
#      Nexus killed. HOME, every XDG root and TMPDIR point into it; no
#      Herdr variable of the caller's reaches it.
#   2. Copy only `~/.claude/.credentials.json` into the root's home; refuse
#      when its access token expires within 15 minutes.
#   3. Start a Flow Nexus on the root (fresh store, its own sockets) with the
#      fixture Herdr first on its PATH, standing in for the flow's pane.
#   4. Make Flow hold the sandbox flow: claim a fresh FlowId for a fresh
#      Claude session id (the claim marker under the source root's flows/),
#      then meta `RegisterFlow` it at the fixture pane. Assert
#      `ReadEvents.<id>` answers no events yet, and a `Report` for a FlowId
#      Flow does not hold answers `Refused.UnknownFlow`, adopting nothing.
#   5. Run Claude Code once with FLOW_ID=<id> and that session id: `-p`, the
#      cheapest model, the hook settings Flow writes into a launched flow
#      (lib/components/flow-hook.nix) with a witness tap, one allowed tool
#      (`Bash(echo:*)`), bounded by a 2G scope, 300 s and 4 turns.
#   6. Witness, every check printed before the verdict: the hook fired on
#      SessionStart, PostToolUse and Stop and each Report answered Reported;
#      `ReadEvents.<id>` shows Started first, ToolUsed.Bash, Stopped last;
#      the unknown FlowId is still unknown.
#   Exit 0 only when every check holds; 1 otherwise.
{
  pkgs,
  flake,
  system,
  ...
}:
let
  flow = flake.lib.components.flow.forSystem system;
  claude = flake.lib.components.claude.forSystem system;
  hook = flake.lib.components.flow-hook.forSystem system;
  herdr = flake.lib.components.herdr-fixture.forSystem system;
  settings = hook.settings {
    prefix = ''tee -a "$FLOW_HOOK_WITNESS/inputs.jsonl" | '';
    suffix = " 2>> \"$FLOW_HOOK_WITNESS/calls.tsv\"";
  };
in
pkgs.writeShellApplication {
  name = "flow-claude-hook";

  runtimeInputs = [
    pkgs.coreutils
    pkgs.gawk
    pkgs.jq
    pkgs.systemd
  ];

  meta.description = "The Flow harness hook in a light-model Claude Code run, reporting to its own Flow Nexus (gated: needs FLOW_TEST_LIVE=1).";

  text = ''
    if [ "''${FLOW_TEST_LIVE:-}" != 1 ]; then
      echo "flow-claude-hook: needs the living's Claude login and the network; set FLOW_TEST_LIVE=1 to run it" >&2
      exit 2
    fi

    model="''${FLOW_TEST_MODEL:-${flake.lib.cheapestModel.claude}}"
    livingCredentials="$HOME/${claude.credentials}"
    # systemd-run reaches the living's user manager through these two; the
    # bounded scope then gets the sandbox's runtime directory back.
    livingRuntime="''${XDG_RUNTIME_DIR:?needed to reach the user manager}"
    expiresAt="$(jq -r '.claudeAiOauth.expiresAt // 0' "$livingCredentials")"
    if [ "$expiresAt" -lt $(( ($(date +%s) + 900) * 1000 )) ]; then
      echo "flow-claude-hook: the Claude access token expires within 15 minutes; refresh the login first" >&2
      exit 2
    fi

    # A short root: sun_path holds 108 bytes.
    root="$(mktemp -d /tmp/fh-XXXXXXXX)"
    flowNexusPid=
    trap 'if [ -n "$flowNexusPid" ]; then kill "$flowNexusPid" 2>/dev/null || true; wait "$flowNexusPid" 2>/dev/null || true; fi; rm -rf "$root"' EXIT

    # The caller's own pane must not name the sandbox's processes.
    unset FLOW_SOCKET FLOW_META_SOCKET FLOW_ID HERDR_ENV HERDR_SESSION HERDR_PANE_ID HERDR_TAB_ID \
      HERDR_WORKSPACE_ID HERDR_SOCKET_PATH HERDR_BIN_PATH
    export HOME="$root/home" XDG_RUNTIME_DIR="$root/run" XDG_STATE_HOME="$root/state" \
      XDG_CONFIG_HOME="$root/config" XDG_CACHE_HOME="$root/cache" XDG_DATA_HOME="$root/data" \
      TMPDIR="$root/tmp" FLOW_HOOK_WITNESS="$root/witness"
    mkdir -p "$HOME/.claude" "$HOME/primary/flows" "$XDG_STATE_HOME" "$XDG_CONFIG_HOME" \
      "$XDG_CACHE_HOME" "$XDG_DATA_HOME" "$TMPDIR" "$FLOW_HOOK_WITNESS" "$root/work"
    chmod 700 "$HOME" "$HOME/.claude"
    install -m 600 "$livingCredentials" "$HOME/${claude.credentials}"

    # The flow: a fresh FlowId and Claude session id, its pane the fixture's.
    flowId="$(od -An -N3 -tx1 /dev/urandom | tr -d ' \n')"
    sessionId="$(cat /proc/sys/kernel/random/uuid)"
    herdrSession=flow-hook-sandbox
    export FIXTURE_HERDR_PANE=fh:p1 FIXTURE_HERDR_TERMINAL=fh-terminal-1
    printf 'version=1\nharness=claude\nidentity=%s\nalias=%s\n' "''${sessionId//-/}" "$flowId" \
      > "$HOME/primary/flows/.$flowId.flow-id"
    unknownFlowId=0a0a0a
    [ "$flowId" != "$unknownFlowId" ] || unknownFlowId=0b0b0b

    PATH="${herdr.package}/bin:$PATH"
    ${flow.start}

    red=0
    check() {
      if [ "$2" = yes ]; then echo "green: $1"; else echo "red: $1"; red=1; fi
    }
    answers() {
      local name="$1" expected="$2" reply
      shift 2
      reply="$(timeout 10 "$@" 2>&1)" || true
      echo "$name: $reply"
      check "$name answers $expected" "$([ "$reply" = "$expected" ] && echo yes || echo no)"
    }

    answers register "FlowRegistered.{ $flowId $sessionId Claude Unavailable Available.{ $herdrSession sandbox-claude $FIXTURE_HERDR_PANE $FIXTURE_HERDR_TERMINAL } { $flowId $sessionId unavailable } Active }" \
      ${flow.metaClient} "RegisterFlow.{ $flowId $sessionId Claude Unavailable Available.{ $herdrSession sandbox-claude $FIXTURE_HERDR_PANE $FIXTURE_HERDR_TERMINAL } { $flowId $sessionId unavailable } Active }"
    answers events-before-run "EventsRead.{ $flowId [] }" ${flow.metaClient} "ReadEvents.$flowId"
    answers unknown-report "Refused.UnknownFlow.$unknownFlowId" ${flow.client} "Report.{ $unknownFlowId Started }"

    cat > "$root/settings.json" <<'SETTINGS'
    ${settings}
    SETTINGS
    touch "$FLOW_HOOK_WITNESS/inputs.jsonl" "$FLOW_HOOK_WITNESS/calls.tsv"

    echo "flow-claude-hook: running ${claude.package.name} ($model) as flow $flowId, session $sessionId, on $root"
    set +e
    (cd "$root/work" && XDG_RUNTIME_DIR="$livingRuntime" DBUS_SESSION_BUS_ADDRESS="unix:path=$livingRuntime/bus" \
      systemd-run --user --scope --quiet -p MemoryMax=2G \
      env XDG_RUNTIME_DIR="$root/run" DBUS_SESSION_BUS_ADDRESS= DISABLE_AUTOUPDATER=1 DISABLE_NON_ESSENTIAL_MODEL_CALLS=1 \
        ENABLE_CLAUDEAI_MCP_SERVERS=false FLOW_ID="$flowId" \
      timeout 300 ${claude.binary} -p 'Run exactly this with the Bash tool: echo flow-hook-probe. Then reply with the single word done.' \
        --model "$model" --session-id "$sessionId" --settings "$root/settings.json" \
        --permission-mode default --strict-mcp-config \
        --allowedTools 'Bash(echo:*)' --max-turns 4 \
        --output-format stream-json --verbose > "$root/run.jsonl" 2> "$root/run.stderr")
    runCode=$?
    set -e
    runSession="$(jq -r 'select(.type == "system" and .subtype == "init") | .session_id' "$root/run.jsonl" | head -n 1)"
    echo "run: exit $runCode, session $runSession"
    if [ "$runCode" != 0 ]; then
      echo "--- run stderr"
      tail -n 20 "$root/run.stderr"
      echo "--- run stream tail"
      tail -n 3 "$root/run.jsonl"
    fi
    echo "--- hook inputs (event, tool)"
    jq -c '{hook_event_name, tool_name}' "$FLOW_HOOK_WITNESS/inputs.jsonl"
    echo "--- hook calls (event, datom, flow exit, flow output)"
    cat "$FLOW_HOOK_WITNESS/calls.tsv"

    fired() { jq -e --arg e "$1" 'select(.hook_event_name == $e)' "$FLOW_HOOK_WITNESS/inputs.jsonl" > /dev/null && echo yes || echo no; }
    reported() {
      awk -F '\t' -v e="$1" -v d="$2" '$1 == e && $2 == d && $3 == "0" && $4 == "Reported" { found = 1 } END { print (found ? "yes" : "no") }' "$FLOW_HOOK_WITNESS/calls.tsv"
    }
    check "the run exited 0" "$([ "$runCode" = 0 ] && echo yes || echo no)"
    check "the run's session is the flow's session" "$([ "$runSession" = "$sessionId" ] && echo yes || echo no)"
    check "the hook fired on SessionStart" "$(fired SessionStart)"
    check "the hook fired on PostToolUse" "$(fired PostToolUse)"
    check "the hook fired on Stop" "$(fired Stop)"
    check "SessionStart: Report Started answered Reported" "$(reported SessionStart "Report.{ «$flowId» Started }")"
    check "PostToolUse: Report ToolUsed.Bash answered Reported" "$(reported PostToolUse "Report.{ «$flowId» ToolUsed.«Bash» }")"
    check "Stop: Report Stopped answered Reported" "$(reported Stop "Report.{ «$flowId» Stopped }")"

    events="$(timeout 10 ${flow.metaClient} "ReadEvents.$flowId" 2>&1)" || true
    echo "ReadEvents.$flowId after the run: $events"
    check "the Nexus holds Started first, ToolUsed.Bash, Stopped last for $flowId" \
      "$(case "$events" in "EventsRead.{ $flowId [ Started "*"ToolUsed.Bash "*"Stopped ] }") echo yes ;; *) echo no ;; esac)"
    answers unknown-still-unknown ReadEventsRejected.UnknownFlow ${flow.metaClient} "ReadEvents.$unknownFlowId"

    ${flow.stop}
    flowNexusPid=
    if [ "$red" = 0 ]; then echo "flow-claude-hook: green"; else echo "flow-claude-hook: red" >&2; fi
    exit "$red"
  '';
}

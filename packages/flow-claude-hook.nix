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
#      fixture Herdr first on its PATH, standing in for the flow's pane. The
#      Nexus runs in the next slot's layout: its runtime directory is
#      `run/flow-next`, so it serves `run/flow-next/flow/flow.sock`, while
#      the pane's shell and every harness have `run` as XDG_RUNTIME_DIR,
#      where the default `run/flow/flow.sock` does not exist. Steps 4-6 name
#      the Nexus's sockets to the clients and the hand-run harness
#      (FLOW_SOCKET, FLOW_META_SOCKET), as a caller choosing a Nexus does.
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
#   7. A flow Flow launches (flow 0.22.0; its FLOW_SOCKET since 0.23.0): the ordinary `Start` of a Claude
#      launch on the cheapest model, through the fixture Herdr's launch
#      stages (lib/components/herdr-fixture.nix) and the real `flow-id`
#      (lib/components/flow-id.nix). The fixture pane's shell inherited a
#      foreign FLOW_ID; it runs the line Flow typed, records the
#      environment the harness gets, and runs Claude Code with the agent
#      arguments Flow passed (Flow's own hook settings, `--session-id`, the
#      launch's system prompt file), as `-p` with one probe prompt, bounded
#      like step 5. Witness: the FlowId Flow reserved is the claim of the
#      session it passed; the harness's FLOW_ID is that FlowId, not the
#      inherited one; the run's session is that session; `ReadEvents` of the
#      FlowId shows Started first, ToolUsed.Bash, Stopped last: nothing but
#      the launch itself told that harness where its Nexus is, so its
#      FLOW_SOCKET is the Nexus's ordinary socket and the default stable
#      path is still absent. Where the
#      stand-in stops: it refuses the title `/rename`, so the Start answers
#      `StartRejected.BindingRefused` at Title, after Bind and Register; no
#      first prompt is typed into an interactive pane.
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
  flowId = flake.lib.components.flow-id.forSystem system;
  herdrCli = "${pkgs.herdr}/bin/herdr";
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
    pkgs.util-linux
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
    interactiveHerdrPid=
    interactiveSession=
    trap 'if [ -n "$flowNexusPid" ]; then kill "$flowNexusPid" 2>/dev/null || true; wait "$flowNexusPid" 2>/dev/null || true; fi; if [ -n "$interactiveHerdrPid" ]; then kill "$interactiveHerdrPid" 2>/dev/null || true; fi; if [ -n "$interactiveSession" ]; then ${herdrCli} --session "$interactiveSession" server stop 2>/dev/null || true; fi; rm -rf "$root"' EXIT

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
    # This is an installed, generated native Claude skill, not a copied
    # setting or a prompt-shaped substitute.  The disposable HOME owns every
    # other Claude path; the read-only link lets the first interactive user
    # message resolve the current Curriculum projection.
    ln -s /home/li/primary/.claude/skills "$HOME/.claude/skills"

    # The interactive witness owns a separate Herdr server and configuration.
    # It never points at the caller's session, socket, pane, or configuration.
    mkdir -p "$XDG_CONFIG_HOME/herdr"
    cat > "$XDG_CONFIG_HOME/herdr/config.toml" <<'HERDR_CONFIG'
    [update]
    version_check = false
    manifest_check = false
    [experimental]
    allow_nested = true
    HERDR_CONFIG
    export HERDR_CONFIG_PATH="$XDG_CONFIG_HOME/herdr/config.toml"

    # The flow: a fresh FlowId and Claude session id, its pane the fixture's.
    flowId="$(od -An -N3 -tx1 /dev/urandom | tr -d ' \n')"
    sessionId="$(cat /proc/sys/kernel/random/uuid)"
    herdrSession=flow-hook-sandbox
    export FIXTURE_HERDR_PANE=fh:p1 FIXTURE_HERDR_TERMINAL=fh-terminal-1
    printf 'version=1\nharness=claude\nidentity=%s\nalias=%s\n' "''${sessionId//-/}" "$flowId" \
      > "$HOME/primary/flows/.$flowId.flow-id"
    unknownFlowId=0a0a0a
    [ "$flowId" != "$unknownFlowId" ] || unknownFlowId=0b0b0b

    # The launch stand-in (step 7): its state, the shell identity its pane
    # inherited, and the harness it runs, bounded as step 5's run is.
    launchProbe='Run exactly this with the Bash tool: echo flow-launch-probe. Then reply with the single word done.'
    export FIXTURE_HERDR_STATE="$root/herdr" FIXTURE_HERDR_INHERITED_FLOW_ID=0c0c0c \
      FIXTURE_HERDR_HARNESS="$root/bin/harness"
    mkdir -p "$FIXTURE_HERDR_STATE" "$root/bin"
    cat > "$FIXTURE_HERDR_HARNESS" <<HARNESS
    #!${pkgs.runtimeShell}
    exec env XDG_RUNTIME_DIR="$livingRuntime" DBUS_SESSION_BUS_ADDRESS="unix:path=$livingRuntime/bus" \\
      ${pkgs.systemd}/bin/systemd-run --user --scope --quiet -p MemoryMax=2G \\
      env XDG_RUNTIME_DIR="$root/run" DBUS_SESSION_BUS_ADDRESS= DISABLE_AUTOUPDATER=1 DISABLE_NON_ESSENTIAL_MODEL_CALLS=1 \\
        ENABLE_CLAUDEAI_MCP_SERVERS=false \\
      ${pkgs.coreutils}/bin/timeout 300 ${claude.binary} "\$@" -p "$launchProbe" --strict-mcp-config --max-turns 4 \\
        --output-format stream-json --verbose
    HARNESS
    chmod +x "$FIXTURE_HERDR_HARNESS"
    printf 'flow-test launch source\n' > "$HOME/primary/launch-source.md"
    printf 'You are a sandbox flow. Do exactly what the prompt asks.\n' > "$HOME/primary/launch-system-prompt.md"

    # The next slot's layout: the Nexus under run/flow-next, the pane's shell
    # (the Herdr server's environment) under run, with no Flow socket there.
    nexusRuntime="$root/run/flow-next"
    stableSocket="$root/run/flow/flow.sock"
    export FIXTURE_HERDR_RUNTIME_DIR="$root/run"
    mkdir -p "$root/run"
    chmod 700 "$root/run"

    PATH="${herdr.package}/bin:${flowId.bin}:$PATH"
    XDG_RUNTIME_DIR="$nexusRuntime"
    ${flow.start}
    XDG_RUNTIME_DIR="$root/run"
    nexusSocket="$FLOW_SOCKET"
    echo "flow-nexus serves $nexusSocket; the pane's runtime directory is $XDG_RUNTIME_DIR"

    red=0
    check() {
      if [ "$2" = yes ]; then echo "green: $1"; else echo "red: $1"; red=1; fi
    }

    # A real, private Herdr pane carries one interactive Claude turn. Its
    # first user input is the native, user-only contact discipline, followed
    # by the harmless environment request.  No later turn invokes a skill.
    interactiveSession=flow-claude-hook-private
    interactiveLog="$FLOW_HOOK_WITNESS/herdr.typescript"
    setsid script -qfc "stty cols 160 rows 48; ${herdrCli} session attach $interactiveSession" "$interactiveLog" \
      </dev/null >"$FLOW_HOOK_WITNESS/herdr-client.log" 2>&1 &
    interactiveHerdrPid=$!
    for attempt in $(seq 1 30); do
      ${herdrCli} --session "$interactiveSession" pane list >"$FLOW_HOOK_WITNESS/panes.json" 2>/dev/null && break
      sleep 1
    done
    interactivePane="$(jq -r '.result.panes[0].pane_id // empty' "$FLOW_HOOK_WITNESS/panes.json")"
    test -n "$interactivePane" || { echo "private Herdr did not create a pane" >&2; exit 1; }
    interactiveSessionId="$(cat /proc/sys/kernel/random/uuid)"
    interactivePrompt="$root/interactive-first-user-turn.txt"
    cat > "$interactivePrompt" <<'PROMPT'
    /trial-contact-discipline

    This is a disposable Flow witness. Use one harmless shell tool invocation to print exactly FLOW_ID, FLOW_DIRECTORY and FLOW_SOCKET, then reply exactly: witness complete.
    PROMPT
    ${herdrCli} --session "$interactiveSession" pane run "$interactivePane" \
      "cd $root/work && exec env XDG_RUNTIME_DIR=$livingRuntime DBUS_SESSION_BUS_ADDRESS=unix:path=$livingRuntime/bus ${pkgs.systemd}/bin/systemd-run --user --scope --quiet -p MemoryMax=2G env XDG_RUNTIME_DIR=$root/run DBUS_SESSION_BUS_ADDRESS= DISABLE_AUTOUPDATER=1 DISABLE_NON_ESSENTIAL_MODEL_CALLS=1 ENABLE_CLAUDEAI_MCP_SERVERS=false FLOW_ID=$flowId FLOW_DIRECTORY=$HOME/primary/flows/$flowId FLOW_SOCKET=$nexusSocket ${pkgs.coreutils}/bin/timeout 300 ${claude.binary} --session-id $interactiveSessionId --model $model --effort low --remote-control --dangerously-skip-permissions --max-turns 4 \"\$(< $interactivePrompt)\"" \
      >"$FLOW_HOOK_WITNESS/interactive-launch.json"
    ${herdrCli} --session "$interactiveSession" pane wait-output "$interactivePane" --match 'witness complete' --timeout 300000 \
      >"$FLOW_HOOK_WITNESS/interactive-wait.json" || true
    ${herdrCli} --session "$interactiveSession" pane read "$interactivePane" --source recent-unwrapped --lines 400 \
      >"$FLOW_HOOK_WITNESS/interactive-pane.txt" || true
    check "interactive Claude received its exact UUID" "$(grep -F "$interactiveSessionId" "$FLOW_HOOK_WITNESS/interactive-pane.txt" >/dev/null && echo yes || echo no)"
    check "interactive first user input names trial-contact-discipline" "$(grep -F '/trial-contact-discipline' "$FLOW_HOOK_WITNESS/interactive-pane.txt" >/dev/null && echo yes || echo no)"
    check "interactive first user input was delivered before witness work" "$(grep -F 'This is a disposable Flow witness.' "$FLOW_HOOK_WITNESS/interactive-pane.txt" >/dev/null && echo yes || echo no)"
    check "interactive Claude printed the three Flow environment values" "$(grep -F "FLOW_ID=$flowId" "$FLOW_HOOK_WITNESS/interactive-pane.txt" >/dev/null && grep -F "FLOW_DIRECTORY=$HOME/primary/flows/$flowId" "$FLOW_HOOK_WITNESS/interactive-pane.txt" >/dev/null && grep -F "FLOW_SOCKET=$nexusSocket" "$FLOW_HOOK_WITNESS/interactive-pane.txt" >/dev/null && echo yes || echo no)"
    ${herdrCli} --session "$interactiveSession" server stop || true
    kill "$interactiveHerdrPid" 2>/dev/null || true

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

    echo "--- step 7: a flow Flow launches"
    sourceSha="$(sha256sum "$HOME/primary/launch-source.md" | cut -d ' ' -f 1)"
    start="Start.{ { flow-test-launch [ { launch-source.md $sourceSha } ] [] Field Low Claude $model low None [] $herdrSession $HOME/primary/launch-system-prompt.md «Run the probe.» } { 000000 sandbox-session sandbox-turn } }"
    started="$(timeout 120 ${flow.client} "$start" 2>&1)" || true
    echo "start: $started"
    check "the Start stops where the stand-in stops (Title): StartRejected.BindingRefused" \
      "$([ "$started" = StartRejected.BindingRefused ] && echo yes || echo no)"
    launchSession="$(cat "$FIXTURE_HERDR_STATE/session" 2>/dev/null || true)"
    # flow-id claims the shortest unclaimed prefix of the session's hex
    # digits, six in a fresh root.
    launchedFlowId="$(printf '%s' "$launchSession" | tr -d - | cut -c 1-6)"
    echo "launched: session $launchSession, flow $launchedFlowId"
    check "Flow passed a --session-id" "$([ -n "$launchSession" ] && echo yes || echo no)"
    check "the flow-id claim of $launchedFlowId names that session" \
      "$(grep -qx "identity=''${launchSession//-/}" "$HOME/primary/flows/.$launchedFlowId.flow-id" 2>/dev/null && echo yes || echo no)"
    echo "--- the line Flow typed at the pane's prompt"
    cat "$FIXTURE_HERDR_STATE/pane-run" 2>/dev/null || true
    echo
    harnessPid="$(cat "$FIXTURE_HERDR_STATE/harness.pid" 2>/dev/null || true)"
    if [ -n "$harnessPid" ]; then
      timeout 330 tail --pid="$harnessPid" -f /dev/null || true
    fi
    harnessExit="$(cat "$FIXTURE_HERDR_STATE/harness.exit" 2>/dev/null || true)"
    harnessFlowId="$(sed -n 's/^FLOW_ID=//p' "$FIXTURE_HERDR_STATE/harness-env" 2>/dev/null || true)"
    harnessSession="$(jq -r 'select(.type == "system" and .subtype == "init") | .session_id' "$FIXTURE_HERDR_STATE/harness.out" 2>/dev/null | head -n 1)"
    echo "harness: exit $harnessExit, FLOW_ID $harnessFlowId, session $harnessSession"
    if [ "$harnessExit" != 0 ]; then
      echo "--- harness stderr"
      tail -n 20 "$FIXTURE_HERDR_STATE/harness.err" 2>/dev/null || true
      echo "--- harness stream tail"
      tail -n 3 "$FIXTURE_HERDR_STATE/harness.out" 2>/dev/null || true
    fi
    check "the harness Flow launched exited 0" "$([ "$harnessExit" = 0 ] && echo yes || echo no)"
    check "the harness's FLOW_ID is the FlowId Flow reserved ($launchedFlowId), not the inherited 0c0c0c" \
      "$([ -n "$launchedFlowId" ] && [ "$harnessFlowId" = "$launchedFlowId" ] && echo yes || echo no)"
    harnessSocket="$(sed -n 's/^FLOW_SOCKET=//p' "$FIXTURE_HERDR_STATE/harness-env" 2>/dev/null || true)"
    harnessRuntime="$(sed -n 's/^XDG_RUNTIME_DIR=//p' "$FIXTURE_HERDR_STATE/harness-env" 2>/dev/null || true)"
    echo "harness: FLOW_SOCKET $harnessSocket, XDG_RUNTIME_DIR $harnessRuntime"
    check "the harness's runtime directory is the pane's ($root/run), not the Nexus's" \
      "$([ "$harnessRuntime" = "$root/run" ] && echo yes || echo no)"
    check "the default stable socket $stableSocket does not exist" \
      "$([ ! -e "$stableSocket" ] && echo yes || echo no)"
    check "the harness's FLOW_SOCKET is the socket of the Nexus that launched it ($nexusSocket)" \
      "$([ "$harnessSocket" = "$nexusSocket" ] && echo yes || echo no)"
    check "the harness ran as the session Flow chose" \
      "$([ -n "$launchSession" ] && [ "$harnessSession" = "$launchSession" ] && echo yes || echo no)"
    launchedEvents="$(timeout 10 ${flow.metaClient} "ReadEvents.$launchedFlowId" 2>&1)" || true
    echo "ReadEvents.$launchedFlowId after the launched run: $launchedEvents"
    check "the Nexus holds Started first, ToolUsed.Bash, Stopped last for the launched $launchedFlowId" \
      "$(case "$launchedEvents" in "EventsRead.{ $launchedFlowId [ Started "*"ToolUsed.Bash "*"Stopped ] }") echo yes ;; *) echo no ;; esac)"
    echo "List after the launch: $(timeout 10 ${flow.client} 'List.{}' 2>&1 || true)"

    ${flow.stop}
    flowNexusPid=
    if [ "$red" = 0 ]; then echo "flow-claude-hook: green"; else echo "flow-claude-hook: red" >&2; fi
    exit "$red"
  '';
}

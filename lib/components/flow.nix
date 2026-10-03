# Flow: the Flow Nexus and its `flow` / `flow-meta` clients, taken from the
# pinned `flow` input. The Nexus takes no arguments; it derives every default
# from two anchors, HOME (its store) and XDG_RUNTIME_DIR (its sockets), so a
# scenario points both at its own root and gets a fresh store and its own
# sockets. The clients reach the default sockets under the caller's
# XDG_RUNTIME_DIR unless FLOW_SOCKET / FLOW_META_SOCKET name others.
{ inputs }:
{
  name = "flow";

  forSystem = system: rec {
    package = inputs.flow.packages.${system}.default;

    nexus = "${package}/bin/flow-nexus";
    client = "${package}/bin/flow";
    metaClient = "${package}/bin/flow-meta";

    # Relative to XDG_RUNTIME_DIR and HOME, as flow-defaults lays them out
    # for a fresh store.
    ordinarySocket = "flow/flow.sock";
    metaSocket = "flow/flow-meta.sock";
    store = ".local/state/flow/flow.sema";

    # The body of a meta `Configuration` datom: the two sockets and the
    # source root given, everything else fixed test values. The contract's
    # `Configured` reply carries the stored Configuration back unchanged, so
    # a scenario writes this same body into both the request and the
    # expected reply.
    configuration =
      {
        ordinary,
        meta,
        sourceRoot,
      }:
      "{ ${ordinary} ${meta} ${sourceRoot} { /opt/stable-client /opt/stable /opt/stable/control.sock [ stable-model ] } { /opt/next-client /opt/next /opt/next/control.sock [ next-model ] } [ { Codex [ / ] [ esc ] [] } ] [ Psyche Mind ] /opt/message-nexus }";

    # Starts the Nexus against the caller's exported HOME and
    # XDG_RUNTIME_DIR and records its pid in `flowNexusPid`. The Nexus prints
    # no ready line, so it waits (bounded) until each socket answers a
    # read-only query: `List.{}` on the ordinary socket and a `Retire` of an
    # unknown flow on the meta socket (a refusal that changes nothing). A
    # socket file existing proves nothing: on a restart the previous run's
    # files are still there. It exports the default client socket paths
    # unless the caller already set them; a scenario whose store names other
    # paths sets them itself.
    start = ''
      mkdir -p "$XDG_RUNTIME_DIR"
      chmod 700 "$XDG_RUNTIME_DIR"
      flowNexusLog="$XDG_RUNTIME_DIR/flow-nexus.stderr"
      ${nexus} 2>> "$flowNexusLog" &
      flowNexusPid=$!
      export FLOW_SOCKET="''${FLOW_SOCKET:-$XDG_RUNTIME_DIR/${ordinarySocket}}"
      export FLOW_META_SOCKET="''${FLOW_META_SOCKET:-$XDG_RUNTIME_DIR/${metaSocket}}"
      flowNexusAnswers=
      for _ in $(seq 1 300); do
        if ${client} 'List.{}' > /dev/null 2>&1 && ${metaClient} 'Retire.ffffff' > /dev/null 2>&1; then
          flowNexusAnswers=1
          break
        fi
        kill -0 "$flowNexusPid" 2>/dev/null || { echo "flow-nexus exited before binding:" >&2; cat "$flowNexusLog" >&2; exit 1; }
        sleep 0.1
      done
      if [ -z "$flowNexusAnswers" ]; then
        echo "flow-nexus never answered on $FLOW_SOCKET and $FLOW_META_SOCKET" >&2
        cat "$flowNexusLog" >&2
        exit 1
      fi
      echo "flow-nexus answering on both sockets (pid $flowNexusPid)"
    '';

    # Stops the Nexus with TERM and waits (bounded) for it to exit.
    stop = ''
      kill -TERM "$flowNexusPid" 2>/dev/null || true
      for _ in $(seq 1 100); do
        kill -0 "$flowNexusPid" 2>/dev/null || break
        sleep 0.1
      done
      if kill -0 "$flowNexusPid" 2>/dev/null; then
        echo "flow-nexus did not stop on TERM" >&2
        kill -9 "$flowNexusPid" 2>/dev/null || true
        exit 1
      fi
      wait "$flowNexusPid" 2>/dev/null || true
      echo "flow-nexus stopped on TERM"
    '';
  };
}

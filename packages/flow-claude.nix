# flow-claude — a gated semi-sandbox: a light-model Claude Code flow launched
# through Flow itself, against its own Flow Nexus. It needs the living's
# Claude login, the network and Herdr, so it is a runner, never a check, and
# it refuses to run unless FLOW_TEST_LIVE=1 is set. `nix flake check` only
# builds this script.
#
# What runs today, with the flag set: a fresh short `mktemp -d` root
# (removed in an exit trap), a Flow Nexus started on it with HOME and
# XDG_RUNTIME_DIR pointed into the root, a meta `Configure` naming the root's
# own sockets and source root and the Claude harness profile, and a `List.{}`
# that must answer `Listed.[]`. Then it stops, exit 3: the launch itself is
# not yet exercised.
#
# The launch, once Flow launches harnesses (the drive this runner grows into,
# after the semi-sandbox in flow 3ec648, witnesses/semi-sandbox-capsule.sh):
#   1. Copy only `~/.claude/.credentials.json` into the root's home; refuse
#      when its access token expires within 15 minutes.
#   2. Start a Herdr server on the root's runtime directory, so the launched
#      pane is the sandbox's own, never the living's session.
#   3. Send the ordinary `Start` with a LaunchProfile naming the Claude
#      harness, the cheapest model (FLOW_TEST_MODEL, default
#      flake.lib.cheapestModel.claude), one native skill, a source descriptor
#      with its exact SHA-256 under the root's source root, the root's Herdr
#      session, and a first instruction asking for one receipt.
#   4. Assert `Started` (never the transient ambiguity), then `List.{}`
#      showing the flow Active, then `Observe.Agent.<flow-id>` reaching Idle
#      or Done after the receipt.
#   5. `Stop.<flow-id>` and assert `Stopped`; the pane is gone and the row
#      stays, listed Stopped.
#   6. Bound the harness by MemoryMax=2G (systemd-run --user --scope), 600 s
#      and a turn cap; run the unwrapped Claude binary, never the installed
#      wrapper that prepends --dangerously-skip-permissions.
{
  pkgs,
  flake,
  system,
  ...
}:
let
  flow = flake.lib.components.flow.forSystem system;
in
pkgs.writeShellApplication {
  name = "flow-claude";

  runtimeInputs = [
    pkgs.coreutils
  ];

  meta.description = "Light-model Claude Code flow launched through its own Flow Nexus (gated: needs FLOW_TEST_LIVE=1; the launch step is documented, not yet run).";

  text = ''
    if [ "''${FLOW_TEST_LIVE:-}" != 1 ]; then
      echo "flow-claude: needs the living's Claude login, the network and Herdr; set FLOW_TEST_LIVE=1 to run it" >&2
      exit 2
    fi

    model="''${FLOW_TEST_MODEL:-${flake.lib.cheapestModel.claude}}"

    # A short root: sun_path holds 108 bytes.
    root="$(mktemp -d /tmp/ft-XXXXXXXX)"
    flowNexusPid=
    # Kill the Nexus and remove the root on every exit.
    trap 'if [ -n "$flowNexusPid" ]; then kill "$flowNexusPid" 2>/dev/null || true; wait "$flowNexusPid" 2>/dev/null || true; fi; rm -rf "$root"' EXIT

    export HOME="$root/home" XDG_RUNTIME_DIR="$root/run"
    mkdir -p "$HOME/primary"
    unset FLOW_SOCKET FLOW_META_SOCKET
    ${flow.start}

    configuration="{ $FLOW_SOCKET $FLOW_META_SOCKET $HOME/primary { /opt/stable-client /opt/stable /opt/stable/control.sock [ stable-model ] } { /opt/next-client /opt/next /opt/next/control.sock [ next-model ] } [ { Claude [ / «!» # ] [ esc esc ] [ enter ] } ] [ Psyche ] /opt/message-nexus }"
    reply="$(timeout 10 ${flow.metaClient} "Configure.$configuration")"
    test "$reply" = "Configured.{ $configuration NexusRestartRequired }" || { echo "flow-claude: Configure answered $reply" >&2; exit 1; }
    reply="$(timeout 10 ${flow.client} 'List.{}')"
    test "$reply" = 'Listed.[]' || { echo "flow-claude: List answered $reply" >&2; exit 1; }
    echo "flow-claude: Nexus configured on $root"

    echo "flow-claude: the $model launch through Flow is not yet exercised (steps 1-6 in packages/flow-claude.nix)" >&2
    exit 3
  '';
}

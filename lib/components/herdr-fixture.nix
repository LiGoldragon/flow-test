# A fixture Herdr: an executable named `herdr` that answers only
# `--session <name> api snapshot`, with one Claude agent at the pane and
# terminal named by FIXTURE_HERDR_PANE and FIXTURE_HERDR_TERMINAL in its
# environment, resting (`idle`). Everything else it refuses with exit 1.
#
# It stands in for the Herdr pane a launched flow would run in, so a
# semi-sandbox can register a flow with Flow (meta RegisterFlow checks the
# pane's binding in Herdr's snapshot) without a Herdr server. Put its `bin`
# first on the Nexus's PATH.
{ inputs }:
{
  name = "herdr-fixture";

  forSystem =
    system:
    let
      pkgs = inputs.nixpkgs.legacyPackages.${system};
    in
    {
      package = pkgs.writeShellApplication {
        name = "herdr";
        runtimeInputs = [ pkgs.jq ];
        text = ''
          if [ "$#" = 4 ] && [ "$1" = --session ] && [ "$3" = api ] && [ "$4" = snapshot ]; then
            jq -cn --arg pane "''${FIXTURE_HERDR_PANE:?}" --arg terminal "''${FIXTURE_HERDR_TERMINAL:?}" \
              '{ result: { snapshot: { agents: [ { pane_id: $pane, terminal_id: $terminal, agent: "claude", name: "sandbox-claude", agent_status: "idle" } ] } } }'
            exit 0
          fi
          echo "fixture herdr: only api snapshot is answered" >&2
          exit 1
        '';
      };
    };
}

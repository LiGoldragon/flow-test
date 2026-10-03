# A fixture Herdr: an executable named `herdr` standing in for the Herdr
# server a Flow-launched flow's pane lives in, so a semi-sandbox can drive
# Flow without one. Put its `bin` first on the Nexus's PATH.
#
# `--session <name> api snapshot` answers one Claude agent at the pane and
# terminal named by FIXTURE_HERDR_PANE and FIXTURE_HERDR_TERMINAL, resting
# (`idle`), and, once a launch has started one, the launched agent at its
# pane. That is what meta RegisterFlow and a launch's registration check.
#
# With FIXTURE_HERDR_STATE naming a directory, it also answers the launch
# stages Flow drives, in order, recording each under that directory:
#
#   workspace create   one workspace `fhw1`, root pane `fhw1:p1`, terminal
#                      `fhw-terminal-1`; the `--cwd` is kept (`cwd`)
#   pane run           keeps the line Flow typed at the pane's shell prompt
#                      (`pane-run`), unrun
#   pane wait-output   answers the `--match` marker as seen in the pane
#   agent start        starts the harness as Herdr would at that prompt: a
#                      shell that inherited FIXTURE_HERDR_INHERITED_FLOW_ID
#                      as FLOW_ID (the caller's identity a pane may carry),
#                      with the Herdr server's runtime directory
#                      FIXTURE_HERDR_RUNTIME_DIR (else the caller's) as
#                      XDG_RUNTIME_DIR and no FLOW_SOCKET, runs the kept line, records its environment
#                      (`harness-env`), then execs FIXTURE_HERDR_HARNESS with
#                      the agent arguments Flow passed, less
#                      `--remote-control <name>` (interactive only). It runs
#                      detached; `harness.pid`, `harness.exit`,
#                      `harness.out`, `harness.err` record it. The
#                      `--session-id` Flow passed is kept (`session`).
#   agent get          the started agent, interactive-ready, with that
#                      session as Herdr's integration reports it
#
# Everything else (the title `/rename`, pane labels, prompts) it refuses
# with exit 1: the stand-in stops a launch at Title.
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
        runtimeInputs = [
          pkgs.coreutils
          pkgs.jq
        ];
        text = ''
          refuse() {
            echo "fixture herdr: $*" >&2
            exit 1
          }
          [ "''${1:-}" = --session ] && [ "$#" -ge 4 ] || refuse "expected --session <name> <command>"
          shift 2
          state="''${FIXTURE_HERDR_STATE:-}"
          stage="$1 $2"
          shift 2
          case "$stage" in
            "api snapshot")
              launched='[]'
              if [ -n "$state" ] && [ -f "$state/agent-name" ]; then
                launched="$(jq -cn --arg name "$(cat "$state/agent-name")" \
                  '[ { pane_id: "fhw1:p1", terminal_id: "fhw-terminal-1", agent: "claude", name: $name, agent_status: "idle" } ]')"
              fi
              jq -cn --arg pane "''${FIXTURE_HERDR_PANE:?}" --arg terminal "''${FIXTURE_HERDR_TERMINAL:?}" \
                --argjson launched "$launched" \
                '{ result: { snapshot: { agents: ([ { pane_id: $pane, terminal_id: $terminal, agent: "claude", name: "sandbox-claude", agent_status: "idle" } ] + $launched) } } }'
              ;;
            "workspace create")
              [ -n "$state" ] || refuse "no FIXTURE_HERDR_STATE: launch stages are not answered"
              while [ "$#" -gt 0 ]; do
                if [ "$1" = --cwd ]; then printf '%s' "$2" > "$state/cwd"; fi
                shift
              done
              echo '{"result":{"workspace":{"workspace_id":"fhw1"},"root_pane":{"pane_id":"fhw1:p1","terminal_id":"fhw-terminal-1"}}}'
              ;;
            "pane run")
              [ -n "$state" ] || refuse "no FIXTURE_HERDR_STATE"
              printf '%s' "$2" > "$state/pane-run"
              ;;
            "pane wait-output")
              pane="$1"
              marker=
              while [ "$#" -gt 0 ]; do
                if [ "$1" = --match ]; then marker="$2"; fi
                shift
              done
              jq -cn --arg pane "$pane" --arg marker "$marker" '{ result: { pane_id: $pane, matched_line: $marker } }'
              ;;
            "agent start")
              [ -n "$state" ] || refuse "no FIXTURE_HERDR_STATE"
              name="$1"
              shift
              while [ "$#" -gt 0 ] && [ "$1" != -- ]; do shift; done
              [ "$#" -gt 0 ] || refuse "agent start without --"
              shift
              set -- "$@" END
              session=
              while [ "$1" != END ]; do
                case "$1" in
                  --remote-control) shift 2; continue ;;
                  --session-id) session="$2" ;;
                esac
                set -- "$@" "$1"
                shift
              done
              shift
              printf '%s' "$name" > "$state/agent-name"
              printf '%s' "$session" > "$state/session"
              printf '%s\n' "$@" > "$state/harness-arguments"
              # shellcheck disable=SC2016
              (cd "$(cat "$state/cwd")" && env -u FLOW_SOCKET FLOW_ID="''${FIXTURE_HERDR_INHERITED_FLOW_ID:-}" \
                XDG_RUNTIME_DIR="''${FIXTURE_HERDR_RUNTIME_DIR:-''${XDG_RUNTIME_DIR:-}}" \
                sh -c 'eval "$(cat "$0/pane-run")" > "$0/pane-output" && env > "$0/harness-env" && "''${FIXTURE_HERDR_HARNESS:?}" "$@"; echo "$?" > "$0/harness.exit"' \
                "$state" "$@" < /dev/null > "$state/harness.out" 2> "$state/harness.err" &
                echo "$!" > "$state/harness.pid")
              jq -cn --arg name "$name" '{ result: { agent: { name: $name } } }'
              ;;
            "agent get")
              [ -n "$state" ] && [ -f "$state/agent-name" ] || refuse "no started agent"
              jq -cn --arg name "$(cat "$state/agent-name")" --arg session "$(cat "$state/session")" \
                '{ result: { agent: { name: $name, agent: "claude", workspace_id: "fhw1", pane_id: "fhw1:p1", terminal_id: "fhw-terminal-1", interactive_ready: true, agent_session: { source: "herdr:claude", agent: "claude", kind: "id", value: $session } } } }'
              ;;
            *)
              refuse "$stage is not answered"
              ;;
          esac
        '';
      };
    };
}

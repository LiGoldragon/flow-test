# The Flow harness hook: `flow-hook` from the pinned flow package, and the
# Claude Code settings that run it. They are the hooks Flow writes into
# every Claude flow it launches (flow 0.21.0, `claude_flag_settings`):
# SessionStart, every PostToolUse and Stop, each running `flow-hook`, which
# reads the event on stdin and calls `flow` with one
# `Report.{ «FLOW_ID» Event }`, the FlowId taken from FLOW_ID in its
# environment. It always exits 0 and writes one tab-separated record on
# stderr: event, datom, flow's exit code, flow's whole output.
{ inputs }:
{
  name = "flow-hook";

  forSystem =
    system:
    let
      flow = inputs.flow.packages.${system}.default;
    in
    rec {
      command = "${flow}/bin/flow-hook";

      # `prefix` is shell put in front of the command (a scenario's witness
      # tap); `suffix` follows it. Without both, these are Flow's own hooks.
      settings =
        {
          prefix ? "",
          suffix ? "",
        }:
        let
          hook = [
            {
              hooks = [
                {
                  type = "command";
                  command = "${prefix}${command}${suffix}";
                }
              ];
            }
          ];
        in
        builtins.toJSON {
          hooks = {
            SessionStart = hook;
            PostToolUse = map (entry: entry // { matcher = "*"; }) hook;
            Stop = hook;
          };
        };
    };
}

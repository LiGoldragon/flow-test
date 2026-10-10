# Bind under an address whose bound process is gone (its pid and start
# time no longer name a live process) replaces the binding: Bound.FlowId;
# Current is then Awake with the new FlowId.
# Target: mind.
{
  pkgs,
  flake,
  system,
  ...
}:
flake.lib.flowScenario { inherit pkgs flake system; } {
  name = "flow-bind-rebind";
  target = "mind";
  script = ''
    configure()
    pane, _ = open_pane("mind")
    in_pane(pane, "sleep 600 & echo $! > /tmp/first")
    first = int(machine.succeed("cat /tmp/first").strip())
    bind("{ Mind nexus Secondary }", first)
    machine.succeed(f"kill {first}; while kill -0 {first} 2>/dev/null; do sleep 0.1; done")
    _, second = open_pane("again")
    flow_id = bind("{ Mind nexus Secondary }", second)
    expect("Current after the rebind", flow("Current.{ Mind nexus Secondary }"), f"Current.Awake.{flow_id}")
  '';
}

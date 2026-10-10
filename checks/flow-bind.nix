# Bind.{ Address Process } of a running shell: Bound.FlowId; the metaflow
# is then Awake with that FlowId, and the shell identifies as its address.
# Target: mind.
{
  pkgs,
  flake,
  system,
  ...
}:
flake.lib.flowScenario { inherit pkgs flake system; } {
  name = "flow-bind";
  target = "mind";
  script = ''
    configure()
    _, pid = open_pane("mind")
    flow_id = bind("{ Mind nexus Secondary }", pid)
    expect("Current", flow("Current.{ Mind nexus Secondary }"), f"Current.Awake.{flow_id}")
    expect("Identify", flow(f"Identify.{process(pid)}"), "Identified.{ Mind nexus Secondary }")
  '';
}

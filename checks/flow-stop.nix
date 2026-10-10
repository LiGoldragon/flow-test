# Stop.FlowId reaps a bound flow with no successor: Stopped, and the
# metaflow is left Asleep (only End ends it).
# Target: mind.
{
  pkgs,
  flake,
  system,
  ...
}:
flake.lib.flowScenario { inherit pkgs flake system; } {
  name = "flow-stop";
  target = "mind";
  script = ''
    configure()
    _, _, flow_id = awake("{ Mind nexus Secondary }", "mind")
    expect("Stop", flow(f"Stop.{flow_id}"), "Stopped")
    expect("Current after Stop", flow("Current.{ Mind nexus Secondary }"), "Current.Asleep")
  '';
}

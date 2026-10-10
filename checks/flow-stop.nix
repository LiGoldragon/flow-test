# Stop.FlowId reaps a bound flow with no successor: Stopped.
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
  '';
}

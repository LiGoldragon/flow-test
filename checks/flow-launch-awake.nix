# Launch of an awake metaflow: Refused.Awake.FlowId, carrying its current
# flow (the FlowId Bind answered).
# Target: mind.
{
  pkgs,
  flake,
  system,
  ...
}:
flake.lib.flowScenario { inherit pkgs flake system; } {
  name = "flow-launch-awake";
  target = "mind";
  script = ''
    configure()
    expect("Configure.Module", meta(module_payload(module_hash())), "Configured")
    _, _, flow_id = awake("{ Mind nexus Secondary }", "mind")
    expect("Launch awake", flow("Launch.{ { Mind nexus Secondary } [ { Vision flow } ] «Design nothing.» }"), f"Refused.Awake.{flow_id}")
  '';
}

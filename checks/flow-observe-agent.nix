# Observe.Agent.FlowId for a bound flow: Observed.Agent.String, Herdr's
# agent state of its pane.
# Target: mind.
{
  pkgs,
  flake,
  system,
  ...
}:
flake.lib.flowScenario { inherit pkgs flake system; } {
  name = "flow-observe-agent";
  target = "mind";
  script = ''
    configure()
    _, _, flow_id = awake("{ Mind nexus Secondary }", "mind")
    expect_prefix("Observe.Agent", flow(f"Observe.Agent.{flow_id}"), "Observed.Agent.")
  '';
}

# Observe.Agent.FlowId for a bound flow: Observed.Agent.[ Working Idle Done Absent ], Herdr's
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
    states = ["Working", "Idle", "Done", "Absent"]
    expect_match("Observe.Agent", flow(f"Observe.Agent.{flow_id}"), r"Observed\.Agent\.(" + "|".join(states) + ")")
  '';
}

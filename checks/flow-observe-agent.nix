# Observe.Agent.FlowId for a bound flow: Observed.Agent.[ Working Idle Done Absent ], Herdr's
# agent state of its pane.
# Target: mind.
args@{ flake, ... }:
flake.lib.flowScenario args {
  name = "flow-observe-agent";
  target = "mind";
  script = ''
    configure()
    _, _, flow_id = awake("{ Mind nexus Secondary }", "mind")
    states = ["Working", "Idle", "Done", "Absent"]
    expect_match("Observe.Agent", flow(f"Observe.Agent.{flow_id}"), r"Observed\.Agent\.(" + "|".join(states) + ")")
  '';
}

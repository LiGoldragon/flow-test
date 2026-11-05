# Observe.Agent for a FlowId Flow does not hold: Refused.Unknown.FlowId.
# Target: mind.
args@{ flake, ... }:
flake.lib.flowScenario args {
  name = "flow-observe-agent-unknown";
  target = "mind";
  script = ''
    configure()
    expect("Observe.Agent ghost", flow("Observe.Agent.ghost1"), "Refused.Unknown.FlowId.ghost1")
  '';
}

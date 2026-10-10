# Observe.Agent for a FlowId Flow does not hold: Refused.Unknown.FlowId.
# Target: mind.
{
  pkgs,
  flake,
  system,
  ...
}:
flake.lib.flowScenario { inherit pkgs flake system; } {
  name = "flow-observe-agent-unknown";
  target = "mind";
  script = ''
    configure()
    expect("Observe.Agent ghost", flow("Observe.Agent.ghost1"), "Refused.Unknown.ghost1")
  '';
}

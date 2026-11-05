# Stop of a FlowId Flow does not hold: Refused.Unknown.FlowId.
# Target: mind.
args@{ flake, ... }:
flake.lib.flowScenario args {
  name = "flow-stop-unknown";
  target = "mind";
  script = ''
    configure()
    expect("Stop ghost", flow("Stop.ghost1"), "Refused.Unknown.FlowId.ghost1")
  '';
}

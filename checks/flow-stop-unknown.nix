# Stop of a FlowId Flow does not hold: Refused.Unknown.FlowId.
# Target: mind.
{
  pkgs,
  flake,
  system,
  ...
}:
flake.lib.flowScenario { inherit pkgs flake system; } {
  name = "flow-stop-unknown";
  target = "mind";
  script = ''
    configure()
    expect("Stop ghost", flow("Stop.ghost1"), "Refused.Unknown.ghost1")
  '';
}

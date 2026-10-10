# Report for a FlowId Flow does not hold: Refused.Unknown.FlowId.
# Target: mind.
{
  pkgs,
  flake,
  system,
  ...
}:
flake.lib.flowScenario { inherit pkgs flake system; } {
  name = "flow-report-unknown";
  target = "mind";
  script = ''
    configure()
    expect("Report ghost", flow("Report.{ ghost1 Started }"), "Refused.Unknown.ghost1")
  '';
}

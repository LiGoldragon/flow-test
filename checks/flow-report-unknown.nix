# Report for a FlowId Flow does not hold: Refused.Unknown.FlowId.
# Target: mind.
args@{ flake, ... }:
flake.lib.flowScenario args {
  name = "flow-report-unknown";
  target = "mind";
  script = ''
    configure()
    expect("Report ghost", flow("Report.{ ghost1 Started }"), "Refused.Unknown.FlowId.ghost1")
  '';
}

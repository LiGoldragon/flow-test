# Refresh of an Ended metaflow: Refused.Ended.{ Mind refresh Secondary }.
# Target: mind.
args@{ flake, ... }:
flake.lib.flowScenario args {
  name = "flow-refresh-ended";
  target = "mind";
  script = ''
    configure()
    awake("{ Mind refresh Secondary }", "refresh")
    expect("End", flow("End.{ Mind refresh Secondary }"), "Ended")
    expect("Refresh ended", flow("Refresh.{ Mind refresh Secondary }"), "Refused.Ended.{ Mind refresh Secondary }")
  '';
}

# End of an Ended metaflow: Refused.Ended.{ Mind nexus Secondary }.
# Target: mind.
args@{ flake, ... }:
flake.lib.flowScenario args {
  name = "flow-end-ended";
  target = "mind";
  script = ''
    configure()
    awake("{ Mind nexus Secondary }", "mind")
    expect("End", flow("End.{ Mind nexus Secondary }"), "Ended")
    expect("End again", flow("End.{ Mind nexus Secondary }"), "Refused.Ended.{ Mind nexus Secondary }")
  '';
}

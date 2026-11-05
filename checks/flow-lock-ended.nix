# Lock on an Ended metaflow: Refused.Ended.{ Mind nexus Secondary }.
# Target: mind.
args@{ flake, ... }:
flake.lib.flowScenario args {
  name = "flow-lock-ended";
  target = "mind";
  script = ''
    configure()
    awake(PSYCHE, "psyche")
    awake("{ Mind nexus Secondary }", "mind")
    expect("End", flow("End.{ Mind nexus Secondary }"), "Ended")
    expect_message("Lock ended", lock_datom(PSYCHE, "{ Mind nexus Secondary }"), "Refused.Ended.{ Mind nexus Secondary }")
  '';
}

# Lock on an Ended metaflow: Refused.Ended.{ Mind nexus Secondary }.
# Target: mind.
{
  pkgs,
  flake,
  system,
  ...
}:
flake.lib.flowScenario { inherit pkgs flake system; } {
  name = "flow-lock-ended";
  target = "mind";
  script = ''
    configure()
    awake(PSYCHE, "psyche")
    awake("{ Mind nexus Secondary }", "mind")
    expect("End", flow("End.{ Mind nexus Secondary }"), "Ended")
    expect("Lock ended", flow(lock_datom(PSYCHE, "{ Mind nexus Secondary }")), "Refused.Ended.{ Mind nexus Secondary }")
  '';
}

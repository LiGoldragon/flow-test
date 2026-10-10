# End of an Ended metaflow: Refused.Ended.{ Mind nexus Secondary }.
# Target: mind.
{
  pkgs,
  flake,
  system,
  ...
}:
flake.lib.flowScenario { inherit pkgs flake system; } {
  name = "flow-end-ended";
  target = "mind";
  script = ''
    configure()
    awake("{ Mind nexus Secondary }", "mind")
    expect("End", flow("End.{ Mind nexus Secondary }"), "Ended")
    expect("End again", flow("End.{ Mind nexus Secondary }"), "Refused.Ended.{ Mind nexus Secondary }")
  '';
}

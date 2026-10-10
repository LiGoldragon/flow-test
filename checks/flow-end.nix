# End of an awake metaflow: Ended; Current is then Current.Ended and
# Metaflows lists it Ended.
# Target: mind.
{
  pkgs,
  flake,
  system,
  ...
}:
flake.lib.flowScenario { inherit pkgs flake system; } {
  name = "flow-end";
  target = "mind";
  script = ''
    configure()
    awake("{ Mind nexus Secondary }", "mind")
    expect("End", flow("End.{ Mind nexus Secondary }"), "Ended")
    expect("Current after End", flow("Current.{ Mind nexus Secondary }"), "Current.Ended")
    expect("Metaflows", flow("Metaflows"), "Listed.[ { { Mind nexus Secondary } Ended [] [] } ]")
  '';
}

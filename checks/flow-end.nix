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
    listed = expect_prefix("Metaflows", flow("Metaflows"), "Listed.")
    expect_true("listed Ended", "{ Mind nexus Secondary } Ended" in listed, listed)
  '';
}

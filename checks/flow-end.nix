# End of an awake metaflow: Ended; Current is then Current.Ended and
# Metaflows lists it Ended, its flow's id moved into Past, its queue empty.
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
    _, _, flow_id = awake("{ Mind nexus Secondary }", "mind")
    expect("End", flow("End.{ Mind nexus Secondary }"), "Ended")
    expect("Current after End", flow("Current.{ Mind nexus Secondary }"), "Current.Ended")
    expect("Metaflows", flow("Metaflows"), f"Listed.[ {{ {{ Mind nexus Secondary }} Ended [ {flow_id} ] [] }} ]")
  '';
}

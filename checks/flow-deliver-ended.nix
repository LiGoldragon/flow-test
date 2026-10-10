# Deliver under a lock taken before the metaflow ended:
# Refused.Ended.{ Mind nexus Secondary }, and the pane never shows it.
# Target: mind.
{
  pkgs,
  flake,
  system,
  ...
}:
flake.lib.flowScenario { inherit pkgs flake system; } {
  name = "flow-deliver-ended";
  target = "mind";
  script = ''
    configure()
    awake("{ Psyche nexus Secondary }", "psyche")
    pane, _, _ = awake("{ Mind nexus Secondary }", "mind")
    held, _ = lock("{ Mind nexus Secondary }")
    expect("End", flow("End.{ Mind nexus Secondary }"), "Ended")
    expect("Deliver", flow(f"Deliver.{{ {held} {{ Psyche nexus Secondary }} Order.«ftDeliverEnded» }}"), "Refused.Ended.{ Mind nexus Secondary }")
  '';
}

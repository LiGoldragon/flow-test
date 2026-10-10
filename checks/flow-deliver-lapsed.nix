# Deliver under a lock whose Until has passed: Refused.Lapsed, and the
# recipient's pane never shows the request.
# Target: mind.
{
  pkgs,
  flake,
  system,
  ...
}:
flake.lib.flowScenario { inherit pkgs flake system; } {
  name = "flow-deliver-lapsed";
  target = "mind";
  script = ''
    configure()
    awake("{ Psyche nexus Secondary }", "psyche")
    pane, _, _ = awake("{ Mind nexus Secondary }", "mind")
    held, until = lock("{ Mind nexus Secondary }")
    set_clock_past(until)
    expect("Deliver", flow(f"Deliver.{{ {held} {{ Psyche nexus Secondary }} Order.«ftDeliverLapsed» }}"), "Refused.Lapsed")
    pane_lacks("recipient pane", pane, "ftDeliverLapsed")
  '';
}

# Deliver under a lock whose Until has passed: Refused.Lapsed, and the
# recipient's pane never shows the request.
# Target: mind.
args@{ flake, ... }:
flake.lib.flowScenario args {
  name = "flow-deliver-lapsed";
  target = "mind";
  script = ''
    configure()
    awake(PSYCHE, "psyche")
    pane, _, _ = awake("{ Mind nexus Secondary }", "mind")
    held, until = lock(PSYCHE, "{ Mind nexus Secondary }")
    set_clock_past(until)
    expect_message("Deliver", deliver(held, "Order.ftDeliverLapsed"), "Refused.Lapsed")
    pane_lacks("recipient pane", pane, "ftDeliverLapsed")
  '';
}

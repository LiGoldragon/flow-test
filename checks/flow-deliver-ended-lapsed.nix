# A lock that lapsed while its recipient was ended: the lock lapses, End
# is then accepted (no lock is held), and a Deliver under the lapsed lock
# is refused Lapsed, not Ended.Address.
# Target: mind.
{
  pkgs,
  flake,
  system,
  ...
}:
flake.lib.flowScenario { inherit pkgs flake system; } {
  name = "flow-deliver-ended-lapsed";
  target = "mind";
  script = ''
    configure()
    awake(PSYCHE, "psyche")
    awake("{ Mind nexus Secondary }", "mind")
    held, until = lock(PSYCHE, "{ Mind nexus Secondary }")
    set_clock_past(until)
    expect("End after the lapse", flow("End.{ Mind nexus Secondary }"), "Ended")
    expect_message("Deliver under the lapsed lock", deliver(held, "Order.ftEndedLapsed"), "Refused.Lapsed")
  '';
}

# Deliver.{ Lock Request } under a lock from { Psyche nexus Secondary } to
# the awake { Mind nexus Secondary }: Delivered, and the request reaches the
# recipient's pane (where in the flow it lands is open, book 17 ruling 3, so
# only its words are looked for). The Deliver ends the lock: a second
# Deliver under it is Refused.Unknown.Lock, and a new Lock is granted.
# Target: mind.
{
  pkgs,
  flake,
  system,
  ...
}:
flake.lib.flowScenario { inherit pkgs flake system; } {
  name = "flow-deliver-awake";
  target = "mind";
  script = ''
    configure()
    awake(PSYCHE, "psyche")
    pane, _, _ = awake("{ Mind nexus Secondary }", "mind")
    held, _ = lock(PSYCHE, "{ Mind nexus Secondary }")
    expect_message("Deliver", deliver(held, "Order.«ftDelivered build the lock path»"), "Delivered")
    pane_shows("recipient pane", pane, "ftDelivered")
    expect_message("second Deliver", deliver(held, "Order.ftDeliveredTwice"), f"Refused.Unknown.Lock.{held}")
    lock(PSYCHE, "{ Mind nexus Secondary }", "Lock after the Deliver")
  '';
}

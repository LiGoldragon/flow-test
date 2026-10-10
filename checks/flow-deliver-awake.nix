# Deliver.{ Lock Request } under a lock from { Psyche nexus Secondary } to
# the awake { Mind nexus Secondary } (same layer, shared topic: on route):
# Delivered, and the request reaches the recipient's pane. Where in the flow
# it lands is open (book 17, ruling 3), so only its words are looked for.
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
    expect("Deliver", deliver(held, "Order.«ftDelivered build the lock path»"), "Delivered")
    pane_shows("recipient pane", pane, "ftDelivered")
  '';
}

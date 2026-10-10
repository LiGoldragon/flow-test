# From { Field ghost Tertiary } to { Psyche core Primary }: another aspect,
# another layer, another topic, off the vision-aspects routes:
# Refused.OffRoute, at the Lock (which carries both Sender and Recipient)
# or, if the Lock is granted, at the Deliver; the recipient's pane never
# shows the request.
# Target: mind.
{
  pkgs,
  flake,
  system,
  ...
}:
flake.lib.flowScenario { inherit pkgs flake system; } {
  name = "flow-deliver-off-route";
  target = "mind";
  script = ''
    configure()
    awake("{ Field ghost Tertiary }", "field")
    pane, _, _ = awake("{ Psyche core Primary }", "psyche")
    status, reply = run(flow(lock_datom("{ Field ghost Tertiary }", "{ Psyche core Primary }")))
    if reply.startswith("Locked."):
        judge("Lock", reply, status, True, "")
        held, _ = lock_of(reply)
        expect("Deliver", deliver(held, "Order.«ftOffRoute»"), "Refused.OffRoute")
    else:
        judge("Lock", reply, status, reply == "Refused.OffRoute", "«Refused.OffRoute»")
    pane_lacks("recipient pane", pane, "ftOffRoute")
  '';
}

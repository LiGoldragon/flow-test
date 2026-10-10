# Deliver under a lock never granted: Refused.Unknown.Lock, and the pane
# never shows the request.
# Target: mind.
{
  pkgs,
  flake,
  system,
  ...
}:
flake.lib.flowScenario { inherit pkgs flake system; } {
  name = "flow-deliver-unknown-lock";
  target = "mind";
  script = ''
    configure()
    awake(PSYCHE, "psyche")
    pane, _, _ = awake("{ Mind nexus Secondary }", "mind")
    forged = f"{{ {PSYCHE} {{ Mind nexus Secondary }} 4102444800 }}"
    expect("Deliver under a forged lock", deliver(forged, "Order.«ftForged»"), f"Refused.Unknown.Lock.{forged}")
    pane_lacks("recipient pane", pane, "ftForged")
  '';
}

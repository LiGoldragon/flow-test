# Refresh while a lock is held: Refused.Held.Lock, carrying the held lock.
# Target: mind.
{
  pkgs,
  flake,
  system,
  ...
}:
flake.lib.flowScenario { inherit pkgs flake system; } {
  name = "flow-refresh-held";
  target = "mind";
  script = ''
    configure()
    awake(PSYCHE, "psyche")
    awake("{ Mind nexus Secondary }", "mind")
    held, _ = lock(PSYCHE, "{ Mind nexus Secondary }")
    expect("Refresh held", flow("Refresh.{ Mind nexus Secondary }"), f"Refused.Held.{held}")
  '';
}

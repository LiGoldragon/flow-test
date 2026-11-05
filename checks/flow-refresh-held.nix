# Refresh while a lock is held: Refused.Held.Lock, carrying the held lock.
# Target: mind.
args@{ flake, ... }:
flake.lib.flowScenario args {
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

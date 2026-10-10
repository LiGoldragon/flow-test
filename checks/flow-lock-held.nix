# A second Lock on a locked metaflow: Refused.Held.Lock, carrying the held
# lock. Once the clock passes its Until, the lapsed lock is released by Flow
# and a Lock is granted again.
# Target: mind.
{
  pkgs,
  flake,
  system,
  ...
}:
flake.lib.flowScenario { inherit pkgs flake system; } {
  name = "flow-lock-held";
  target = "mind";
  script = ''
    configure()
    awake(PSYCHE, "psyche")
    awake("{ Mind nexus Secondary }", "mind")
    held, until = lock(PSYCHE, "{ Mind nexus Secondary }", "first Lock")
    expect_message("second Lock", lock_datom(PSYCHE, "{ Mind nexus Secondary }"), f"Refused.Held.{held}")
    set_clock_past(until)
    lock(PSYCHE, "{ Mind nexus Secondary }", "Lock after the lapse")
  '';
}

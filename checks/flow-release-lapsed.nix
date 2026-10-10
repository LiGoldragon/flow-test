# Release of a lapsed lock: Refused.Lapsed.
# Target: mind.
{
  pkgs,
  flake,
  system,
  ...
}:
flake.lib.flowScenario { inherit pkgs flake system; } {
  name = "flow-release-lapsed";
  target = "mind";
  script = ''
    configure()
    awake(PSYCHE, "psyche")
    awake("{ Mind nexus Secondary }", "mind")
    held, until = lock(PSYCHE, "{ Mind nexus Secondary }")
    set_clock_past(until)
    expect("Release lapsed", flow(f"Release.{held}"), "Refused.Lapsed")
  '';
}

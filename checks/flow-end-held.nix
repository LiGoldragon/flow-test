# End while a lock is held: Refused.Held.Lock; after Release, End proceeds:
# Ended.
# Target: mind.
{
  pkgs,
  flake,
  system,
  ...
}:
flake.lib.flowScenario { inherit pkgs flake system; } {
  name = "flow-end-held";
  target = "mind";
  script = ''
    configure()
    awake(PSYCHE, "psyche")
    awake("{ Mind nexus Secondary }", "mind")
    held, _ = lock(PSYCHE, "{ Mind nexus Secondary }")
    expect("End held", flow("End.{ Mind nexus Secondary }"), f"Refused.Held.{held}")
    expect("Release", flow(f"Release.{held}"), "Released")
    expect("End after Release", flow("End.{ Mind nexus Secondary }"), "Ended")
  '';
}

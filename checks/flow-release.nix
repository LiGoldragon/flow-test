# Release of a held lock: Released, and a Lock on the metaflow is then
# granted rather than refused Held.
# Target: mind.
{
  pkgs,
  flake,
  system,
  ...
}:
flake.lib.flowScenario { inherit pkgs flake system; } {
  name = "flow-release";
  target = "mind";
  script = ''
    configure()
    awake(PSYCHE, "psyche")
    awake("{ Mind nexus Secondary }", "mind")
    held, _ = lock(PSYCHE, "{ Mind nexus Secondary }")
    expect("Release", flow(f"Release.{held}"), "Released")
    lock(PSYCHE, "{ Mind nexus Secondary }", "Lock after Release")
  '';
}

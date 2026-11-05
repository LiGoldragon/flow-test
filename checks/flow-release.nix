# Release of a held lock: Released, and a Lock on the metaflow is then
# granted rather than refused Held.
# Target: mind.
args@{ flake, ... }:
flake.lib.flowScenario args {
  name = "flow-release";
  target = "mind";
  script = ''
    configure()
    awake(PSYCHE, "psyche")
    awake("{ Mind nexus Secondary }", "mind")
    held, _ = lock(PSYCHE, "{ Mind nexus Secondary }")
    expect_message("Release", f"Release.{held}", "Released")
    lock(PSYCHE, "{ Mind nexus Secondary }", "Lock after Release")
  '';
}

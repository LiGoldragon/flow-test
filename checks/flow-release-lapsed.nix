# Release of a lapsed lock: Refused.Lapsed.
# Target: mind.
args@{ flake, ... }:
flake.lib.flowScenario args {
  name = "flow-release-lapsed";
  target = "mind";
  script = ''
    configure()
    awake(PSYCHE, "psyche")
    awake("{ Mind nexus Secondary }", "mind")
    held, until = lock(PSYCHE, "{ Mind nexus Secondary }")
    set_clock_past(until)
    expect_message("Release lapsed", f"Release.{held}", "Refused.Lapsed")
  '';
}

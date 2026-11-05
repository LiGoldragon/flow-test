# Release of a lock never granted: Refused.Unknown.Lock.
# Target: mind.
args@{ flake, ... }:
flake.lib.flowScenario args {
  name = "flow-release-unknown";
  target = "mind";
  script = ''
    configure()
    awake(PSYCHE, "psyche")
    awake("{ Mind nexus Secondary }", "mind")
    forged = f"{{ {PSYCHE} {{ Mind nexus Secondary }} 4102444800 }}"
    expect_message("Release forged", f"Release.{forged}", f"Refused.Unknown.Lock.{forged}")
  '';
}

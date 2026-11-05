# Release after the lock's Deliver: Refused.Unknown.Lock (the Deliver ended
# it).
# Target: mind.
args@{ flake, ... }:
flake.lib.flowScenario args {
  name = "flow-release-after-deliver";
  target = "mind";
  script = ''
    configure()
    awake(PSYCHE, "psyche")
    awake("{ Mind nexus Secondary }", "mind")
    held, _ = lock(PSYCHE, "{ Mind nexus Secondary }")
    expect_message("Deliver", deliver(held, "Order.ftReleaseAfter"), "Delivered")
    expect_message("Release after Deliver", f"Release.{held}", f"Refused.Unknown.Lock.{held}")
  '';
}

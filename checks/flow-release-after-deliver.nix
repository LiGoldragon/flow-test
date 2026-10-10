# Release after the lock's Deliver: Refused.Unknown.Lock (the Deliver ended
# it).
# Target: mind.
{
  pkgs,
  flake,
  system,
  ...
}:
flake.lib.flowScenario { inherit pkgs flake system; } {
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

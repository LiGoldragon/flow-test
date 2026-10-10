# Lock to an Asleep recipient is granted: Locked.{ Sender Address Until }
# carrying the recipient's address.
# Target: mind.
{
  pkgs,
  flake,
  system,
  ...
}:
flake.lib.flowScenario { inherit pkgs flake system; } {
  name = "flow-lock-asleep-recipient";
  target = "mind";
  script = ''
    configure()
    awake(PSYCHE, "psyche")
    asleep("{ Mind nexus Secondary }", "mind")
    held, until = lock(PSYCHE, "{ Mind nexus Secondary }")
    expect_true("the lock is { Sender Address Until }", held == f"{{ {PSYCHE} {{ Mind nexus Secondary }} {until} }}", held)
  '';
}

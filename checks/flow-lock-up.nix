# Lock.{ Sender Up } with Sender { Mind nexus Secondary }: Flow resolves Up
# relative to the Sender, the layer above within its aspect, and answers
# Locked.Lock carrying { Mind nexus Primary }.
# Target: mind.
{
  pkgs,
  flake,
  system,
  ...
}:
flake.lib.flowScenario { inherit pkgs flake system; } {
  name = "flow-lock-up";
  target = "mind";
  script = ''
    configure()
    awake("{ Mind nexus Primary }", "primary")
    awake("{ Mind nexus Secondary }", "secondary")
    held, until = lock("{ Mind nexus Secondary }", "Up")
    expect_true("the lock is { Sender Address Until }, Address resolved", held == f"{{ {{ Mind nexus Secondary }} {{ Mind nexus Primary }} {until} }}", held)
  '';
}

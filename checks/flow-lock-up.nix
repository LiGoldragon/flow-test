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
    held, _ = lock("{ Mind nexus Secondary }", "Up")
    expect_true("the lock carries the resolved Address", "{ Mind nexus Primary }" in held, held)
  '';
}

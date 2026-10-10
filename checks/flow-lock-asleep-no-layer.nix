# Lock to an Asleep recipient checks the wake's preconditions before
# granting: with no Model for the recipient's layer (only Primary has one),
# the Lock is refused NoLayer.
# Target: mind.
{
  pkgs,
  flake,
  system,
  ...
}:
flake.lib.flowScenario { inherit pkgs flake system; } {
  name = "flow-lock-asleep-no-layer";
  target = "mind";
  script = ''
    configure(layers=["Primary"])
    awake(PSYCHE, "psyche")
    asleep("{ Mind nexus Secondary }", "mind")
    expect_message("Lock to an asleep recipient with no Model", lock_datom(PSYCHE, "{ Mind nexus Secondary }"), "Refused.NoLayer")
  '';
}

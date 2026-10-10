# Wake of an Ended metaflow: Refused.Ended.{ Mind wake Secondary }
# (the request returns to its sender).
# Target: mind.
{
  pkgs,
  flake,
  system,
  ...
}:
flake.lib.flowScenario { inherit pkgs flake system; } {
  name = "flow-wake-ended";
  target = "mind";
  script = ''
    configure()
    awake("{ Mind wake Secondary }", "wake")
    expect("End", flow("End.{ Mind wake Secondary }"), "Ended")
    expect("Wake ended", flow("Wake.{ { Mind wake Secondary } Order.«ftWakeEnded» }"), "Refused.Ended.{ Mind wake Secondary }")
  '';
}

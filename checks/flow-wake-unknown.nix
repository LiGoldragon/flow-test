# Wake of a metaflow that does not exist:
# Refused.Unknown.{ Mind ghost Secondary }.
# Target: mind.
{
  pkgs,
  flake,
  system,
  ...
}:
flake.lib.flowScenario { inherit pkgs flake system; } {
  name = "flow-wake-unknown";
  target = "mind";
  script = ''
    configure()
    expect("Wake ghost", flow("Wake.{ { Mind ghost Secondary } Order.«ftWakeUnknown» }"), "Refused.Unknown.{ Mind ghost Secondary }")
  '';
}

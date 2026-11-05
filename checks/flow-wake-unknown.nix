# Wake of a metaflow that does not exist:
# Refused.Unknown.Address.{ Mind ghost Secondary }.
# Target: mind.
args@{ flake, ... }:
flake.lib.flowScenario args {
  name = "flow-wake-unknown";
  target = "mind";
  script = ''
    configure()
    expect("Wake ghost", flow("Wake.{ { Mind ghost Secondary } Order.ftWakeUnknown }"), "Refused.Unknown.Address.{ Mind ghost Secondary }")
  '';
}

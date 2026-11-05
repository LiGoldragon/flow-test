# Refresh of a metaflow that does not exist:
# Refused.Unknown.Address.{ Mind ghost Secondary }.
# Target: mind.
args@{ flake, ... }:
flake.lib.flowScenario args {
  name = "flow-refresh-unknown";
  target = "mind";
  script = ''
    configure()
    expect("Refresh ghost", flow("Refresh.{ Mind ghost Secondary }"), "Refused.Unknown.Address.{ Mind ghost Secondary }")
  '';
}

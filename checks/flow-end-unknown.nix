# End of a metaflow that does not exist:
# Refused.Unknown.Address.{ Mind ghost Secondary }.
# Target: mind.
args@{ flake, ... }:
flake.lib.flowScenario args {
  name = "flow-end-unknown";
  target = "mind";
  script = ''
    configure()
    expect("End ghost", flow("End.{ Mind ghost Secondary }"), "Refused.Unknown.Address.{ Mind ghost Secondary }")
  '';
}

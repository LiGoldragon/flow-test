# Lock on a metaflow that does not exist:
# Refused.Unknown.{ Mind ghost Secondary }.
# Target: mind.
{
  pkgs,
  flake,
  system,
  ...
}:
flake.lib.flowScenario { inherit pkgs flake system; } {
  name = "flow-lock-unknown";
  target = "mind";
  script = ''
    configure()
    expect("Lock ghost", flow("Lock.Address.{ Mind ghost Secondary }"), "Refused.Unknown.{ Mind ghost Secondary }")
  '';
}

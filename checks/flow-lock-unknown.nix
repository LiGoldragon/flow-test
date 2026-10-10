# Lock on a metaflow that does not exist:
# Refused.Unknown.Address.{ Mind ghost Secondary }.
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
    awake(PSYCHE, "psyche")
    expect("Lock ghost", flow(lock_datom(PSYCHE, "{ Mind ghost Secondary }")), "Refused.Unknown.Address.{ Mind ghost Secondary }")
  '';
}

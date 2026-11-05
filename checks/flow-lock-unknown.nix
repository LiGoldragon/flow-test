# Lock on a metaflow that does not exist:
# Refused.Unknown.Address.{ Mind ghost Secondary }.
# Target: mind.
args@{ flake, ... }:
flake.lib.flowScenario args {
  name = "flow-lock-unknown";
  target = "mind";
  script = ''
    configure()
    awake(PSYCHE, "psyche")
    expect_message("Lock ghost", lock_datom(PSYCHE, "{ Mind ghost Secondary }"), "Refused.Unknown.Address.{ Mind ghost Secondary }")
  '';
}

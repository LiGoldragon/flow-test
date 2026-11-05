# Lock whose Sender names no metaflow:
# Refused.Unknown.Address, carrying the sender's address.
# Target: mind.
args@{ flake, ... }:
flake.lib.flowScenario args {
  name = "flow-lock-unknown-sender";
  target = "mind";
  script = ''
    configure()
    awake("{ Mind nexus Secondary }", "mind")
    expect_message("Lock from a ghost sender", lock_datom("{ Mind ghost Secondary }", "{ Mind nexus Secondary }"), "Refused.Unknown.Address.{ Mind ghost Secondary }")
  '';
}

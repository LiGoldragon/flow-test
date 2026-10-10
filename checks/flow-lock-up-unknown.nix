# Lock.{ Sender Up } from { Mind nexus Secondary } when no metaflow holds
# the resolved { Mind nexus Primary }: Refused.Unknown.Address, carrying the
# resolved address.
# Target: mind.
{
  pkgs,
  flake,
  system,
  ...
}:
flake.lib.flowScenario { inherit pkgs flake system; } {
  name = "flow-lock-up-unknown";
  target = "mind";
  script = ''
    configure()
    awake("{ Mind nexus Secondary }", "secondary")
    expect_message("Lock Up to no metaflow", lock_datom("{ Mind nexus Secondary }", "Up"), "Refused.Unknown.Address.{ Mind nexus Primary }")
  '';
}

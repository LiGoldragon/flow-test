# Lock whose Sender is an Asleep metaflow: Refused.Asleep (a Lock's Sender
# must be Awake).
# Target: mind.
{
  pkgs,
  flake,
  system,
  ...
}:
flake.lib.flowScenario { inherit pkgs flake system; } {
  name = "flow-lock-asleep-sender";
  target = "mind";
  script = ''
    configure()
    asleep(PSYCHE, "psyche")
    awake("{ Mind nexus Secondary }", "mind")
    expect_message("Lock from an asleep sender", lock_datom(PSYCHE, "{ Mind nexus Secondary }"), "Refused.Asleep")
  '';
}

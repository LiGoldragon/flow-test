# Lock from a peer that is not the Message Nexus's own process (an unbound
# process, while a process is bound as Message): Refused.NotMessage.
# Target: mind.
{
  pkgs,
  flake,
  system,
  ...
}:
flake.lib.flowScenario { inherit pkgs flake system; } {
  name = "flow-lock-not-message";
  target = "mind";
  script = ''
    configure()
    awake(MESSAGE, "message")
    awake(PSYCHE, "psyche")
    awake("{ Mind nexus Secondary }", "mind")
    expect("Lock from a peer not Message", flow(lock_datom(PSYCHE, "{ Mind nexus Secondary }")), "Refused.NotMessage")
  '';
}

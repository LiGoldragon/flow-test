# Lock from a peer that is not the Message Nexus's own process (an unbound
# process, while a process is bound as Message by message-helper):
# Refused.NotMessage.
# Target: mind.
args@{ flake, ... }:
flake.lib.flowScenario args {
  name = "flow-lock-not-message";
  target = "mind";
  script = ''
    configure()
    _, message_pid = open_pane("message")
    bind_message(message_pid)
    awake(PSYCHE, "psyche")
    awake("{ Mind nexus Secondary }", "mind")
    expect("Lock from a peer not Message", flow(lock_datom(PSYCHE, "{ Mind nexus Secondary }")), "Refused.NotMessage")
  '';
}

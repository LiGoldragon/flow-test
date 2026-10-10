# Identify is open to any local peer: with a process bound as Message, an
# Identify from the general flow client (not Message, in no metaflow) is
# answered Identified.Address, never NotMessage.
# Target: mind.
{
  pkgs,
  flake,
  system,
  ...
}:
flake.lib.flowScenario { inherit pkgs flake system; } {
  name = "flow-identify-not-message";
  target = "mind";
  script = ''
    configure()
    _, message_pid = open_pane("message")
    bind_message(message_pid)
    _, pid, _ = awake("{ Mind nexus Secondary }", "mind")
    expect("Identify from a peer not Message", flow(f"Identify.{process(pid)}"), "Identified.{ Mind nexus Secondary }")
  '';
}

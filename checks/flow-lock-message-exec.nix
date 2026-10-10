# The bound Message process, bound by message-helper (MessageNexusBinary),
# execve's another binary after its Bind (the general flow client): its pid
# and start time still match, but the gate re-checks the executable against MessageNexusBinary,
# so its Lock is refused NotMessage, and a following Bind as Message from
# that binary is refused NotMessage too.
# Target: mind.
{
  pkgs,
  flake,
  system,
  ...
}:
flake.lib.flowScenario { inherit pkgs flake system; } {
  name = "flow-lock-message-exec";
  target = "mind";
  script = ''
    configure()
    awake(PSYCHE, "psyche")
    awake("{ Mind nexus Secondary }", "mind")
    code, got = as_message(lock_datom(PSYCHE, "{ Mind nexus Secondary }"), binary="flow")
    judge("Lock after the exec", got, code, got == "Refused.NotMessage", "«Refused.NotMessage»")
    _, pid = open_pane("message")
    datom = f"Bind.{{ {MESSAGE} {process(pid)} }}"
    expect("Bind as Message from that binary", flow(datom), "Refused.NotMessage")
  '';
}

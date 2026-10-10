# The bound Message process execs a different binary after its Bind (a
# copy of the flow client at another path): its pid and start time still
# match, but the gate re-checks the executable against MessageNexusBinary,
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
    rig("cp $(readlink -f $(command -v flow)) /tmp/other-flow; chmod +x /tmp/other-flow")
    code, got = as_message(lock_datom(PSYCHE, "{ Mind nexus Secondary }"), binary="/tmp/other-flow")
    judge("Lock after the exec", got, code, got == "Refused.NotMessage", "«Refused.NotMessage»")
    _, pid = open_pane("message")
    datom = f"Bind.{{ {MESSAGE} {process(pid)} }}"
    expect("Bind as Message from that binary", f"/tmp/other-flow {shlex.quote(datom)}", "Refused.NotMessage")
  '';
}

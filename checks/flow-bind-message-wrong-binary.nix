# Bind under { Field message Primary } from a peer whose executable is not
# Configure.Nexus's MessageNexusBinary (a copy of the flow client at
# another path): Refused.NotMessage.
# Target: mind.
{
  pkgs,
  flake,
  system,
  ...
}:
flake.lib.flowScenario { inherit pkgs flake system; } {
  name = "flow-bind-message-wrong-binary";
  target = "mind";
  script = ''
    configure()
    rig("cp $(readlink -f $(command -v flow)) /tmp/other-flow; chmod +x /tmp/other-flow")
    _, pid = open_pane("message")
    datom = f"Bind.{{ {MESSAGE} {process(pid)} }}"
    expect("Bind as Message from another binary", f"/tmp/other-flow {shlex.quote(datom)}", "Refused.NotMessage")
  '';
}

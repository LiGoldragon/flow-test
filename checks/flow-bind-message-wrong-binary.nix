# Bind under { Field message Primary } from a peer whose executable is not
# Configure.Nexus's MessageNexusBinary (the general flow client, while
# MessageNexusBinary names message-helper): Refused.NotMessage.
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
    _, pid = open_pane("message")
    datom = f"Bind.{{ {MESSAGE} {process(pid)} }}"
    expect("Bind as Message from another binary", flow(datom), "Refused.NotMessage")
  '';
}

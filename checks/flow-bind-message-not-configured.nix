# Bind under { Field message Primary } before any Configure.Nexus:
# Refused.NotConfigured.
# Target: mind.
{
  pkgs,
  flake,
  system,
  ...
}:
flake.lib.flowScenario { inherit pkgs flake system; } {
  name = "flow-bind-message-not-configured";
  target = "mind";
  script = ''
    _, pid = open_pane("message")
    expect("Bind as Message before Nexus", flow(f"Bind.{{ {MESSAGE} {process(pid)} }}"), "Refused.NotConfigured")
  '';
}

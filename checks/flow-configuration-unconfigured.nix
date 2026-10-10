# Configuration on a fresh Nexus, before any Configure.Nexus: Unconfigured.
# Target: mind.
{
  pkgs,
  flake,
  system,
  ...
}:
flake.lib.flowScenario { inherit pkgs flake system; } {
  name = "flow-configuration-unconfigured";
  target = "mind";
  script = ''
    expect("Configuration before Nexus", meta("Configuration"), "Unconfigured")
  '';
}

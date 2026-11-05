# Configuration on a fresh Nexus, before any Configure.Nexus: Unconfigured.
# Target: mind.
args@{ flake, ... }:
flake.lib.flowScenario args {
  name = "flow-configuration-unconfigured";
  target = "mind";
  script = ''
    expect("Configuration before Nexus", meta("Configuration"), "Unconfigured")
  '';
}

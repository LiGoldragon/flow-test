# Configure.Model on a fresh Nexus, before any Configure.Nexus: Configured;
# Configure.Nexus after it: Configured.
# Target: mind.
args@{ flake, ... }:
flake.lib.flowScenario args {
  name = "flow-configure-model-before-nexus";
  target = "mind";
  script = ''
    expect("Configure.Model before Nexus", meta(model_payload("Primary")), "Configured")
    expect("Configure.Nexus after Model", meta(nexus_payload()), "Configured")
  '';
}

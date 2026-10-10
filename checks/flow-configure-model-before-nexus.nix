# Configure.Model on a fresh Nexus, before any Configure.Nexus: Configured;
# Configure.Nexus after it: Configured.
# Target: mind.
{
  pkgs,
  flake,
  system,
  ...
}:
flake.lib.flowScenario { inherit pkgs flake system; } {
  name = "flow-configure-model-before-nexus";
  target = "mind";
  script = ''
    expect("Configure.Model before Nexus", meta("Configure.Model.{ Primary haiku }"), "Configured")
    expect("Configure.Nexus after Model", meta(nexus_payload()), "Configured")
  '';
}

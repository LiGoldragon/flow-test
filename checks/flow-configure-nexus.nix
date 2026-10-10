# Configure.Nexus with the Nexus's own paths (the defaults): Configured;
# the same payload again agrees with the one held: Configured.
# Target: mind.
{
  pkgs,
  flake,
  system,
  ...
}:
flake.lib.flowScenario { inherit pkgs flake system; } {
  name = "flow-configure-nexus";
  target = "mind";
  script = ''
    expect("Configure.Nexus", meta(NEXUS_PAYLOAD), "Configured")
    expect("Configure.Nexus again", meta(NEXUS_PAYLOAD), "Configured")
  '';
}

# Configure.Nexus with the Nexus's own paths (the defaults) and Lease 60:
# Configured; the same payload again agrees with the one held: Configured;
# a disagreeing Nexus payload within the same start: Refused.Conflict.
# Target: mind.
args@{ flake, ... }:
flake.lib.flowScenario args {
  name = "flow-configure-nexus";
  target = "mind";
  script = ''
    expect("Configure.Nexus", meta(nexus_payload()), "Configured")
    expect("Configure.Nexus again", meta(nexus_payload()), "Configured")
    expect("Configure.Nexus disagreeing", meta(nexus_payload(30)), "Refused.Conflict")
  '';
}

# A Module before any Configure.Nexus is recorded unchecked: a payload with
# a Blake3 the file does not have answers Configured, and Configuration
# shows it as recorded once the Nexus is configured. Its hash is checked
# when it is first composed into a Launch: that Launch is refused
# HashMismatch.
# Target: mind.
{
  pkgs,
  flake,
  system,
  ...
}:
flake.lib.flowScenario { inherit pkgs flake system; } {
  name = "flow-module-before-nexus";
  target = "mind";
  script = ''
    wrong = "0" * 64
    expect("Configure.Module before Nexus", meta(module_payload(wrong)), "Configured")
    configure()
    got = expect_prefix("Configuration", meta("Configuration"), "Configuration.{ ")
    expect_true("the Module as recorded", f"{{ psyche-skills {wrong} vision/flow.md }}" in got, got)
    expect("Launch composing it", flow("Launch.{ { Mind launch Secondary } [ { Vision flow } ] «Design nothing.» }"), "Refused.HashMismatch")
  '';
}

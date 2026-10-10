# Configure.Module whose path names no file under the source:
# Refused.NoSource.Path.
# Target: mind.
{
  pkgs,
  flake,
  system,
  ...
}:
flake.lib.flowScenario { inherit pkgs flake system; } {
  name = "flow-configure-no-source";
  target = "mind";
  script = ''
    expect("Configure.Nexus", meta(NEXUS_PAYLOAD), "Configured")
    reply = expect_prefix("Configure.Module", meta(module_payload(module_hash(), path="vision/ghost.md")), "Refused.NoSource.")
    expect_true("the refusal names the path", "vision/ghost.md" in reply, reply)
  '';
}

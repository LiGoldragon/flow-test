# Configure.Module whose path names no file under the source:
# Refused.NoSource.Path.
# Target: mind.
args@{ flake, ... }:
flake.lib.flowScenario args {
  name = "flow-configure-no-source";
  target = "mind";
  script = ''
    expect("Configure.Nexus", meta(nexus_payload()), "Configured")
    reply = expect_prefix("Configure.Module", meta(module_payload(module_hash(), path="vision/ghost.md")), "Refused.NoSource.")
    expect_true("the refusal names the path", "vision/ghost.md" in reply, reply)
  '';
}

# Configure.Module with the fixture file's Blake3: Configured; again:
# Configured; the same subaspect and topic with another source:
# Refused.Conflict.
# Target: mind.
{
  pkgs,
  flake,
  system,
  ...
}:
flake.lib.flowScenario { inherit pkgs flake system; } {
  name = "flow-configure-module";
  target = "mind";
  script = ''
    expect("Configure.Nexus", meta(NEXUS_PAYLOAD), "Configured")
    payload = module_payload(module_hash())
    expect("Configure.Module", meta(payload), "Configured")
    expect("Configure.Module again", meta(payload), "Configured")
    other = module_payload(module_hash("psyche-skills/vision/other.md"), path="vision/other.md")
    expect("Configure.Module disagreeing", meta(other), "Refused.Conflict")
  '';
}

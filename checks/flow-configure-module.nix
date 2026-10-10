# Configure.Module with the fixture file's Blake3: Configured; again:
# Configured; the same key with another source and hash is an update:
# Configured, and the key stays registered: a Launch naming it is refused
# Awake (the metaflow is bound), never UnknownModule.
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
    configure()
    payload = module_payload(module_hash())
    expect("Configure.Module", meta(payload), "Configured")
    expect("Configure.Module again", meta(payload), "Configured")
    other = module_payload(module_hash("psyche-skills/vision/other.md"), path="vision/other.md")
    expect("Configure.Module updated", meta(other), "Configured")
    _, _, flow_id = awake("{ Mind nexus Secondary }", "mind")
    expect("Launch naming the key", flow("Launch.{ { Mind nexus Secondary } [ { Vision flow } ] «Design nothing.» }"), f"Refused.Awake.{flow_id}")
  '';
}

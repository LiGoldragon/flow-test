# Metaflows lists every metaflow as { Address State Past Queue }: one
# awake (Awake.FlowId, the FlowId Bind answered) and one asleep.
# Target: mind.
{
  pkgs,
  flake,
  system,
  ...
}:
flake.lib.flowScenario { inherit pkgs flake system; } {
  name = "flow-metaflows";
  target = "mind";
  script = ''
    configure()
    _, _, flow_id = awake("{ Mind nexus Secondary }", "mind")
    asleep("{ Mind other Secondary }", "other")
    listed = expect_prefix("Metaflows", flow("Metaflows"), "Listed.")
    expect_true("the awake one", "{ Mind nexus Secondary } Awake." + flow_id in listed, listed)
    expect_true("the asleep one", "{ Mind other Secondary } Asleep" in listed, listed)
  '';
}

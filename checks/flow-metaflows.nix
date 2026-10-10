# Metaflows lists every metaflow as { Address State Past Queue }, in bind
# order: one awake (Awake.FlowId, the FlowId Bind answered) and one asleep,
# its closed pane's FlowId moved into Past.
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
    other_id = asleep("{ Mind other Secondary }", "other")
    want = f"Listed.[ {{ {{ Mind nexus Secondary }} Awake.{flow_id} [] [] }} {{ {{ Mind other Secondary }} Asleep [ {other_id} ] [] }} ]"
    expect("Metaflows", flow("Metaflows"), want)
  '';
}

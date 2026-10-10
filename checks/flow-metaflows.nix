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
    want = f"Listed.[ {{ {{ Mind nexus Secondary }} Awake.{flow_id} [] [] }} {{ {{ Mind other Secondary }} Asleep [] [] }} ]"
    expect("Metaflows", flow("Metaflows"), want)
  '';
}

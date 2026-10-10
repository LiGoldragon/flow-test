# Restart on its own store: Flow, started again with the same Start, opens
# the store it created and continues from it, so a metaflow bound before
# the restart is listed after it, Awake with the same FlowId.
# Target: mind.
{
  pkgs,
  flake,
  system,
  ...
}:
flake.lib.flowScenario { inherit pkgs flake system; } {
  name = "flow-restart";
  target = "mind";
  script = ''
    configure()
    _, _, flow_id = awake("{ Mind nexus Secondary }", "mind")
    machine.succeed(f"touch {RUNTIME}/restart-mark")
    rig("systemctl --user restart flow-nexus.service")
    machine.wait_until_succeeds(f"test {RUNTIME}/flow/flow.sock -nt {RUNTIME}/restart-mark", timeout=30)
    expect("Metaflows after the restart", flow("Metaflows"), f"Listed.[ {{ {{ Mind nexus Secondary }} Awake.{flow_id} [] [] }} ]")
  '';
}

# Wake of an awake metaflow: Queued; the queue drains at the flow's next
# Stop, which the hook reports (Report.{ FlowId Stopped }), so the request
# then reaches the pane.
# Target: mind.
{
  pkgs,
  flake,
  system,
  ...
}:
flake.lib.flowScenario { inherit pkgs flake system; } {
  name = "flow-wake-awake";
  target = "mind";
  script = ''
    configure()
    pane, _, flow_id = awake("{ Mind nexus Secondary }", "mind")
    expect("Wake awake", flow("Wake.{ { Mind nexus Secondary } Order.ftWakeAwake }"), "Queued")
    expect("Report Stopped", flow(f"Report.{{ {flow_id} Stopped }}"), "Reported")
    pane_shows("drained at the Stop", pane, "ftWakeAwake")
  '';
}

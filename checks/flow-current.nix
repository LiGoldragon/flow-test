# Current answers each state: Unknown for an address never seen,
# Awake.FlowId (the FlowId Bind answered) for a bound metaflow, Asleep once
# its pane is closed, Ended after End.
# Target: mind.
{
  pkgs,
  flake,
  system,
  ...
}:
flake.lib.flowScenario { inherit pkgs flake system; } {
  name = "flow-current";
  target = "mind";
  script = ''
    configure()
    expect("Current never seen", flow("Current.{ Mind ghost Secondary }"), "Current.Unknown")
    pane, pid, flow_id = awake("{ Mind nexus Secondary }", "mind")
    expect("Current awake", flow("Current.{ Mind nexus Secondary }"), f"Current.Awake.{flow_id}")
    close_pane(pane)
    expect("Current asleep", flow("Current.{ Mind nexus Secondary }"), "Current.Asleep")
    awake("{ Mind other Secondary }", "other")
    expect("End other", flow("End.{ Mind other Secondary }"), "Ended")
    expect("Current ended", flow("Current.{ Mind other Secondary }"), "Current.Ended")
  '';
}

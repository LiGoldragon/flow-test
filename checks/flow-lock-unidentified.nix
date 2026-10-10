# Lock.Up from a pane in no metaflow: Refused.Unidentified.Process.
# Target: mind.
{
  pkgs,
  flake,
  system,
  ...
}:
flake.lib.flowScenario { inherit pkgs flake system; } {
  name = "flow-lock-unidentified";
  target = "mind";
  script = ''
    configure()
    pane, _ = open_pane("stranger")
    expect_in_pane("Lock.Up from an unbound pane", pane, flow("Lock.Up"), "Refused.Unidentified.", prefix=True)
  '';
}

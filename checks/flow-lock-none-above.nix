# Lock.Up from a pane bound to { Mind nexus Primary }, the top of its
# aspect: Refused.NoneAbove.
# Target: mind.
{
  pkgs,
  flake,
  system,
  ...
}:
flake.lib.flowScenario { inherit pkgs flake system; } {
  name = "flow-lock-none-above";
  target = "mind";
  script = ''
    configure()
    pane, _, _ = awake("{ Mind nexus Primary }", "primary")
    expect_in_pane("Lock.Up from the Primary", pane, flow("Lock.Up"), "Refused.NoneAbove")
  '';
}

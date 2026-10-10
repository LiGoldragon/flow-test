# Lock.Up from a pane bound to { Mind nexus Secondary }: Flow identifies
# the sender by process and resolves Up to the layer above within its
# aspect, answering Locked.{ { Mind nexus Primary } Until }.
# Target: mind.
{
  pkgs,
  flake,
  system,
  ...
}:
flake.lib.flowScenario { inherit pkgs flake system; } {
  name = "flow-lock-up";
  target = "mind";
  script = ''
    configure()
    awake("{ Mind nexus Primary }", "primary")
    pane, _, _ = awake("{ Mind nexus Secondary }", "secondary")
    expect_in_pane("Lock.Up from the Secondary", pane, flow("Lock.Up"), "Locked.{ { Mind nexus Primary } ", prefix=True)
  '';
}

# Deliver of a Notice under the lock to an Asleep metaflow: Queued (a
# notice wakes nothing); Current stays Asleep and the Queue holds it.
# Target: mind.
{
  pkgs,
  flake,
  system,
  ...
}:
flake.lib.flowScenario { inherit pkgs flake system; } {
  name = "flow-deliver-asleep";
  target = "mind";
  script = ''
    configure()
    awake(PSYCHE, "psyche")
    asleep("{ Mind nexus Secondary }", "mind")
    held, _ = lock(PSYCHE, "{ Mind nexus Secondary }")
    expect_message("Deliver a Notice", deliver(held, "Notice.ftDeliverNotice"), "Queued")
    expect("Current after", flow("Current.{ Mind nexus Secondary }"), "Current.Asleep")
    listed = expect_prefix("Metaflows", flow("Metaflows"), "Listed.")
    expect_true("the Queue holds the Notice", "Notice.ftDeliverNotice" in listed, listed)
  '';
}

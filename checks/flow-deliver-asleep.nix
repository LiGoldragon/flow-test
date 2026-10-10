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
    awake("{ Psyche nexus Secondary }", "psyche")
    asleep("{ Mind nexus Secondary }", "mind")
    held, _ = lock("{ Mind nexus Secondary }")
    expect("Deliver a Notice", flow(f"Deliver.{{ {held} {{ Psyche nexus Secondary }} Notice.«ftDeliverNotice» }}"), "Queued")
    expect("Current after", flow("Current.{ Mind nexus Secondary }"), "Current.Asleep")
    listed = expect_prefix("Metaflows", flow("Metaflows"), "Listed.")
    expect_true("the Queue holds the Notice", "Notice.«ftDeliverNotice»" in listed, listed)
  '';
}

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
    # The list also holds Message's own metaflow, bound for the Lock, whose
    # state after its process exits is not given; so the recipient's entry
    # is looked for whole.
    entry = "{ { Mind nexus Secondary } Asleep [] [ Notice.ftDeliverNotice ] }"
    expect_true("the recipient's entry", entry in listed, listed)
  '';
}

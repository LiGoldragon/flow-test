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
    _, _, psyche_id = awake(PSYCHE, "psyche")
    mind_id = asleep("{ Mind nexus Secondary }", "mind")
    held, _ = lock(PSYCHE, "{ Mind nexus Secondary }")
    expect_message("Deliver a Notice", deliver(held, "Notice.ftDeliverNotice"), "Queued")
    expect("Current after", flow("Current.{ Mind nexus Secondary }"), "Current.Asleep")
    # In bind order: the sender, the recipient (asleep, its closed pane's
    # FlowId in Past, the Notice queued), and Message's own metaflow, bound
    # for the Lock and again for the Deliver, asleep once each process
    # exited, both FlowIds in Past.
    entries = [
        f"{{ {PSYCHE} Awake.{psyche_id} [] [] }}",
        f"{{ {{ Mind nexus Secondary }} Asleep [ {mind_id} ] [ Notice.ftDeliverNotice ] }}",
        f"{{ {MESSAGE} Asleep [ {' '.join(MESSAGE_FLOWS)} ] [] }}",
    ]
    expect("Metaflows", flow("Metaflows"), f"Listed.[ {' '.join(entries)} ]")
  '';
}

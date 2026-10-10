# Lock whose Sender is an Ended metaflow:
# Refused.Ended.{ Psyche nexus Secondary }.
# Target: mind.
{
  pkgs,
  flake,
  system,
  ...
}:
flake.lib.flowScenario { inherit pkgs flake system; } {
  name = "flow-lock-ended-sender";
  target = "mind";
  script = ''
    configure()
    awake(PSYCHE, "psyche")
    expect("End the sender", flow(f"End.{PSYCHE}"), "Ended")
    awake("{ Mind nexus Secondary }", "mind")
    expect_message("Lock from an ended sender", lock_datom(PSYCHE, "{ Mind nexus Secondary }"), f"Refused.Ended.{PSYCHE}")
  '';
}

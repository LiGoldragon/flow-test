# Deliver under a lock taken before the metaflow ended:
# Refused.Ended.{ Mind nexus Secondary }.
# Target: mind.
{
  pkgs,
  flake,
  system,
  ...
}:
flake.lib.flowScenario { inherit pkgs flake system; } {
  name = "flow-deliver-ended";
  target = "mind";
  script = ''
    configure()
    awake(PSYCHE, "psyche")
    awake("{ Mind nexus Secondary }", "mind")
    held, _ = lock(PSYCHE, "{ Mind nexus Secondary }")
    expect("End", flow("End.{ Mind nexus Secondary }"), "Ended")
    expect_message("Deliver", deliver(held, "Order.«ftDeliverEnded»"), "Refused.Ended.{ Mind nexus Secondary }")
  '';
}

# The wake's preconditions are checked again at Deliver: a Lock to the
# Asleep { Mind flow Secondary } is granted while { Vision flow }, the
# registry's module for its topic, is present; after a Forget of that
# module, the Deliver is refused Unknown.Key.{ Vision flow }.
# Target: mind.
{
  pkgs,
  flake,
  system,
  ...
}:
flake.lib.flowScenario { inherit pkgs flake system; } {
  name = "flow-deliver-forgotten-module";
  target = "mind";
  script = ''
    configure()
    expect("Configure.Module", meta(module_payload(module_hash())), "Configured")
    awake(PSYCHE, "psyche")
    asleep("{ Mind flow Secondary }", "mind")
    held, _ = lock(PSYCHE, "{ Mind flow Secondary }")
    expect("Forget", meta("Forget.{ Vision flow }"), "Forgotten")
    expect_message("Deliver after the Forget", deliver(held, "Order.ftForgotten"), "Refused.Unknown.Key.{ Vision flow }")
  '';
}

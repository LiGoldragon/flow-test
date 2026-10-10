# A module forgotten between Lock and Deliver refuses nothing: a wake
# composes whatever the registry holds for the recipient's topic when it
# wakes, an empty set included. A Lock to the Asleep { Mind flow Secondary }
# is granted while { Vision flow } is registered; after a Forget of it, a
# Deliver of a Notice is Queued as usual (a notice wakes nothing) and the
# metaflow stays Asleep.
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
    expect_message("Deliver after the Forget", deliver(held, "Notice.ftForgotten"), "Queued")
    expect("Current after", flow("Current.{ Mind flow Secondary }"), "Current.Asleep")
  '';
}

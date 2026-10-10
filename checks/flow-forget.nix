# Forget.{ Vision flow } of a registered module: Forgotten; a Launch
# naming it is then Refused.Unknown.Key.{ Vision flow }.
# Target: mind.
{
  pkgs,
  flake,
  system,
  ...
}:
flake.lib.flowScenario { inherit pkgs flake system; } {
  name = "flow-forget";
  target = "mind";
  script = ''
    configure()
    expect("Configure.Module", meta(module_payload(module_hash())), "Configured")
    expect("Forget", meta("Forget.{ Vision flow }"), "Forgotten")
    expect("Launch with vision-flow", flow("Launch.{ { Mind launch Secondary } [ { Vision flow } ] «Design nothing.» }"), "Refused.Unknown.Key.{ Vision flow }")
  '';
}

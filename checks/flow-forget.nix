# Forget.{ Vision flow } of a registered module: Forgotten; a Launch
# naming it is then Refused.UnknownModule.
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
    expect_prefix("Launch with vision-flow", flow("Launch.{ { Mind launch Secondary } [ vision-flow ] «Design nothing.» }"), "Refused.UnknownModule.")
  '';
}

# Launch naming a module the registry does not hold:
# Refused.UnknownModule.{ Vision ghost }.
# Target: mind.
{
  pkgs,
  flake,
  system,
  ...
}:
flake.lib.flowScenario { inherit pkgs flake system; } {
  name = "flow-launch-unknown-module";
  target = "mind";
  script = ''
    configure()
    expect("Launch with { Vision ghost }", flow("Launch.{ { Mind launch Secondary } [ { Vision ghost } ] «Design nothing.» }"), "Refused.UnknownModule.{ Vision ghost }")
  '';
}

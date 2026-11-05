# Launch naming a module the registry does not hold:
# Refused.Unknown.Key.{ Vision ghost }.
# Target: mind.
args@{ flake, ... }:
flake.lib.flowScenario args {
  name = "flow-launch-unknown-key";
  target = "mind";
  script = ''
    configure()
    expect("Launch with { Vision ghost }", flow("Launch.{ { Mind launch Secondary } [ { Vision ghost } ] «Design nothing.» }"), "Refused.Unknown.Key.{ Vision ghost }")
  '';
}

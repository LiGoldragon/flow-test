# Launch naming a module the registry does not hold:
# Refused.UnknownModule.Key, the key naming the module (vision-ghost).
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
    reply = expect_prefix("Launch with vision-ghost", flow("Launch.{ { Mind launch Secondary } [ vision-ghost ] «Design nothing.» }"), "Refused.UnknownModule.")
    expect_true("the refusal names the module", "ghost" in reply, reply)
  '';
}

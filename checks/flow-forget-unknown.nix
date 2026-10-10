# Forget of a key the registry does not hold:
# Refused.UnknownModule.{ Vision ghost }.
# Target: mind.
{
  pkgs,
  flake,
  system,
  ...
}:
flake.lib.flowScenario { inherit pkgs flake system; } {
  name = "flow-forget-unknown";
  target = "mind";
  script = ''
    configure()
    expect("Forget", meta("Forget.{ Vision ghost }"), "Refused.UnknownModule.{ Vision ghost }")
  '';
}

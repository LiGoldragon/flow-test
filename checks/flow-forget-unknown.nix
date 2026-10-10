# Forget of a module the registry does not hold: Refused.Unknown.Topic.
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
    expect("Forget", meta("Forget.{ Vision ghost }"), "Refused.Unknown.ghost")
  '';
}

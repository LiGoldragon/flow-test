# Configure.Model.{ Primary haiku }: Configured; again: Configured; a
# disagreeing model for the same layer: Refused.Conflict.
# Target: mind.
{
  pkgs,
  flake,
  system,
  ...
}:
flake.lib.flowScenario { inherit pkgs flake system; } {
  name = "flow-configure-model";
  target = "mind";
  script = ''
    expect("Configure.Model", meta("Configure.Model.{ Primary haiku }"), "Configured")
    expect("Configure.Model again", meta("Configure.Model.{ Primary haiku }"), "Configured")
    expect("Configure.Model disagreeing", meta("Configure.Model.{ Primary sonnet }"), "Refused.Conflict")
  '';
}

# Configure.Threshold.{ Primary 20 40 }: Configured; again: Configured; a
# disagreeing threshold for the same layer: Refused.Conflict.
# Target: mind.
{
  pkgs,
  flake,
  system,
  ...
}:
flake.lib.flowScenario { inherit pkgs flake system; } {
  name = "flow-configure-threshold";
  target = "mind";
  script = ''
    expect("Configure.Threshold", meta("Configure.Threshold.{ Primary 20 40 }"), "Configured")
    expect("Configure.Threshold again", meta("Configure.Threshold.{ Primary 20 40 }"), "Configured")
    expect("Configure.Threshold disagreeing", meta("Configure.Threshold.{ Primary 25 45 }"), "Refused.Conflict")
  '';
}

# Configure.Threshold.{ Primary 20 40 }: Configured; again: Configured;
# other thresholds for the same layer are an update: Configured.
# Target: mind.
args@{ flake, ... }:
flake.lib.flowScenario args {
  name = "flow-configure-threshold";
  target = "mind";
  script = ''
    expect("Configure.Threshold", meta("Configure.Threshold.{ Primary 20 40 }"), "Configured")
    expect("Configure.Threshold again", meta("Configure.Threshold.{ Primary 20 40 }"), "Configured")
    expect("Configure.Threshold updated", meta("Configure.Threshold.{ Primary 25 45 }"), "Configured")
  '';
}

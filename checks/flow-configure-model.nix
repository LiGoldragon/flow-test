# Configure.Model.{ Primary Claude haiku }: Configured; again: Configured; another
# model for the same layer is an update (Conflict is only for Nexus setup
# payloads): Configured.
# Target: mind.
args@{ flake, ... }:
flake.lib.flowScenario args {
  name = "flow-configure-model";
  target = "mind";
  script = ''
    expect("Configure.Model", meta(model_payload("Primary")), "Configured")
    expect("Configure.Model again", meta(model_payload("Primary")), "Configured")
    expect("Configure.Model updated", meta(model_payload("Primary", "sonnet")), "Configured")
  '';
}

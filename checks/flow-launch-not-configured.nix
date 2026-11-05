# Launch before any Configure.Nexus: Refused.NotConfigured. Every layer's
# model is configured and the launch names no module, so only the Nexus's
# configuration is missing.
# Target: mind.
args@{ flake, ... }:
flake.lib.flowScenario args {
  name = "flow-launch-not-configured";
  target = "mind";
  script = ''
    for layer in LAYERS:
        expect(f"Configure.Model {layer}", meta(model_payload(layer)), "Configured")
    expect("Launch before Configure.Nexus", flow("Launch.{ { Mind launch Secondary } [ ] «Design nothing.» }"), "Refused.NotConfigured")
  '';
}

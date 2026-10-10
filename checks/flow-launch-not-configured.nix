# Launch before any Configure.Nexus: Refused.NotConfigured. Every layer's
# model is configured and the launch names no module, so only the Nexus's
# configuration is missing.
# Target: mind.
{
  pkgs,
  flake,
  system,
  ...
}:
flake.lib.flowScenario { inherit pkgs flake system; } {
  name = "flow-launch-not-configured";
  target = "mind";
  script = ''
    for layer in LAYERS:
        expect(f"Configure.Model {layer}", meta(model_payload(layer)), "Configured")
    expect("Launch before Configure.Nexus", flow("Launch.{ { Mind launch Secondary } [ ] «Design nothing.» }"), "Refused.NotConfigured")
  '';
}

# Launch at a layer with no model configured (only Primary has one):
# Refused.NoLayer. The launch's one module is registered, so only the
# layer is missing.
# Target: mind.
{
  pkgs,
  flake,
  system,
  ...
}:
flake.lib.flowScenario { inherit pkgs flake system; } {
  name = "flow-launch-no-layer";
  target = "mind";
  script = ''
    configure(layers=["Primary"])
    expect("Configure.Module vision-flow", meta(module_payload(module_hash())), "Configured")
    expect("Launch at Tertiary", flow("Launch.{ { Mind launch Tertiary } [ vision-flow ] «Design nothing.» }"), "Refused.NoLayer")
  '';
}

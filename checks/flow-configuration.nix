# Configuration after Nexus, every layer's Model and Threshold, and one
# Module: Configuration.{ Nexus Vector<Model> Vector<Threshold>
# Vector<Module> }, the stored state whole, in datom's canonical print
# (entries in the order sent, the Module unchecked: false).
# Target: mind.
{
  pkgs,
  flake,
  system,
  ...
}:
flake.lib.flowScenario { inherit pkgs flake system; } {
  name = "flow-configuration";
  target = "mind";
  script = ''
    configure()
    digest = module_hash()
    expect("Configure.Module", meta(module_payload(digest)), "Configured")
    expect("Configuration", meta("Configuration"), configuration_text([module_text(digest)]))
  '';
}

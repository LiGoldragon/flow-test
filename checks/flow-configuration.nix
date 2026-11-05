# Configuration after Nexus, every layer's Model and Threshold, and one
# Module: Configuration.{ Nexus Vector<Model> Vector<Threshold>
# Vector<Module> }, the stored state whole, in datom's canonical print
# (entries in the order sent, the Module unchecked: false).
# Target: mind.
args@{ flake, ... }:
flake.lib.flowScenario args {
  name = "flow-configuration";
  target = "mind";
  script = ''
    configure()
    digest = module_hash()
    expect("Configure.Module", meta(module_payload(digest)), "Configured")
    expect("Configuration", meta("Configuration"), configuration_text([module_text(digest)]))
  '';
}

# Configuration after Nexus, every layer's Model and Threshold, and one
# Module: Configuration.{ Nexus Vector<Model> Vector<Threshold>
# Vector<Module> }, the stored state whole. The print's spacing and order
# within each vector are not given, so each stored value is looked for.
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
    got = expect_prefix("Configuration", meta("Configuration"), "Configuration.{ ")
    for part in [SOURCE_ROOT, "codex-stable-flow-client", "codex-next-flow-client", "/run/user/1000/message/message.sock"]:
        expect_true(f"the Nexus holds {part}", part in got, got)
    for layer in LAYERS:
        expect_true(f"the Model of {layer}", f"{{ {layer} {MODEL} }}" in got, got)
        expect_true(f"the Threshold of {layer}", f"{{ {layer} 20 40 }}" in got, got)
    expect_true("the Module", f"{{ psyche-skills {digest} vision/flow.md }}" in got, got)
  '';
}

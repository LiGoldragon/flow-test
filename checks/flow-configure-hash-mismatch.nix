# Configure.Module carrying a Blake3 the file does not have:
# Refused.HashMismatch, refused whole: a Launch naming the module is then
# Refused.UnknownModule.
# Target: mind.
{
  pkgs,
  flake,
  system,
  ...
}:
flake.lib.flowScenario { inherit pkgs flake system; } {
  name = "flow-configure-hash-mismatch";
  target = "mind";
  script = ''
    configure()
    expect("Configure.Module", meta(module_payload("0" * 64)), "Refused.HashMismatch")
    expect_prefix("Launch with vision-flow", flow("Launch.{ { Mind launch Secondary } [ { Vision flow } ] «Design nothing.» }"), "Refused.UnknownModule.")
  '';
}

# Bind of a second process to an awake metaflow:
# Refused.Taken.{ Mind nexus Secondary }.
# Target: mind.
{
  pkgs,
  flake,
  system,
  ...
}:
flake.lib.flowScenario { inherit pkgs flake system; } {
  name = "flow-bind-taken";
  target = "mind";
  script = ''
    configure()
    awake("{ Mind nexus Secondary }", "first")
    _, pid = open_pane("second")
    expect("second Bind", meta(f"Bind.{{ {{ Mind nexus Secondary }} {process(pid)} }}"), "Refused.Taken.{ Mind nexus Secondary }")
  '';
}

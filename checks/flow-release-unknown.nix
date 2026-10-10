# Release of a lock never granted: Refused.Unknown.Lock.
# Target: mind.
{
  pkgs,
  flake,
  system,
  ...
}:
flake.lib.flowScenario { inherit pkgs flake system; } {
  name = "flow-release-unknown";
  target = "mind";
  script = ''
    configure()
    awake(PSYCHE, "psyche")
    awake("{ Mind nexus Secondary }", "mind")
    forged = f"{{ {PSYCHE} {{ Mind nexus Secondary }} 4102444800 }}"
    expect("Release forged", flow(f"Release.{forged}"), f"Refused.Unknown.Lock.{forged}")
  '';
}

{ inputs, ... }:
let
  components = {
    flow = import ./components/flow.nix { inherit inputs; };
    herdr = import ./components/herdr.nix;
    testMachine = import ./components/test-machine.nix;
  };
in
{
  # One entry per shared component. A scenario reaches these as
  # `flake.lib.components.<name>` and adds only its own drive and assertions.
  inherit components;

  # The Primary revision of Flow's design the scenarios are written to
  # (flows/f5a6e9/reports/flow-buildable-design.md).
  design = "9bffed2f4";

  # The frame every pure scenario shares:
  # `flake.lib.flowScenario args { name, target, script }`.
  flowScenario = import ./flow-scenario.nix;

  # The cheapest model per harness, the semi-sandbox default.
  cheapestModel = {
    claude = "haiku";
    codex = "luna";
  };
}

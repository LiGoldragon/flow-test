{ inputs, ... }:
{
  # One entry per component a scenario drives. A scenario reaches these as
  # `flake.lib.components.<name>` and adds only its own drive and assertions.
  components = {
    flow = import ./components/flow.nix { inherit inputs; };
    herdr = import ./components/herdr.nix;
  };

  # The Primary revision of Flow's design the scenarios are written to
  # (flows/f5a6e9/reports/flow-buildable-design.md).
  design = "c82223e93";

  # The frame every pure scenario shares:
  # `flake.lib.flowScenario { pkgs, flake, system } { name, target, script }`.
  flowScenario = import ./flow-scenario.nix;

  # The cheapest model per harness, the semi-sandbox default.
  cheapestModel = {
    claude = "haiku";
    codex = "luna";
  };
}

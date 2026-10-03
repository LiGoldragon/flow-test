{ inputs, ... }:
{
  # One entry per tested component. A scenario reaches these as
  # `flake.lib.components.<name>`, takes what it needs, and adds only its own
  # drive and assertions.
  components = {
    flow = import ./components/flow.nix { inherit inputs; };
    claude = import ./components/claude.nix { inherit inputs; };
    flow-hook = import ./components/flow-hook.nix { inherit inputs; };
    herdr-fixture = import ./components/herdr-fixture.nix { inherit inputs; };
    flow-id = import ./components/flow-id.nix { inherit inputs; };
  };

  # The shared frame of a pure scenario: `flake.lib.scenario { pkgs, name }
  # drive` is a check that runs `drive` in a fresh root.
  scenario = import ./scenario.nix;

  # The cheapest model per harness, the semi-sandbox default.
  cheapestModel = {
    claude = "haiku";
    codex = "luna";
  };
}

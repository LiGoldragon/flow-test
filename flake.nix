{
  description = "flow-test — Nix sandboxes that drive the Flow Nexus and its clients. The tested repository is a pinned flake input; scenarios are named by the components they drive.";

  inputs = {
    nixpkgs.url = "github:LiGoldragon/nixpkgs?ref=main";

    blueprint.url = "github:numtide/blueprint";
    blueprint.inputs.nixpkgs.follows = "nixpkgs";

    flow.url = "github:LiGoldragon/flow/ae0502724c16c33bab523fc9ac800d53c5b48b87";
    flow.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs: inputs.blueprint { inherit inputs; };
}

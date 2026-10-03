{
  description = "flow-test — Nix sandboxes that drive the Flow Nexus and its clients. The tested repository is a pinned flake input; scenarios are named by the components they drive.";

  inputs = {
    nixpkgs.url = "github:LiGoldragon/nixpkgs?ref=main";

    blueprint.url = "github:numtide/blueprint";
    blueprint.inputs.nixpkgs.follows = "nixpkgs";

    flow.url = "github:LiGoldragon/flow/636214e515f7c09d32ae614033224aa40944423f";
    flow.inputs.nixpkgs.follows = "nixpkgs";

    harness.url = "github:LiGoldragon/harness";
    harness.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs: inputs.blueprint { inherit inputs; };
}

{
  description = "flow-test — acceptance scenarios that run the real Flow Nexus in a virtual machine, written to Flow's design (f5a6e9 flow-buildable-design at Primary 9613a5738, with f5a6e9's later rulings).";

  inputs = {
    nixpkgs.url = "github:LiGoldragon/nixpkgs?ref=main";

    blueprint.url = "github:numtide/blueprint";
    blueprint.inputs.nixpkgs.follows = "nixpkgs";

    flow.url = "github:LiGoldragon/flow";
    flow.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs: inputs.blueprint { inherit inputs; };
}

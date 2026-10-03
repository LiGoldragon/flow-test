# flow-id: the claim helper Flow runs to claim a flow's FlowId for a native
# session (`flow-id claude --flows-root <abs> --parent-session <uuid>`),
# from the pinned `harness` input. Flow finds it on its PATH.
{ inputs }:
{
  name = "flow-id";

  forSystem = system: rec {
    package = inputs.harness.packages.${system}.default;
    bin = "${package}/bin";
  };
}

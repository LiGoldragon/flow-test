# Flow: the Flow Nexus and its `flow` / `flow-meta` clients, taken from the
# `flow` input. The Nexus starts with no arguments; sockets under
# XDG_RUNTIME_DIR, store under HOME. Every request is written as Flow's
# design gives it (f5a6e9 flow-buildable-design at Primary d849975ab).
{ inputs }:
{
  forSystem = system: rec {
    package = inputs.flow.packages.${system}.default;

    nexus = "${package}/bin/flow-nexus";
    client = "${package}/bin/flow";
    metaClient = "${package}/bin/flow-meta";

    # Relative to XDG_RUNTIME_DIR.
    ordinarySocket = "flow/flow.sock";
    metaSocket = "flow/flow-meta.sock";

    layers = [
      "Primary"
      "Secondary"
      "Tertiary"
      "Quaternary"
    ];

    # Configure.Model.{ Layer Native }: the layer's model as the harness
    # knows it.
    modelPayload = layer: model: "Configure.Model.{ ${layer} ${model} }";

    # Configure.Threshold.{ Layer Handover Refresh }, percent of the window.
    thresholdPayload = layer: "Configure.Threshold.{ ${layer} 20 40 }";

    # Configure.Nexus.{ SourceRoot StableCodex NextCodex HarnessProfiles
    # MetaAspects MessageNexusPath Lease }. The listening sockets come from
    # the Nexus's start command (none: the defaults), not from Configure;
    # Lease is a lock's span in seconds (60 until Configure.Nexus sets it).
    nexusPayload = runtime: sourceRoot: lease: ''
      Configure.Nexus.{ ${sourceRoot}
                        codex-stable-flow-client
                        codex-next-flow-client
                        [ claude ]
                        [ Psyche Mind Field ]
                        ${runtime}/message/message.sock
                        ${lease} }
    '';
  };
}

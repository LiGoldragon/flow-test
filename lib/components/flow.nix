# Flow: the Flow Nexus and its `flow` / `flow-meta` clients, taken from the
# `flow` input. The Nexus starts with no arguments; sockets under
# XDG_RUNTIME_DIR, store under HOME. Every request is written as Flow's
# design gives it (f5a6e9 flow-buildable-design at Primary 5f0e64f34).
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

    # Configure.Nexus.{ OrdinarySocketPath MetaSocketPath SourceRoot
    # StableCodex NextCodex HarnessProfiles MetaAspects MessageNexusPath
    # Lease }, every path the default one so no restart is asked; Lease is
    # a lock's span in seconds (60 by default).
    nexusPayload = runtime: sourceRoot: lease: ''
      Configure.Nexus.{ ${runtime}/${ordinarySocket}
                        ${runtime}/${metaSocket}
                        ${sourceRoot}
                        codex-stable-flow-client
                        codex-next-flow-client
                        [ claude ]
                        [ Psyche Mind Field ]
                        ${runtime}/message/message.sock
                        ${lease} }
    '';
  };
}

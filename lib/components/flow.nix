# Flow: the Flow Nexus and its `flow` / `flow-meta` clients, taken from the
# `flow` input. The Nexus starts with no arguments; sockets under
# XDG_RUNTIME_DIR, store under HOME. Every request is written as Flow's
# design gives it (f5a6e9 flow-buildable-design at Primary c5a3654bc).
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

    # The Message stand-in's own binary: a copy of the flow client in its own
    # store path, named message-helper. Configure.Nexus names it as
    # MessageNexusBinary, so only a process running it binds as Message,
    # and the general flow client is another binary to the gate.
    messageHelper =
      pkgs:
      pkgs.runCommand "message-helper" { } ''
        mkdir -p $out/bin
        cp ${client} $out/bin/message-helper
      '';

    # The Nexus's start command: one datom naming its two listening sockets.
    startArgument = runtime: "Start.{ ${runtime}/${ordinarySocket} ${runtime}/${metaSocket} }";

    # Configure.Nexus.{ SourceRoot StableCodex NextCodex HarnessProfiles
    # MetaAspects MessageNexusPath MessageNexusBinary Lease }, with full values in the shapes
    # meta-signal-flow's ethos/signal.ethos declares at the revision Flow
    # 0.25.0 pins (88f3759):
    #   CodexEndpoint.{ ClientPath Home ControlSocketPath Vector<ModelName> }
    #   HarnessProfile.{ HarnessKind Vector<CommandSigil> InterruptKeys
    #                    SubmitKeys }
    # The values are Flow 0.25.0's defaults. A string is bare unless it has a
    # space or a delimiter glyph, or begins or ends with . ! or :, so `!` is
    # written «!». Lease is a lock's span in
    # seconds (60 until Configure.Nexus sets it). MessageNexusBinary is the
    # executable a Bind as Message must come from; the scenarios' Message
    # stand-in binds with the `flow` client, so it names that binary.
    nexusPayload =
      {
        runtime,
        home,
        sourceRoot,
        messageNexusBinary,
        lease,
      }:
      ''
        Configure.Nexus.{ ${sourceRoot}
                          { codex-stable-flow-client
                            ${home}/.codex
                            ${home}/.codex/app-server-control/app-server-control.sock
                            [ gpt-5.6-terra gpt-5.6-sol gpt-5.6-luna ] }
                          { codex-next-flow-client
                            ${home}/.codex-next
                            ${home}/.codex-next/app-server-control/app-server-control.sock
                            [ gpt-6-sol gpt-6-luna gpt-6-astra ] }
                          [ { Claude [ / «!» # ] [ esc esc ] [ enter ] }
                            { Codex [ / «!» ] [ esc ] [ ] } ]
                          [ Psyche Mind Field ]
                          ${runtime}/message/message.sock
                          ${messageNexusBinary}
                          ${lease} }
      '';
  };
}

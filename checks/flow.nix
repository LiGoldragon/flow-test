# A pure scenario: one Flow Nexus on its own HOME and XDG_RUNTIME_DIR with a
# fresh store, driven through its two stock clients. It runs in the build
# sandbox with no network, no credentials and no model.
#
# Drive: both sockets bind; `List.{}` on the ordinary socket (the contract's
# read that needs no flow: `Observe.Agent` names one); a refused `Retire` and
# a `Configure` on the meta socket; then TERM. Every reply is compared whole
# against the typed reply text the contracts (signal-flow, meta-signal-flow)
# define; the expected texts are written here, not computed through the
# clients.
{
  pkgs,
  flake,
  system,
  ...
}:
let
  flow = flake.lib.components.flow.forSystem system;
  configuration = flow.configuration {
    ordinary = "$FLOW_SOCKET";
    meta = "$FLOW_META_SOCKET";
    sourceRoot = "$HOME/primary";
  };
in
flake.lib.scenario
  {
    inherit pkgs;
    name = "flow";
  }
  ''
    ${flow.start}
    test -S "$XDG_RUNTIME_DIR/${flow.ordinarySocket}"
    test -S "$XDG_RUNTIME_DIR/${flow.metaSocket}"
    test -e "$HOME/${flow.store}"

    expect list-empty 0 'Listed.[]' \
      ${flow.client} 'List.{}'
    expect retire-unknown 0 'RetireRejected.UnknownFlow' \
      ${flow.metaClient} 'Retire.ffffff'
    expect configure 0 "Configured.{ ${configuration} NexusRestartRequired }" \
      ${flow.metaClient} "Configure.${configuration}"
    expect list-after-configure 0 'Listed.[]' \
      ${flow.client} 'List.{}'

    ${flow.stop}
  ''

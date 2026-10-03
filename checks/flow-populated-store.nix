# A pure scenario: the Nexus restarted on a populated store. A fresh store is
# configured over the meta socket to move both sockets to new names; the
# Configure answers NexusRestartRequired, so nothing moves while it runs. The
# Nexus is stopped with TERM and started again on the same HOME and
# XDG_RUNTIME_DIR: it must now serve the moved sockets, read back from the
# store, and leave the default names unserved (their stale files from the
# first run are still on disk, so a connection there is refused).
{
  pkgs,
  flake,
  system,
  ...
}:
let
  flow = flake.lib.components.flow.forSystem system;
  configuration = flow.configuration {
    ordinary = "$movedOrdinary";
    meta = "$movedMeta";
    sourceRoot = "$root/source";
  };
in
flake.lib.scenario
  {
    inherit pkgs;
    name = "flow-populated-store";
  }
  ''
    ${flow.start}
    defaultOrdinary="$XDG_RUNTIME_DIR/${flow.ordinarySocket}"
    defaultMeta="$XDG_RUNTIME_DIR/${flow.metaSocket}"
    movedOrdinary="$XDG_RUNTIME_DIR/moved/ordinary.sock"
    movedMeta="$XDG_RUNTIME_DIR/moved/meta.sock"
    refused="Connection refused (os error 111)"
    test "$FLOW_SOCKET" = "$defaultOrdinary"

    expect configure-moved 0 "Configured.{ ${configuration} NexusRestartRequired }" \
      ${flow.metaClient} "Configure.${configuration}"
    expect list-before-restart 0 'Listed.[]' \
      ${flow.client} 'List.{}'

    ${flow.stop}
    echo "restarting on the same store"
    export FLOW_SOCKET="$movedOrdinary" FLOW_META_SOCKET="$movedMeta"
    ${flow.start}

    test -S "$movedOrdinary"
    test -S "$movedMeta"
    expect list-at-moved 0 'Listed.[]' \
      ${flow.client} 'List.{}'
    expect configure-at-moved 0 "Configured.{ ${configuration} NexusRestartRequired }" \
      ${flow.metaClient} "Configure.${configuration}"
    expectFailure ordinary-default-unserved 2 "$refused" \
      env FLOW_SOCKET="$defaultOrdinary" ${flow.client} 'List.{}'
    expectFailure meta-default-unserved 2 "$refused" \
      env FLOW_META_SOCKET="$defaultMeta" ${flow.metaClient} 'Retire.ffffff'

    ${flow.stop}
  ''

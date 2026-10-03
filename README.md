# flow-test

Nix sandboxes that drive the Flow Nexus and its clients. This repository holds
no component source: it **pins `flow` as a flake input** (its `nixpkgs`
follows this flake's) and drives it. Scenarios change often; the Nexus changes
rarely, so a new or edited scenario never invalidates the Rust build, and Flow
moves forward here only when this repository updates its input.

Pinned: `github:LiGoldragon/flow/636214e515f7c09d32ae614033224aa40944423f`
(0.23.0), and `github:LiGoldragon/harness` (its `flow-id`, which Flow runs to
claim a FlowId), both following this flake's `nixpkgs`.

Test unpushed Flow code with
`--override-input flow path:/git/github.com/LiGoldragon/flow`.
Once it lands, `nix flake update flow` and commit the lock.

## Layout

Laid out for [numtide blueprint](https://numtide.github.io/blueprint): the
directory tree is the flake's output tree.

    flake.nix                          inputs and `inputs.blueprint { inherit inputs; }`
    lib/default.nix                    flake.lib: components, scenario, cheapestModel
    lib/scenario.nix                   the frame of a pure scenario: root, expect, exit trap
    lib/components/flow.nix            the Nexus and both clients: paths, configuration, start, stop
    checks/flow.nix                    pure scenario (a check)
    checks/flow-populated-store.nix    pure: restart on a populated store
    lib/components/claude.nix          Claude Code from the pinned nixpkgs
    lib/components/flow-hook.nix       flow-hook and the hook settings Flow writes
    lib/components/flow-id.nix         flow-id from the pinned harness
    lib/components/herdr-fixture.nix   a Herdr stand-in: snapshot, and the launch stages up to Title
    packages/flow-claude.nix           semi-sandbox runner (gated; the launch documented, not yet run)
    packages/flow-claude-hook.nix      semi-sandbox runner (gated): the hook, hand-run and Flow-launched
    checks/lint.nix                    nixfmt --check, deadnix, statix
    formatter.nix                      pkgs.nixfmt

## Scenarios

| scenario | kind | components |
| --- | --- | --- |
| `flow` | pure check | Flow (Nexus, `flow`, `flow-meta`) |
| `flow-populated-store` | pure check | Flow |
| `flow-claude` | semi-sandbox, gated | Flow, Claude Code on the cheapest model |
| `flow-claude-hook` | semi-sandbox, gated | Flow, flow-hook, flow-id, fixture Herdr, Claude Code on the cheapest model |

### `flow` (pure)

Starts `flow-nexus` with no arguments on its own `HOME` and `XDG_RUNTIME_DIR`
inside the build sandbox, so it opens a fresh store at
`$HOME/.local/state/flow/flow.sema` and binds `flow/flow.sock` and
`flow/flow-meta.sock` under the runtime directory. It then drives the stock
clients and compares each whole reply and exit code:

1. both socket files are sockets, the store exists
2. `List.{}` → `Listed.[]` (the ordinary read that needs no flow;
   `Observe.Agent` names one)
3. meta `Retire.ffffff` → `RetireRejected.UnknownFlow`
4. meta `Configure.{ <configuration> }` →
   `Configured.{ { <configuration> } NexusRestartRequired }`
5. `List.{}` → `Listed.[]`

and then stops the Nexus and requires it to exit on TERM. No network, no
credentials, no model.

The Nexus prints no ready line, so `start` waits (bounded) until each socket
answers a read-only query (`List.{}`, and a `Retire` of an unknown flow, which
changes nothing), never on a socket file existing: after a restart the
previous run's files are still there.

### `flow-populated-store` (pure)

A fresh store is configured over the meta client to move both sockets to
`moved/ordinary.sock` and `moved/meta.sock` (`Configured.{ … }
NexusRestartRequired`); the Nexus is stopped with TERM and started again on
the same directories. It must then answer `List.{}` → `Listed.[]` and the same
`Configure` on the moved sockets, and the default names (whose stale files are
still on disk) refuse both clients on stderr with
`Connection refused (os error 111)`, exit 2. The configuration persisted in
the store and the Nexus read it back on start.

### `flow-claude` (semi-sandbox, gated)

The light-model launch through Flow, documented for when Flow launches
harnesses in a sandbox. It refuses to run unless `FLOW_TEST_LIVE=1`:

    FLOW_TEST_LIVE=1 nix run .#flow-claude

With the flag it starts a Nexus in a fresh `mktemp -d /tmp/ft-XXXXXXXX` root,
configures it with the Claude harness profile, asserts `Listed.[]`, and exits
3: the launch is not yet exercised. Its steps (credential copy, a sandbox
Herdr, `Start` with the cheapest model, `Started`, Active in `List`,
`Observe.Agent`, `Stop`, the bounds) are written at the head of
`packages/flow-claude.nix`. `nix flake check` only builds its script
(`pkgs-flow-claude`); no credential and no model reach CI.

| variable | default |
| --- | --- |
| `FLOW_TEST_LIVE` | unset: refuse (exit 2) |
| `FLOW_TEST_MODEL` | `haiku` |

## Running

    find . -name '*.nix' -exec nix fmt {} +
    nix flake check --no-build --option allow-import-from-derivation false
    nix flake check
    FLOW_TEST_LIVE=1 nix run .#flow-claude   # only by hand

Builds go to the remote builder.

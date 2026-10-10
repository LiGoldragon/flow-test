# flow-test

Acceptance scenarios that run the real Flow Nexus in a NixOS virtual machine
and drive it through its real `flow` and `flow-meta` clients. This repository
holds no component source: `flow` is a flake input whose `nixpkgs` follows
this flake's. Every request is written as Flow's design gives it:
`flows/f5a6e9/reports/flow-buildable-design.md` at Primary revision
e846c2ca1, with f5a6e9's later ruling on the lock: `Lock.{ Sender Recipient }`,
written `Lock.{ { Psyche nexus Secondary } Address.{ Mind nexus Secondary } }`
or `Lock.{ { Mind nexus Secondary } Up }`; Flow resolves Up relative to the
Sender and answers `Locked.Lock` carrying the resolved Address, or refuses
`NoneAbove`. The Lock is `{ Sender Address Until }`. Deliver is `Deliver.{ Lock Request }`,
the sender inside the lock. A Key is the pair, `{ Vision flow }`. Configure.Nexus
ends with `Lease`, seconds, 60 by default. Where the design left a case open,
the scenarios follow f5a6e9's rulings (current best) given to this repository.

Test unpushed Flow code with `--override-input flow path:<checkout>`; once it
lands, `nix flake update flow` and commit the lock.

## Targets

Each scenario declares a target. `pass`: it must meet every expectation.
`mind`: it is Mind's acceptance target, expected to miss against the pinned
Flow. A missed expectation is recorded as expected-failing and the check
builds; a `mind` scenario that meets every expectation fails its check, and
is then promoted to `pass`. A failure of the rig (the machine, the units,
the sockets, Herdr, the drive's own Python) fails the check either way.

Each scenario writes `outcome` (its result line, then every step's reply) to
its output. `checks.<system>.report` gathers them, grouped as passing and
expected-failing:

    nix build .#checks.x86_64-linux.report -L && cat result

## Layout

    flake.nix                    inputs and `inputs.blueprint { inherit inputs; }`
    lib/default.nix              flake.lib: components, flowScenario, cheapestModel
    lib/components/flow.nix      the Flow Nexus and clients: paths, payloads
    lib/components/herdr.nix     headless Herdr
    lib/flow-scenario.nix        the frame: one VM, two user services, the target
    lib/flow-scenario.py         the frame's helpers: configure, panes, Bind, Lock
    checks/herdr.nix             the rig: headless Herdr in the VM
    checks/flow-*.nix            one scenario per file
    checks/report.nix            every scenario's outcome
    packages/flow-claude.nix     semi-sandbox: requests that start a harness
    fixtures/flow/source/        module source files for Configure.Module
    checks/lint.nix, formatter.nix  style gate

## Scenarios

| check | request | expect |
|---|---|---|
| flow-launch-unknown-module | Launch | Refused.UnknownModule.{ Vision ghost } |
| flow-launch-no-layer | Launch | Refused.NoLayer |
| flow-launch-awake | Launch | Refused.Awake.FlowId |
| flow-wake-unknown | Wake | Refused.Unknown.Address |
| flow-wake-ended | Wake | Refused.Ended.Address |
| flow-wake-queued | Wake | Notice and Result to Asleep: Queued; Queue holds both |
| flow-wake-awake | Wake | Queued; drained at the reported Stop |
| flow-refresh-unknown | Refresh | Refused.Unknown.Address |
| flow-refresh-ended | Refresh | Refused.Ended.Address |
| flow-refresh-asleep | Refresh | Refused.Asleep |
| flow-refresh-held | Refresh | Refused.Held.Lock |
| flow-end | End | Ended; Current.Ended |
| flow-end-unknown | End | Refused.Unknown.Address |
| flow-end-held | End | Refused.Held.Lock; Ended after Release |
| flow-current | Current | Unknown, Awake.FlowId, Asleep, Ended |
| flow-lock-address | Lock | Locked.{ Sender Address Until }, Until 60 s away |
| flow-lock-up | Lock | Up resolved from the Sender to { Mind nexus Primary } |
| flow-lock-none-above | Lock | Refused.NoneAbove |
| flow-lock-held | Lock | Refused.Held.Lock; granted after the lapse |
| flow-lock-lease | Lock | Lease 3 s: Until 3 s away; Lapsed after it |
| flow-lock-unknown | Lock | Refused.Unknown.Address |
| flow-lock-ended | Lock | Refused.Ended.Address |
| flow-lock-off-route | Lock | Refused.OffRoute |
| flow-deliver-awake | Deliver | Delivered; reaches the pane; the lock ends |
| flow-deliver-asleep | Deliver | Notice: Queued; Current.Asleep |
| flow-deliver-ended | Deliver | Refused.Ended.Address |
| flow-deliver-lapsed | Deliver | Refused.Lapsed |
| flow-deliver-unknown-lock | Deliver | Refused.Unknown.Lock |
| flow-release | Release | Released; Lock granted again |
| flow-release-after-deliver | Release | Refused.Unknown.Lock |
| flow-release-lapsed | Release | Refused.Lapsed |
| flow-release-unknown | Release | Refused.Unknown.Lock |
| flow-identify | Identify | Identified.Address, shell and descendant |
| flow-identify-unidentified | Identify | Refused.Unidentified.Process, unbound and reused pid |
| flow-report | Report | Reported for each Event |
| flow-report-unknown | Report | Refused.Unknown.FlowId |
| flow-observe-agent | Observe.Agent | Observed.Agent.String |
| flow-observe-agent-unknown | Observe.Agent | Refused.Unknown.FlowId |
| flow-stop | Stop | Stopped; Current.Asleep |
| flow-stop-unknown | Stop | Refused.Unknown.FlowId |
| flow-metaflows | Metaflows | Listed, awake and asleep |
| flow-configure-nexus | Configure.Nexus | Configured, twice; disagreeing: Refused.Conflict |
| flow-configure-model | Configure.Model | Configured, twice; update: Configured |
| flow-configure-threshold | Configure.Threshold | Configured, twice; update: Configured |
| flow-configure-module | Configure.Module | Configured, twice; new hash: Configured |
| flow-configure-no-source | Configure.Module | Refused.NoSource.Path |
| flow-configure-hash-mismatch | Configure.Module | Refused.HashMismatch, refused whole |
| flow-forget | Forget | Forgotten; Launch then Refused.UnknownModule |
| flow-forget-unknown | Forget | Refused.UnknownModule.{ Vision ghost } |
| flow-bind | Bind | Bound.FlowId; Current.Awake; Identified |
| flow-bind-taken | Bind | Refused.Taken.Address |
| flow-bind-dead | Bind | Refused.Unidentified.Process, dead and reused pid |

`flow-claude` (semi-sandbox, `FLOW_TEST_LIVE=1`, Claude on Haiku): Launch
(Launched.FlowId, titled pane, brief in the first prompt), Wake (Queued then
Woken.FlowId, drained queue with the Order last), Refresh
(Refreshed.{ successor predecessor }, Past), Refused.Locked during a refresh,
and Queued for a busy flow.

## Running

    nix flake check --no-build --option allow-import-from-derivation false
    nix flake check --keep-going -L
    FLOW_TEST_LIVE=1 nix run .#flow-claude

# Helpers every pure scenario shares. Commands run as alice inside the
# machine. A request goes to the Nexus through the real `flow` (ordinary
# socket) or `flow-meta` (meta socket) client, one inline datom each; the
# reply is the client's whole output.
#
# An expectation of Flow's design that is not met raises Miss. Only Miss is
# caught by scenario(): any other exception (the rig, Herdr, the drive's own
# Python) fails the check as broken.
import json
import os
import re
import shlex

FIXTURES = "/etc/flow-test"
PANE_RUNS = [0]
STEPS = []


class Miss(Exception):
    pass


def as_alice(command):
    inner = f"export XDG_RUNTIME_DIR={RUNTIME}; {command}"
    return "su -l alice -c " + shlex.quote(inner)


# A command bounded at 30 seconds (a hung client answers exit 124); its
# standard error joins its reply.
def run(command):
    bounded = f"timeout 30 sh -c {shlex.quote(command)} 2>&1"
    status, out = machine.execute(as_alice(bounded), timeout=60)
    return status, out.strip()


def rig(command):
    status, out = run(command)
    assert status == 0, f"rig command failed (exit {status}): {command}\n{out}"
    return out


def flow(datom):
    return f"flow {shlex.quote(datom)}"


def meta(datom):
    return f"flow-meta {shlex.quote(datom)}"


def judge(label, got, status, met, want):
    STEPS.append(f"{label}: «{got}» (exit {status})")
    print(f"{label}: «{got}» (exit {status})")
    if not met:
        raise Miss(f"{label}: expected {want}, got «{got}» (exit {status})")
    return got


def expect(label, command, want):
    status, got = run(command)
    return judge(label, got, status, got == want, f"«{want}»")


def expect_prefix(label, command, want):
    status, got = run(command)
    return judge(label, got, status, got.startswith(want), f"«{want}…»")


def expect_match(label, command, pattern):
    status, got = run(command)
    return judge(label, got, status, re.fullmatch(pattern, got) is not None, f"/{pattern}/")


def expect_true(label, met, detail):
    return judge(label, detail, 0, met, "true")


def start():
    machine.wait_for_unit("user@1000.service")
    for unit in ["flow-nexus.service", "herdr.service"]:
        machine.wait_for_unit(unit, user="alice")
    machine.wait_until_succeeds(as_alice("herdr workspace list"), timeout=60)
    for socket in ["flow/flow.sock", "flow/flow-meta.sock"]:
        status, _ = machine.execute(f"timeout 30 sh -c 'until test -S {RUNTIME}/{socket}; do sleep 0.2; done'")
        bound = machine.succeed(f"ls -la {RUNTIME}/flow 2>&1 || true")
        assert status == 0, f"{socket} never bound; under {RUNTIME}/flow:\n{bound}"


def write_outcome(line):
    out = os.environ.get("out")
    if out:
        os.makedirs(out, exist_ok=True)
        with open(os.path.join(out, "outcome"), "w") as handle:
            handle.write(line + "\n")
            for step in STEPS:
                handle.write("  " + step + "\n")


def scenario(drive):
    start()
    try:
        drive()
        miss = None
    except Miss as missed:
        miss = str(missed)
    if TARGET == "pass":
        if miss is not None:
            write_outcome(f"{NAME}: failing: {miss}")
            raise Exception(f"flow-test {NAME}: failing (target pass): {miss}")
        write_outcome(f"{NAME}: passing")
        print(f"flow-test {NAME}: passing")
    else:
        if miss is None:
            write_outcome(f"{NAME}: unexpectedly passing (target mind)")
            raise Exception(f"flow-test {NAME}: unexpectedly passing; promote it to target pass")
        write_outcome(f"{NAME}: expected-failing (Mind target): {miss}")
        print(f"flow-test {NAME}: expected-failing (Mind target): {miss}")


# The Nexus's own configuration with a lock lease in seconds.
# MessageNexusBinary is the message-helper's store path unless another is
# given.
def nexus_payload(lease=60, binary=None):
    return NEXUS_TEMPLATE.replace("LEASE", str(lease)).replace("MESSAGE_BINARY", binary or MESSAGE_HELPER)


# Configure.Model.{ Layer Harness Native }: Harness is meta-signal-flow's
# HarnessKind (88f3759: Codex, Claude), Native the model as the harness
# knows it.
def model_payload(layer, model=None):
    return f"Configure.Model.{{ {layer} Claude {model or MODEL} }}"


# Datom's canonical print: one space between tokens and inside every
# bracket and brace, an empty vector as [].
def canonical(text):
    return " ".join(text.split()).replace("[ ]", "[]")


# Configuration.{ Nexus Models Thresholds Modules } as Flow prints it after
# configure(): the Nexus payload, every layer's Model and Threshold in the
# order configure() sent them, then the modules given (already printed).
def configuration_text(modules):
    nexus = nexus_payload()[len("Configure.Nexus."):]
    models = " ".join(f"{{ {layer} Claude {MODEL} }}" for layer in LAYERS)
    thresholds = " ".join(f"{{ {layer} 20 40 }}" for layer in LAYERS)
    return canonical(f"Configuration.{{ {nexus} [ {models} ] [ {thresholds} ] [ {' '.join(modules)} ] }}")


# A Module as Flow prints it: { Key Source Checked }.
def module_text(digest, path="vision/flow.md", topic="flow", checked="false"):
    return f"{{ {{ Vision {topic} }} {{ psyche-skills {digest} {path} }} {checked} }}"


# The Nexus's own configuration, then each layer's model and thresholds,
# over the meta socket. `layers` limits which layers get a model.
def configure(layers=None):
    expect("Configure.Nexus", meta(nexus_payload()), "Configured")
    for layer in layers if layers is not None else LAYERS:
        expect(f"Configure.Model {layer}", meta(model_payload(layer)), "Configured")
    for layer in LAYERS:
        expect(f"Configure.Threshold {layer}", meta(f"Configure.Threshold.{{ {layer} 20 40 }}"), "Configured")


# The fixture module's Blake3, read in the machine.
def module_hash(path="psyche-skills/vision/flow.md"):
    return rig(f"b3sum --no-names {SOURCE_ROOT}/{path}")


# Configure.Module.{ Key Source Checked }, Checked false: the hash is checked
# at the module's first compose. The file is SourceRoot/Repository/Path.
def module_payload(digest, path="vision/flow.md", topic="flow"):
    return f"Configure.Module.{module_text(digest, path, topic)}"


def open_pane(label):
    out = rig(f"herdr workspace create --cwd /home/alice --label {label} --no-focus")
    pane = json.loads(out)["result"]["root_pane"]["pane_id"]
    out = rig(f"herdr pane process-info --pane {pane}")
    pid = json.loads(out)["result"]["process_info"]["shell_pid"]
    print(f"pane {label}: {pane}, shell pid {pid}")
    return pane, int(pid)


def close_pane(pane):
    rig(f"herdr pane close {pane}")


# Process.{ Pid Started }: the pid and the kernel's start time of that pid
# (field 22 of /proc/<pid>/stat, clock ticks since boot).
def started_of(pid):
    return int(machine.succeed(f"cut -d' ' -f22 /proc/{pid}/stat").strip())


def process(pid, started=None):
    return f"{{ {pid} {started_of(pid) if started is None else started} }}"


# Bind.{ Address Process } on the ordinary socket → Bound.FlowId; returns
# the FlowId.
def bind(address, pid):
    reply = expect_match(f"Bind {address}", flow(f"Bind.{{ {address} {process(pid)} }}"), r"Bound\.\S+")
    return reply[len("Bound."):]


# An awake metaflow: a pane's shell bound to the address.
def awake(address, label):
    pane, pid = open_pane(label)
    flow_id = bind(address, pid)
    return pane, pid, flow_id


# An asleep metaflow: bound, then its pane closed. Flow's design names no
# request that puts a metaflow to sleep, so the state is asserted.
def asleep(address, label):
    pane, pid, flow_id = awake(address, label)
    close_pane(pane)
    expect(f"Current {address} after its pane closed", flow(f"Current.{address}"), "Current.Asleep")
    return flow_id


# Runs a shell command inside a pane, so its process descends from the
# pane's shell; returns the command's reply.
def in_pane(pane, command):
    PANE_RUNS[0] += 1
    out = f"/tmp/pane-run-{PANE_RUNS[0]}"
    line = f"{command} > {out}.reply 2>&1; echo $? > {out}.code"
    rig(f"herdr pane run {pane} {shlex.quote(line)}")
    machine.wait_until_succeeds(f"test -s {out}.code", timeout=60)
    code = machine.succeed(f"cat {out}.code").strip()
    reply = machine.succeed(f"cat {out}.reply").strip()
    return code, reply


def pane_shows(label, pane, text):
    status, out = run(f"herdr pane wait-output {pane} --match {shlex.quote(text)} --timeout 15000")
    return judge(label, f"pane {pane} shows «{text}»" if status == 0 else out, status, status == 0, f"pane shows «{text}»")


def pane_lacks(label, pane, text):
    out = rig(f"herdr pane read {pane} --source recent --format text")
    return judge(label, f"pane {pane} {'shows' if text in out else 'lacks'} «{text}»", 0, text not in out, f"pane lacks «{text}»")


# The sender most scenarios lock from: Message identifies a sender through
# Identify and passes it as the Lock's Sender.
PSYCHE = "{ Psyche nexus Secondary }"


# Lock.{ Sender Recipient }, Recipient.[ Address Up ]: an address is
# written as the variant `Address.{ Mind nexus Secondary }`, a lock up as
# `Up`, resolved by Flow relative to the Sender.
def lock_datom(sender, recipient):
    target = "Up" if recipient == "Up" else f"Address.{recipient}"
    return f"Lock.{{ {sender} {target} }}"


# Locked.Lock → (the lock as written, its Until). The Lock is
# { Sender Address Until }: Until, the lapse time, is its one integer.
def lock_of(reply):
    body = reply[len("Locked."):]
    numbers = re.findall(r"\d+", body)
    if not numbers:
        raise Miss(f"no Until in «{reply}»")
    return body, int(numbers[-1])


# The Message stand-in. Lock, Deliver and Release are accepted only from
# the bound Message process, its pid, start time and executable (resolved)
# matching; a Bind as Message only from MessageNexusBinary, here
# message-helper (a copy of the flow client in its own store path). Each
# gated request runs in a fresh process that waits, is bound as Message by
# message-helper (a Bind over a gone process replaces it), and then execs
# `binary` (message-helper unless a scenario gives another), keeping its
# pid and start time, so the bound process is the one that connects.
MESSAGE = "{ Field message Primary }"
MESSAGE_RUNS = [0]


# Bind as Message, made by message-helper (MessageNexusBinary) unless
# another client is given.
def bind_message(pid, client="message-helper"):
    datom = f"Bind.{{ {MESSAGE} {process(pid)} }}"
    return expect_match(f"Bind {MESSAGE} by {client}", f"{client} {shlex.quote(datom)}", r"Bound\.\S+")


def as_message(datom, binary="message-helper"):
    MESSAGE_RUNS[0] += 1
    base = f"/tmp/message-{MESSAGE_RUNS[0]}"
    inner = f'echo $$ > {base}.pid; read -r go < {base}.go; exec {binary} "$1"'
    rig(f"mkfifo {base}.go")
    rig(f"(sh -c {shlex.quote(inner)} _ {shlex.quote(datom)} > {base}.reply 2>&1; echo $? > {base}.code) > /dev/null 2>&1 &")
    machine.wait_until_succeeds(f"test -s {base}.pid", timeout=30)
    pid = int(machine.succeed(f"cat {base}.pid").strip())
    bind_message(pid)
    machine.succeed(f"echo go > {base}.go")
    machine.wait_until_succeeds(f"test -s {base}.code", timeout=60)
    code = machine.succeed(f"cat {base}.code").strip()
    reply = machine.succeed(f"cat {base}.reply").strip()
    return code, reply


def expect_message(label, datom, want, prefix=False):
    code, got = as_message(datom)
    met = got.startswith(want) if prefix else got == want
    return judge(label, got, code, met, f"«{want}{'…' if prefix else ''}»")


def lock(sender, recipient, label="Lock"):
    reply = expect_message(f"{label} {recipient} from {sender}", lock_datom(sender, recipient), "Locked.", prefix=True)
    return lock_of(reply)


# Deliver.{ Lock Request }: the sender is inside the lock.
def deliver(held, request):
    return f"Deliver.{{ {held} {request} }}"


def set_clock_past(until):
    machine.succeed(f"date -s @{until + 1}")

# Report.{ FlowId Event }, the hook's request, for a bound flow: each
# event of signal-flow (Started, ToolUsed.String, ContextMeasured.{ Tokens
# Window }, Stopped) answers Reported.
# Target: mind.
args@{ flake, ... }:
flake.lib.flowScenario args {
  name = "flow-report";
  target = "mind";
  script = ''
    configure()
    _, _, flow_id = awake("{ Mind nexus Secondary }", "mind")
    for event in ["Started", "ToolUsed.Bash", "ContextMeasured.{ 50000 200000 }", "Stopped"]:
        expect(f"Report {event}", flow(f"Report.{{ {flow_id} {event} }}"), "Reported")
  '';
}

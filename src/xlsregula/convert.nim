## convert.nim -- Convert parsed table rows into regula Rule IR.
{.experimental: "strict_funcs".}
import std/strutils
import lattice, parse

type
  RuleCondition* = object
    field*: string
    op*: string      ## "==", "!=", ">", "<", ">=", "<="
    value*: string

  RuleAction* = object
    field*: string
    value*: string

  ConvertedRule* = object
    name*: string
    conditions*: seq[RuleCondition]
    actions*: seq[RuleAction]

proc parse_condition(header: string, cell: string): RuleCondition =
  let trimmed = cell.strip()
  if trimmed.startsWith(">="):
    RuleCondition(field: header, op: ">=", value: trimmed[2..^1].strip())
  elif trimmed.startsWith("<="):
    RuleCondition(field: header, op: "<=", value: trimmed[2..^1].strip())
  elif trimmed.startsWith("!="):
    RuleCondition(field: header, op: "!=", value: trimmed[2..^1].strip())
  elif trimmed.startsWith(">"):
    RuleCondition(field: header, op: ">", value: trimmed[1..^1].strip())
  elif trimmed.startsWith("<"):
    RuleCondition(field: header, op: "<", value: trimmed[1..^1].strip())
  else:
    RuleCondition(field: header, op: "==", value: trimmed)

proc convert_table*(dt: DecisionTable): Result[seq[ConvertedRule], BridgeError] =
  var rules: seq[ConvertedRule]
  for row_idx, row in dt.rows:
    var rule = ConvertedRule(name: dt.name & "_rule_" & $row_idx)
    for ci in dt.condition_cols:
      if ci < row.len and row[ci].strip().len > 0:
        rule.conditions.add(parse_condition(dt.headers[ci], row[ci]))
    for ai in dt.action_cols:
      if ai < row.len and row[ai].strip().len > 0:
        rule.actions.add(RuleAction(field: dt.headers[ai], value: row[ai].strip()))
    if rule.actions.len > 0:
      rules.add(rule)
  Result[seq[ConvertedRule], BridgeError].good(rules)

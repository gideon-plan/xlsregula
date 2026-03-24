{.experimental: "strict_funcs".}
import std/unittest
import xlsregula

suite "parse":
  test "detect layout":
    let (conds, acts) = detect_layout(@["If Age", "If Income", "Then Risk"])
    check conds.len == 2
    check acts.len == 1

  test "parse decision table":
    let rows = @[@["If Age", "Then Action"], @[">=18", "approve"], @["<18", "deny"]]
    let r = parse_decision_table(rows, "age_table")
    check r.is_good
    check r.val.rows.len == 2

suite "convert":
  test "convert table to rules":
    let rows = @[@["If Age", "Then Action"], @[">=30", "gold"], @["<30", "silver"]]
    let dt = parse_decision_table(rows, "test")
    check dt.is_good
    let rules = convert_table(dt.val)
    check rules.is_good
    check rules.val.len == 2
    check rules.val[0].conditions[0].op == ">="
    check rules.val[0].conditions[0].value == "30"

suite "load":
  test "end-to-end load":
    let rows = @[@["If X", "Then Y"], @["1", "a"]]
    let r = load_decision_table(rows, "test")
    check r.is_good
    check r.val.rule_count == 1

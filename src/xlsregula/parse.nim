## parse.nim -- Read XLS/XLSX sheets, detect decision table layout.
{.experimental: "strict_funcs".}
import std/strutils
import lattice

type
  CellValue* = string
  SheetRow* = seq[CellValue]
  DecisionTable* = object
    name*: string
    headers*: seq[string]
    condition_cols*: seq[int]
    action_cols*: seq[int]
    rows*: seq[SheetRow]

  ReadSheetFn* = proc(path: string, sheet: int): Result[seq[SheetRow], BridgeError] {.raises: [].}

proc detect_layout*(headers: seq[string]): tuple[conditions: seq[int], actions: seq[int]] =
  for i, h in headers:
    let lower = h.toLowerAscii()
    if lower.startsWith("if") or lower.startsWith("condition") or lower.startsWith("when"):
      result.conditions.add(i)
    elif lower.startsWith("then") or lower.startsWith("action") or lower.startsWith("do"):
      result.actions.add(i)
    else:
      result.conditions.add(i)  # default: treat as condition

proc parse_decision_table*(rows: seq[SheetRow], name: string = "table"
                          ): Result[DecisionTable, BridgeError] =
  if rows.len < 2:
    return Result[DecisionTable, BridgeError].bad(BridgeError(msg: "table too short"))
  let headers = rows[0]
  let (conds, acts) = detect_layout(headers)
  if acts.len == 0:
    return Result[DecisionTable, BridgeError].bad(BridgeError(msg: "no action columns detected"))
  Result[DecisionTable, BridgeError].good(
    DecisionTable(name: name, headers: headers, condition_cols: conds,
                  action_cols: acts, rows: rows[1 ..< rows.len]))

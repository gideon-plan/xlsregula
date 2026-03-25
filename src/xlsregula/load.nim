## load.nim -- End-to-end: open spreadsheet -> parse tables -> compile rules.
{.experimental: "strict_funcs".}
import basis/code/choice, parse, convert

type
  LoadResult* = object
    table_name*: string
    rules*: seq[ConvertedRule]
    rule_count*: int

proc load_decision_table*(rows: seq[SheetRow], name: string = "table"
                         ): Choice[LoadResult] =
  let dt = parse_decision_table(rows, name)
  if dt.is_bad: return bad[LoadResult](dt.err)
  let rules = convert_table(dt.val)
  if rules.is_bad: return bad[LoadResult](rules.err)
  good(
    LoadResult(table_name: name, rules: rules.val, rule_count: rules.val.len))

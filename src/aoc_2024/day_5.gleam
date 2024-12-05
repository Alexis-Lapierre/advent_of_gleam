import gleam/int
import gleam/list
import gleam/result
import gleam/string

type Input =
  #(List(#(Int, Int)), List(List(Int)))

pub fn parse(input: String) -> Input {
  input |> string.split("\n") |> do_parse
}

fn do_parse(input: List(String)) -> Input {
  let parse_int = fn(in: String) {
    int.parse(in) |> result.lazy_unwrap(fn() { panic as "unwrap" })
  }
  let assert [x, ..xs] = input
  case x {
    "" -> #(
      [],
      list.map(xs, fn(line) {
        line
        |> string.split(",")
        |> list.map(parse_int)
      }),
    )
    _ -> {
      let assert [first, second] = string.split(x, "|")
      let first = first |> parse_int
      let second = second |> parse_int

      let tail = do_parse(xs)
      #([#(first, second), ..tail.0], tail.1)
    }
  }
}

pub fn pt_1(input: Input) {
  let #(rules, books_pages) = input
  books_pages |> list.map(do_silver(rules, _)) |> int.sum
}

fn do_silver(rules: List(#(Int, Int)), pages: List(Int)) -> Int {
  case rules |> list.all(check_rule(_, pages)) {
    True ->
      list.drop(pages, up_to: list.length(pages) / 2)
      |> list.first
      |> result.lazy_unwrap(fn() { panic })

    False -> 0
  }
}

fn check_rule(rule: #(Int, Int), pages: List(Int)) -> Bool {
  let matching =
    pages
    |> list.filter(fn(page) { page == rule.0 || page == rule.1 })
  let _ = rule
  case matching {
    [left, right] -> {
      left == rule.0 && right == rule.1
    }
    [_] | [] -> True
    [_, _, ..] -> panic as "more than two matches?"
  }
}

pub fn pt_2(input: Input) {
  let #(rules, books_pages) = input
  books_pages |> list.map(do_gold(rules, _)) |> int.sum
}

fn do_gold(rules: List(#(Int, Int)), pages: List(Int)) -> Int {
  let invalid = rules |> list.filter(fn(rule) { !check_rule(rule, pages) })
  case invalid {
    [] -> 0
    _ -> fix_rules(rules, invalid, pages) |> do_silver(rules, _)
  }
}

fn fix_rules(
  all_rules: List(#(Int, Int)),
  rules: List(#(Int, Int)),
  pages: List(Int),
) -> List(Int) {
  let #(changes, result) =
    rules
    |> list.fold(#(False, pages), fn(acc, rule) {
      let res = fix_rule(rule, acc.1)
      #(acc.0 || res.0, res.1)
    })

  case changes {
    True ->
      get_invalid(all_rules, result)
      |> fix_rules(all_rules, _, result)
    False -> result
  }
}

fn get_invalid(
  all_rules: List(#(Int, Int)),
  pages: List(Int),
) -> List(#(Int, Int)) {
  all_rules |> list.filter(fn(rule) { !check_rule(rule, pages) })
}

fn fix_rule(rule: #(Int, Int), pages: List(Int)) -> #(Bool, List(Int)) {
  let changes =
    pages
    |> list.filter(fn(page) { page != rule.1 })
    |> add_right_back(rule.0, rule.1, _)
  #(changes != pages, changes)
}

fn add_right_back(after: Int, insert: Int, on: List(Int)) -> List(Int) {
  case on {
    [] -> panic
    [x, ..xs] if x == after -> [x, insert, ..xs]
    [x, ..xs] -> [x, ..add_right_back(after, insert, xs)]
  }
}

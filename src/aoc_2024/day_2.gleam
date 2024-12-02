import gleam/int
import gleam/list
import gleam/option.{Some}
import gleam/regexp
import gleam/result
import gleam/string

pub fn parse(input: String) -> List(List(Int)) {
  string.split(input, "\n")
  |> list.map(parse_line)
}

fn parse_line(input: String) -> List(Int) {
  let assert Ok(re) = regexp.from_string("(\\d++)")

  regexp.scan(re, input)
  |> list.map(fn(match) {
    let assert [Some(content)] = match.submatches
    int.parse(content) |> result.lazy_unwrap(fn() { panic })
  })
}

pub fn pt_1(input: List(List(Int))) -> Int {
  input |> list.count(silver_line)
}

fn silver_line(input: List(Int)) -> Bool {
  let assert [x, ..xs] = input
  let #(_x, delta) = list.map_fold(xs, x, fn(acc, a) { #(a, acc - a) })
  let assert [head, ..tail] = delta
  list.all(delta, fn(elem) {
    case int.absolute_value(elem) {
      1 | 2 | 3 -> True
      _ -> False
    }
  })
  && all_same_sign(head, tail)
}

fn all_same_sign(sign: Int, list: List(Int)) -> Bool {
  case list {
    [x, ..xs] ->
      case { x * sign } > 0 {
        True -> all_same_sign(sign, xs)
        False -> False
      }
    _ -> True
  }
}

pub fn pt_2(input: List(List(Int))) {
  input
  |> list.count(fn(line) {
    silver_line(line)
    || list.combinations(line, list.length(line) - 1)
    |> list.any(silver_line)
  })
}

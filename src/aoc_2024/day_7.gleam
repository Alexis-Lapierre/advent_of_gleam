import gleam/int
import gleam/list
import gleam/result
import gleam/string
import gleam/yielder.{type Yielder}

pub type InputLine {
  InputLine(number: Int, operations: List(Int))
}

pub type Input =
  List(InputLine)

pub fn parse(input: String) -> Input {
  use line <- list.map(string.split(input, "\n"))
  let assert Ok(#(left, right)) = string.split_once(line, ": ")
  InputLine(to_int(left), string.split(right, " ") |> list.map(to_int))
}

fn list_posibilities(
  possible_operation: fn(Int, Int) -> List(Int),
  input: List(Int),
) -> Yielder(Int) {
  let assert [x, ..xs] = input
  do_list_posibilities(possible_operation, x, xs)
}

fn do_list_posibilities(
  possible_operation: fn(Int, Int) -> List(Int),
  previous: Int,
  in: List(Int),
) -> Yielder(Int) {
  case in {
    [] -> yielder.single(previous)
    [x, ..xs] ->
      possible_operation(previous, x)
      |> yielder.from_list
      |> yielder.flat_map(do_list_posibilities(possible_operation, _, xs))
  }
}

fn silver_posibilities(previous: Int, current: Int) -> List(Int) {
  [previous + current, previous * current]
}

fn gold_posibilities(previous: Int, current: Int) -> List(Int) {
  [
    { int.to_string(previous) <> int.to_string(current) } |> to_int,
    ..silver_posibilities(previous, current)
  ]
}

fn solve(input: Input, algo: fn(Int, Int) -> List(Int)) -> Int {
  list.filter(input, fn(line) {
    list_posibilities(algo, line.operations)
    |> yielder.any(fn(combinaison) { combinaison == line.number })
  })
  |> list.fold(0, fn(acc, line) { acc + line.number })
}

pub fn pt_1(input: Input) {
  solve(input, silver_posibilities)
}

pub fn pt_2(input: Input) {
  solve(input, gold_posibilities)
}

fn to_int(in: String) -> Int {
  int.parse(in) |> result.lazy_unwrap(fn() { panic as "unwrap" })
}

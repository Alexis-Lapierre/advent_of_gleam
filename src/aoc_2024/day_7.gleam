import gleam/bool
import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/string
import gleam/yielder.{type Yielder, Done}

pub opaque type InputLine {
  InputLine(number: Int, operations: List(Int))
}

pub type Input =
  List(InputLine)

pub fn parse(input: String) -> Input {
  use line <- list.map(string.split(input, "\n"))
  let assert Ok(#(left, right)) = string.split_once(line, ": ")
  InputLine(to_int(left), string.split(right, " ") |> list.map(to_int))
}

fn to_int(in: String) -> Int {
  int.parse(in) |> result.lazy_unwrap(fn() { panic as "unwrap" })
}

fn list_add_sum_posibilities(in: List(Int), previous: Int) -> Yielder(Int) {
  let from_list = fn(x) {
    [previous + x, previous * x]
    |> yielder.from_list
  }
  case in {
    [] -> yielder.single(previous)
    [x, ..xs] -> {
      yielder.flat_map(from_list(x), list_add_sum_posibilities(xs, _))
    }
  }
}

fn list_concat_posibilities(in: List(Int), previous: Int) -> Yielder(Int) {
  let or_operator = fn(x) {
    { int.to_string(previous) <> int.to_string(x) }
    |> to_int
  }
  let from_list = fn(x) {
    [previous + x, previous * x, or_operator(x)]
    |> yielder.from_list
  }

  case in {
    [] -> yielder.single(previous)
    [x, ..xs] -> {
      yielder.flat_map(from_list(x), list_concat_posibilities(xs, _))
    }
  }
}

pub fn pt_1(input: Input) {
  list.filter(input, fn(line) {
    let assert [x, ..xs] = line.operations
    list_add_sum_posibilities(xs, x)
    |> yielder.any(fn(combinaison) { combinaison == line.number })
  })
  |> list.map(fn(line) { line.number })
  |> int.sum
}

pub fn pt_2(input: Input) {
  list.filter(input, fn(line) {
    let assert [x, ..xs] = line.operations
    list_concat_posibilities(xs, x)
    |> yielder.any(fn(combinaison) { combinaison == line.number })
  })
  |> list.map(fn(line) { line.number })
  |> int.sum
}

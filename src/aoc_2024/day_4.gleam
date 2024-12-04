import gleam/int
import gleam/list
import gleam/result
import gleam/string
import gleam/yielder

pub fn pt_1(input: String) {
  let input = input |> string.split("\n")
  let line_count = input |> list.fold(0, fn(acc, in) { silver_line(in) + acc })
  line_count + silver_diag(input)
}

fn silver_line(line: String) -> Int {
  case line {
    "XMAS" <> xs -> 1 + silver_line("S" <> xs)
    "SAMX" <> xs -> 1 + silver_line("X" <> xs)
    _ ->
      case string.pop_grapheme(line) {
        Ok(#(_, xs)) -> silver_line(xs)
        _ -> 0
      }
  }
}

fn silver_diag(input: List(String)) -> Int {
  list.map(input, fn(line) { line |> string.to_graphemes |> enumerate })
  |> do_silver_diagonals
}

fn do_silver_diagonals(list: List(List(#(Int, String)))) -> Int {
  case list {
    [x, ..xs] -> {
      list.fold(x, 0, fn(acc, elem) {
        let #(column_index, _char) = elem
        acc + count_xmas_down(column_index, list)
      })
      + do_silver_diagonals(xs)
    }
    _ -> 0
  }
}

fn silver_check_down(
  current_column: Int,
  delta: Int,
  input: List(List(#(Int, String))),
) -> List(String) {
  case input {
    [] -> []
    [x, ..xs] -> {
      case list.key_find(x, current_column) {
        Ok(char) -> [
          char,
          ..silver_check_down(current_column + delta, delta, xs)
        ]
        _ -> []
      }
    }
  }
}

fn count_xmas_down(
  current_column: Int,
  input: List(List(#(Int, String))),
) -> Int {
  yielder.range(from: -1, to: 1)
  |> yielder.fold(0, fn(acc, delta) {
    acc
    + case silver_check_down(current_column, delta, input) {
      ["X", "M", "A", "S", ..] -> 1
      ["S", "A", "M", "X", ..] -> 1
      _ -> 0
    }
  })
}

type GoldLine =
  #(Int, List(#(Int, String)))

pub fn pt_2(input: String) {
  let gold_input =
    string.split(input, "\n")
    |> list.index_map(fn(elem, index) {
      #(index, elem |> string.to_graphemes |> enumerate)
    })

  list.map(gold_input, gold_line(gold_input, _))
  |> int.sum
}

fn gold_line(input: List(GoldLine), line: GoldLine) -> Int {
  let #(column, line) = line
  list.fold(line, 0, fn(acc, elem) {
    case elem {
      #(row, "A") -> acc + gold_do_crisscross(input, column, row)
      _ -> acc
    }
  })
}

fn gold_do_crisscross(input: List(GoldLine), column: Int, row: Int) -> Int {
  let find = fn(column, row) {
    list.key_find(input, column)
    |> result.try(fn(line) { line |> list.key_find(row) })
  }

  let criss_cross = fn(right, left) {
    case right, left {
      "M", "S" | "S", "M" -> True
      _, _ -> False
    }
  }
  result.all([
    find(column - 1, row - 1),
    find(column - 1, row + 1),
    find(column + 1, row - 1),
    find(column + 1, row + 1),
  ])
  |> result.map(fn(in) {
    let assert [topleft, topright, bottomleft, bottomright] = in
    let right = criss_cross(topleft, bottomright)
    let left = criss_cross(topright, bottomleft)
    case left && right {
      True -> 1
      _ -> 0
    }
  })
  |> result.unwrap(0)
}

fn enumerate(in: List(a)) -> List(#(Int, a)) {
  in |> list.index_map(with: fn(elem, index) { #(index, elem) })
}

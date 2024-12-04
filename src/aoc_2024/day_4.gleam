import gleam/io
import gleam/list
import gleam/result
import gleam/string

pub fn pt_1(input: String) {
  let input = input |> string.split("\n")
  let regular =
    input
    |> silver_1d_parse
  regular + { { silver_diag(input) } + { silver_diag(input |> list.reverse) } }
}

fn silver_line(line: String) -> Int {
  case line {
    "XMAS" <> xs -> 1 + silver_line(xs)
    "" -> 0
    _ -> {
      let assert Ok(#(_x, xs)) = string.pop_grapheme(line)
      silver_line(xs)
    }
  }
}

fn silver_1d_parse(input: List(String)) -> Int {
  input
  |> list.fold(0, fn(acc, line) {
    acc + silver_line(line) + silver_line(line |> string.reverse)
  })
}

fn silver_rotate(input: List(String)) -> List(String) {
  input
  |> list.map(string.split(_, ""))
  |> list.transpose()
  |> list.map(list.fold(_, "", string.append))
}

fn silver_diag(input: List(String)) -> Int {
  let input =
    input
    |> list.map(fn(line) {
      string.split(line, "")
      |> list.index_map(fn(char, index) { #(index, char) })
    })

  input |> do_silver_diag
}

fn do_silver_diag(fuck: List(List(#(Int, String)))) -> Int {
  case fuck {
    [] -> 0
    [x, ..xs] -> {
      list.fold(x, 0, fn(acc, elem) {
        let #(column_index, _char) = elem
        acc + count_xmas_down(column_index, fuck)
      })
      + do_silver_diag(xs)
    }
  }
}

fn silver_check_down(
  current_column: Int,
  delta: Int,
  input: List(List(#(Int, String))),
) -> String {
  case input {
    [] -> ""
    [x, ..xs] -> {
      case list.key_find(x, current_column) {
        Ok(char) ->
          string.append(
            char,
            silver_check_down(current_column + delta, delta, xs),
          )
        _ -> ""
      }
    }
  }
}

fn count_xmas_down(
  current_column: Int,
  input: List(List(#(Int, String))),
) -> Int {
  list.fold([-1, 0, 1], 0, fn(acc, delta) {
    acc
    + case silver_check_down(current_column, delta, input) {
      "XMAS" <> _ -> 1
      _ -> 0
    }
  })
}

type GoldData =
  List(GoldLine)

type GoldLine =
  #(Int, GoldLineChars)

type GoldLineChars =
  List(#(Int, String))

pub fn pt_2(input: String) {
  let input = input |> gold_input
  input
  |> list.fold(0, fn(acc, elem) { acc + gold_line(input, elem) })
}

fn gold_line(input: GoldData, line: GoldLine) -> Int {
  let #(column, line) = line
  line
  |> list.fold(0, fn(acc, elem) {
    let #(row, char) = elem
    case char {
      "A" -> acc + gold_do_crisscross(input, column, row)
      _ -> acc
    }
  })
}

fn gold_do_crisscross(input: GoldData, column: Int, row: Int) -> Int {
  let topleft = find_in_2d(input, column - 1, row - 1)
  let topright = find_in_2d(input, column - 1, row + 1)
  let bottomleft = find_in_2d(input, column + 1, row - 1)
  let bottomright = find_in_2d(input, column + 1, row + 1)

  result.all([topleft, topright, bottomleft, bottomright])
  |> result.map(fn(in) {
    let assert [topleft, topright, bottomleft, bottomright] = in
    let right = case topleft, bottomright {
      "M", "S" -> True
      "S", "M" -> True
      _, _ -> False
    }
    let left = case topright, bottomleft {
      "M", "S" -> True
      "S", "M" -> True
      _, _ -> False
    }
    case left && right {
      True -> 1
      _ -> 0
    }
  })
  |> result.unwrap(0)
}

fn find_in_2d(input: GoldData, column: Int, row: Int) -> Result(String, Nil) {
  input
  |> list.key_find(column)
  |> result.try(fn(line) { line |> list.key_find(row) })
}

fn gold_input(input: String) -> List(#(Int, List(#(Int, String)))) {
  input
  |> string.split("\n")
  |> list.index_map(fn(elem, index) {
    #(
      index,
      elem
        |> string.split("")
        |> list.index_map(fn(char, index) { #(index, char) }),
    )
  })
}

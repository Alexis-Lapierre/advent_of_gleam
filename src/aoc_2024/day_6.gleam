import gleam/bool
import gleam/function
import gleam/int
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/set.{type Set}
import gleam/string
import gleam/yielder.{type Step, type Yielder, Done, Next}

pub type Cell {
  Empty
  Crate
}

pub type Direction {
  Up
  Down
  Right
  Left
}

pub type Position =
  #(Int, Int)

pub type Gard {
  Gard(facing: Direction, pos: Position)
}

pub type Input =
  #(Gard, List(List(Cell)))

pub fn parse(input: String) -> Input {
  let res =
    input
    |> string.split("\n")
    |> list.index_fold(#(None, []), fn(acc, line, line_number) {
      let line_res =
        line
        |> string.to_graphemes
        |> list.index_fold(#(None, []), fn(acc, char, char_number) -> #(
          Option(Gard),
          List(Cell),
        ) {
          let position = #(line_number, char_number)
          let cell = fn(cell) { list.append(acc.1, [cell]) }
          case char {
            "^" -> #(Some(Gard(Up, position)), cell(Empty))
            ">" -> #(Some(Gard(Right, position)), cell(Empty))
            "v" -> #(Some(Gard(Down, position)), cell(Empty))
            "<" -> #(Some(Gard(Left, position)), cell(Empty))
            "#" -> #(acc.0, cell(Crate))
            "." -> #(acc.0, cell(Empty))
            _ -> panic
          }
        })
      case line_res.0 {
        Some(gard) -> #(Some(gard), list.append(acc.1, [line_res.1]))
        _ -> #(acc.0, list.append(acc.1, [line_res.1]))
      }
    })

  let assert Some(gard) = res.0
  #(gard, res.1)
}

fn walk(gard: Gard, map: List(List(Cell))) -> Option(Gard) {
  let Gard(direction, pos) = gard
  let new_gard = case direction {
    Up -> Gard(Up, #(pos.0 - 1, pos.1))
    Down -> Gard(Down, #(pos.0 + 1, pos.1))
    Left -> Gard(Left, #(pos.0, pos.1 - 1))
    Right -> Gard(Right, #(pos.0, pos.1 + 1))
  }

  case at(new_gard.pos.0, new_gard.pos.1, map) {
    None -> None
    Some(Crate) -> walk(gard |> rotate, map)
    Some(Empty) -> Some(new_gard)
  }
}

fn rotate(gard: Gard) -> Gard {
  let direction = case gard.facing {
    Up -> Right
    Right -> Down
    Down -> Left
    Left -> Up
  }
  Gard(direction, gard.pos)
}

fn at(x: Int, y: Int, list: List(List(a))) -> Option(a) {
  case x >= 0 && y >= 0 {
    True ->
      case list |> list.drop(up_to: x) {
        [] -> None
        [x, ..] -> {
          case x |> list.drop(up_to: y) {
            [] -> None
            [x, ..] -> Some(x)
          }
        }
      }
    False -> None
  }
}

pub fn pt_1(input: Input) {
  do_silver(set.new(), input)
}

fn do_silver(walked_on: Set(Position), input: Input) -> Int {
  let walked_on = walked_on |> set.insert({ input.0 }.pos)
  case walk(input.0, input.1) {
    None -> walked_on |> set.size
    Some(gard) -> {
      do_silver(walked_on, #(gard, input.1))
    }
  }
}

pub fn pt_2(input: Input) {
  input
  |> list_all_possible_blocks
  |> yielder.map(do_gold(set.new(), _))
  |> yielder.map(bool.to_int)
  |> yielder.fold(0, int.add)
}

fn list_all_possible_blocks(input: Input) -> Yielder(Input) {
  yielder.unfold(#(0, 0), fn(position) -> Step(Result(Input, Nil), #(Int, Int)) {
    let next_position = fn() {
      let assert [head, ..] = input.1
      case position.1 >= list.length(head) {
        True -> #(position.0 + 1, 0)
        False -> #(position.0, position.1 + 1)
      }
    }
    case input.1 |> list.length < position.0 {
      True -> Done
      False ->
        case at(position.0, position.1, input.1) {
          Some(Crate) | None -> Next(Error(Nil), next_position())
          Some(Empty) ->
            Next(
              Ok(#(input.0, replace_cell(position, input.1))),
              next_position(),
            )
        }
    }
  })
  |> yielder.filter_map(function.identity)
}

fn replace_cell(pos: #(Int, Int), input: List(List(Cell))) -> List(List(Cell)) {
  let assert [x, ..xs] = input
  case pos {
    #(n, _) if n > 0 -> {
      [x, ..replace_cell(#(pos.0 - 1, pos.1), xs)]
    }
    #(0, n) -> {
      let #(left, right) = x |> list.split(n)
      let assert [_, ..right] = right
      [list.append(left, [Crate, ..right]), ..xs]
    }
    _ -> panic
  }
}

fn do_gold(walked_on: Set(Gard), input: Input) -> Bool {
  case walked_on |> set.contains(input.0) {
    True -> True
    False -> {
      let walked_on = walked_on |> set.insert(input.0)
      case walk(input.0, input.1) {
        None -> False
        Some(gard) -> {
          do_gold(walked_on, #(gard, input.1))
        }
      }
    }
  }
}

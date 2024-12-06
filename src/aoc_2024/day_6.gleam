import gleam/bool
import gleam/int
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/pair
import gleam/result
import gleam/set.{type Set}
import gleam/string
import gleam/yielder

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

pub type Position {
  Position(x: Int, y: Int)
}

pub type Gard {
  Gard(facing: Direction, pos: Position)
}

pub type List2D(a) =
  List(List(a))

pub type Input =
  #(Gard, List2D(Cell), Set(Position))

pub fn parse(input: String) -> Input {
  let res =
    string.split(input, "\n")
    |> list.index_fold(#(None, []), fn(acc, line, line_number) {
      let line_res =
        string.to_graphemes(line)
        |> list.index_fold(#(None, []), fn(acc, char, char_number) -> #(
          Option(Gard),
          List(Cell),
        ) {
          let cell = fn(cell) { list.append(acc.1, [cell]) }
          let gard = fn(direction) {
            #(
              Some(Gard(direction, Position(line_number, char_number))),
              cell(Empty),
            )
          }
          case char {
            "^" -> gard(Up)
            ">" -> gard(Right)
            "v" -> gard(Down)
            "<" -> gard(Left)
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

  let assert #(Some(gard), map) = res
  #(gard, map, fill_walked_tile_set(#(gard, map, set.new())))
}

fn walk(gard: Gard, map: List2D(Cell)) -> Option(Gard) {
  let new_pos = {
    let vec = to_vector(gard.facing)
    Position(vec.x + gard.pos.x, vec.y + gard.pos.y)
  }

  case at(map, new_pos) {
    Error(_) -> None
    Ok(Crate) -> walk(Gard(gard.facing |> rotate, gard.pos), map)
    Ok(Empty) -> Some(Gard(gard.facing, new_pos))
  }
}

fn fill_walked_tile_set(input: Input) -> Set(Position) {
  let walked_on = set.insert(input.2, { input.0 }.pos)
  case walk(input.0, input.1) {
    None -> walked_on
    Some(gard) -> {
      fill_walked_tile_set(#(gard, input.1, walked_on))
    }
  }
}

fn rotate(direction: Direction) -> Direction {
  case direction {
    Up -> Right
    Right -> Down
    Down -> Left
    Left -> Up
  }
}

fn at(list: List2D(a), pos: Position) -> Result(a, Nil) {
  case pos.x >= 0 && pos.y >= 0 {
    True -> {
      use x <- result.try(list.drop(list, pos.x) |> list.first)
      list.drop(x, pos.y) |> list.first
    }
    False -> Error(Nil)
  }
}

pub fn pt_1(input: Input) {
  input.2 |> set.size
}

pub fn pt_2(input: Input) {
  set.to_list(input.2)
  |> yielder.from_list
  |> yielder.map(replace_cell(input.1, _))
  |> yielder.map(pair.new(input.0, _))
  |> yielder.map(do_gold(set.new(), _))
  |> yielder.map(bool.to_int)
  |> yielder.fold(0, int.add)
}

fn replace_cell(input: List2D(Cell), pos: Position) -> List2D(Cell) {
  let assert [head, ..tail] = input
  case pos {
    Position(0, n) -> {
      let #(left, right) = list.split(head, n)
      let assert Ok(right) = list.rest(right)
      [list.append(left, [Crate, ..right]), ..tail]
    }
    Position(n, _) -> [head, ..replace_cell(tail, Position(n - 1, pos.y))]
  }
}

pub fn do_gold(walked_on: Set(Gard), input: #(Gard, List2D(Cell))) -> Bool {
  case set.contains(walked_on, input.0) {
    True -> True
    False -> {
      let walked_on = set.insert(walked_on, input.0)
      case walk(input.0, input.1) {
        None -> False
        Some(gard) -> {
          do_gold(walked_on, #(gard, input.1))
        }
      }
    }
  }
}

fn to_vector(in: Direction) -> Position {
  case in {
    Up -> Position(-1, 0)
    Down -> Position(1, 0)
    Left -> Position(0, -1)
    Right -> Position(0, 1)
  }
}

import gleam/bool
import gleam/int
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/pair
import gleam/result
import gleam/set.{type Set}
import gleam/string
import gleam/yielder.{type Yielder}

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
  #(Gard, List2D(Cell))

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

  let assert Some(gard) = res.0
  #(gard, res.1)
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
  list_all_possible_blocks(input.1)
  |> yielder.map(pair.new(input.0, _))
  |> yielder.map(do_gold(set.new(), _))
  |> yielder.map(bool.to_int)
  |> yielder.fold(0, int.add)
}

fn list_all_possible_blocks(input: List2D(Cell)) -> Yielder(List2D(Cell)) {
  let head = list.first(input) |> unwrap
  all_cells(list.length(input), list.length(head))
  |> yielder.filter_map(fn(position) -> Result(List2D(Cell), Nil) {
    case at(input, position) |> unwrap {
      Crate -> Error(Nil)
      Empty -> Ok(replace_cell(input, position))
    }
  })
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

fn all_cells(x_max: Int, y_max: Int) -> Yielder(Position) {
  use x <- yielder.flat_map(yielder.range(from: 0, to: x_max - 1))
  yielder.map(yielder.range(from: 0, to: y_max - 1), Position(x, _))
}

fn to_vector(in: Direction) -> Position {
  case in {
    Up -> Position(-1, 0)
    Down -> Position(1, 0)
    Left -> Position(0, -1)
    Right -> Position(0, 1)
  }
}

fn unwrap(result: Result(a, _)) -> a {
  result.lazy_unwrap(result, fn() { panic as "unwrap" })
}

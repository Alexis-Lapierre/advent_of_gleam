import gleam/bool
import gleam/dict.{type Dict}
import gleam/io
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/pair
import gleam/result
import gleam/string

type Position {
  Position(x: Int, y: Int)
}

type Tile {
  Wall
  Box
}

type Direction {
  Up
  Down
  Right
  Left
}

type Map =
  Dict(Position, Tile)

pub opaque type Input {
  Input(map: Dict(Position, Tile), robot: Position, orders: List(Direction))
}

pub fn parse(input: String) -> Input {
  let assert Ok(#(map, movements)) = string.split_once(input, "\n\n")
  let assert #(map, Some(robot)) = {
    use acc, line, x <- list.index_fold(string.split(map, "\n"), #(
      dict.new(),
      None,
    ))
    use acc, grapheme, y <- list.index_fold(string.to_graphemes(line), acc)
    let point = Position(x, y)
    case grapheme {
      "@" -> #(acc.0, Some(point))
      "#" -> #(dict.insert(acc.0, point, Wall), acc.1)
      "O" -> #(dict.insert(acc.0, point, Box), acc.1)
      _ -> acc
    }
  }
  let orders =
    string.to_graphemes(movements)
    |> list.filter(fn(grapheme) { grapheme != "\n" })
    |> list.map(fn(grapheme) {
      case grapheme {
        "<" -> Left
        ">" -> Right
        "^" -> Up
        "v" -> Down
        _ -> panic
      }
    })

  Input(map, robot, orders)
}

fn move(pos: Position, dir: Direction) -> Position {
  case dir {
    Left -> Position(pos.x, pos.y - 1)
    Right -> Position(pos.x, pos.y + 1)
    Up -> Position(pos.x - 1, pos.y)
    Down -> Position(pos.x + 1, pos.y)
  }
}

fn try_move(
  map: Dict(Position, Tile),
  robot: Position,
  dir: Direction,
) -> #(Dict(Position, Tile), Position) {
  let next = move(robot, dir)
  case dict.get(map, next) {
    Error(_) -> #(map, next)
    Ok(Wall) -> #(map, robot)
    Ok(Box) ->
      case try_move_box(map, next, dir) {
        Ok(map) -> #(map, next)
        Error(_) -> #(map, robot)
      }
  }
}

fn try_gold_move(
  map: Map,
  robot: Position,
  dir: Direction,
) -> #(Dict(Position, Tile), Position) {
  let next = move(robot, dir)
  case gold_get(map, next) {
    None -> #(map, next)
    Some(#(Wall, _)) -> #(map, robot)
    Some(#(Box, pos)) ->
      case try_gold_move_box(map, pos, dir) {
        Ok(map) -> #(map, next)
        Error(_) -> #(map, robot)
      }
  }
}

fn try_gold_move_box(
  map: Map,
  pos: Position,
  dir: Direction,
) -> Result(Map, Nil) {
  case dir {
    Left -> gold_move_left(map, pos, dir)
    Right -> gold_move_right(map, pos, dir)
    Up | Down -> gold_move_updown(map, pos, dir)
  }
}

fn gold_move_left(map, pos, dir) -> Result(Map, Nil) {
  let next = move(pos, dir)

  case gold_get(map, next) {
    None -> Ok(dict.delete(map, pos) |> dict.insert(next, Box))
    Some(#(Box, other_pos)) -> {
      use map <- result.map(gold_move_left(map, other_pos, dir))
      dict.delete(map, pos) |> dict.insert(next, Box)
    }
    _ -> Error(Nil)
  }
}

fn gold_move_right(map, pos, dir) -> Result(Map, Nil) {
  let next = move(pos, dir)
  let nextnext = move(next, dir)

  case dict.get(map, nextnext) {
    Error(_) -> Ok(dict.delete(map, pos) |> dict.insert(next, Box))
    Ok(Box) -> {
      use map <- result.map(gold_move_right(map, nextnext, dir))
      dict.delete(map, pos) |> dict.insert(next, Box)
    }
    _ -> Error(Nil)
  }
}

fn gold_move_updown(map: Map, pos: Position, dir: Direction) -> Result(Map, Nil) {
  let next = move(pos, dir)
  let next_right = move(Position(pos.x, pos.y + 1), dir)

  case gold_get(map, next), gold_get(map, next_right) {
    None, None -> Ok(dict.delete(map, pos) |> dict.insert(next, Box))
    Some(#(Box, pos_a)), Some(#(Box, pos_b)) if pos_a == pos_b -> {
      use map <- result.map(gold_move_updown(map, pos_a, dir))

      dict.delete(map, pos) |> dict.insert(next, Box)
    }
    Some(#(Box, pos_a)), Some(#(Box, pos_b)) -> {
      use map <- result.try(gold_move_updown(map, pos_a, dir))
      use map <- result.map(gold_move_updown(map, pos_b, dir))
      dict.delete(map, pos) |> dict.insert(next, Box)
    }
    Some(#(Box, other_pos)), None -> {
      use map <- result.map(gold_move_updown(map, other_pos, dir))
      dict.delete(map, pos) |> dict.insert(next, Box)
    }
    None, Some(#(Box, other_pos)) -> {
      use map <- result.map(gold_move_updown(map, other_pos, dir))
      dict.delete(map, pos) |> dict.insert(next, Box)
    }
    _, _ -> Error(Nil)
  }
}

fn gold_get(map: Map, at: Position) -> Option(#(Tile, Position)) {
  case dict.get(map, at) {
    Error(_) -> {
      let left = Position(at.x, at.y - 1)
      case dict.get(map, left) {
        Ok(Box) -> Some(#(Box, left))
        _ -> None
      }
    }
    Ok(obj) -> Some(#(obj, at))
  }
}

fn try_move_box(
  map: Map,
  position: Position,
  dir: Direction,
) -> Result(Map, Nil) {
  let next = move(position, dir)
  case dict.get(map, next) {
    Error(_) -> Ok(dict.delete(map, position) |> dict.insert(next, Box))
    Ok(Box) -> {
      use map <- result.map(try_move_box(map, next, dir))
      dict.delete(map, position) |> dict.insert(next, Box)
    }
    Ok(Wall) -> Error(Nil)
  }
}

pub fn pt_1(input: Input) {
  let end_map =
    {
      use acc, order <- list.fold(input.orders, #(input.map, input.robot))
      let #(map, robot) = acc
      try_move(map, robot, order)
    }
    |> pair.first
  use acc, position, tile <- dict.fold(end_map, 0)
  use <- bool.guard(tile == Wall, acc)
  acc + position.x * 100 + position.y
}

fn widen(map: Map) -> Map {
  use acc, key, value <- dict.fold(map, dict.new())
  case value {
    Wall -> {
      dict.insert(acc, Position(key.x, key.y * 2), Wall)
      |> dict.insert(Position(key.x, key.y * 2 + 1), Wall)
    }
    Box -> dict.insert(acc, Position(key.x, key.y * 2), Box)
  }
}

pub fn pt_2(input: Input) {
  let map = input.map |> widen
  let end_map =
    {
      use acc, order <- list.fold(input.orders, #(
        map,
        Position(input.robot.x, input.robot.y * 2),
      ))
      let #(map, robot) = acc

      try_gold_move(map, robot, order)
    }
    |> pair.first
  use acc, position, tile <- dict.fold(end_map, 0)
  use <- bool.guard(tile == Wall, acc)
  io.debug(position)
  acc + position.x * 100 + position.y
}

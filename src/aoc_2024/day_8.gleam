import gleam/dict.{type Dict}
import gleam/list
import gleam/option.{None, Some}
import gleam/set.{type Set}
import gleam/string

type Position {
  Position(x: Int, y: Int)
}

pub opaque type Input {
  Input(dimentions: Position, antenna: Dict(String, List(Position)))
}

pub fn parse(input: String) -> Input {
  let lines = string.split(input, "\n") |> list.map(string.to_graphemes)
  let assert [head, ..] = lines
  let dimentions = Position(list.length(lines), list.length(head))
  let dict = {
    use dict, line, x <- list.index_fold(lines, dict.new())
    use dict, char, y <- list.index_fold(line, dict)
    let current_pos = Position(x, y)
    case char {
      "." -> dict
      _ ->
        dict.upsert(dict, char, fn(maybelist) {
          case maybelist {
            Some(list) -> [current_pos, ..list]
            None -> [current_pos]
          }
        })
    }
  }
  Input(dimentions, dict)
}

fn solve(
  input: Input,
  fun: fn(Position, #(Position, Position)) -> Set(Position),
) -> Int {
  {
    use set, _, antennas <- dict.fold(input.antenna, set.new())
    let combinations = list.combination_pairs(antennas)
    use set, comb <- list.fold(combinations, set)
    set.union(set, fun(input.dimentions, comb))
  }
  |> set.size
}

fn silver(dimention: Position, comb: #(Position, Position)) -> Set(Position) {
  set.new()
  |> set.insert(delta(comb.0, comb.1) |> add(comb.0, _))
  |> set.insert(delta(comb.1, comb.0) |> add(comb.1, _))
  |> set.filter(in_map(dimention, _))
}

fn gold(dimention: Position, comb: #(Position, Position)) -> Set(Position) {
  set.new()
  |> set.union(do_gold(dimention, comb.0, delta(comb.0, comb.1)))
  |> set.union(do_gold(dimention, comb.1, delta(comb.1, comb.0)))
}

fn do_gold(dimention: Position, pos: Position, vec: Position) -> Set(Position) {
  case in_map(dimention, pos) {
    True -> do_gold(dimention, add(pos, vec), vec) |> set.insert(pos)
    False -> set.new()
  }
}

fn delta(a: Position, b: Position) -> Position {
  Position(a.x - b.x, a.y - b.y)
}

fn add(a: Position, vector: Position) -> Position {
  Position(a.x + vector.x, a.y + vector.y)
}

fn in_map(dim: Position, elem: Position) -> Bool {
  elem.x >= 0 && elem.y >= 0 && dim.x > elem.x && dim.y > elem.y
}

pub fn pt_1(input: Input) {
  solve(input, silver)
}

pub fn pt_2(input: Input) {
  solve(input, gold)
}

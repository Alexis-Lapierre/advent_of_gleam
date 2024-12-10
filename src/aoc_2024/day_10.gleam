import gleam/dict.{type Dict}
import gleam/int
import gleam/list
import gleam/pair
import gleam/result
import gleam/set.{type Set}
import gleam/string

pub type Input =
  #(Int, Int)

pub type Map =
  Dict(Point, Int)

pub type Point {
  Point(x: Int, y: Int)
}

pub fn parse(input: String) -> Input {
  let add = fn(a: Input, b: Input) -> Input { #(a.0 + b.0, a.1 + b.1) }
  let map = {
    use dict, line, x <- list.index_fold(string.split(input, "\n"), dict.new())
    use dict, grapheme, y <- list.index_fold(string.to_graphemes(line), dict)
    let assert Ok(grapheme) = int.parse(grapheme)
    dict.insert(dict, Point(x, y), grapheme)
  }
  let start = dict.filter(map, fn(_, height) { height == 0 })
  use acc, point, _ <- dict.fold(start, #(0, 0))
  let list = do_parse(map, point, 1)
  add(acc, #(set.from_list(list) |> set.size, list.length(list)))
}

fn do_parse(map: Map, at: Point, height: Int) -> List(Point) {
  let possible_path =
    [
      Point(at.x - 1, at.y),
      Point(at.x + 1, at.y),
      Point(at.x, at.y - 1),
      Point(at.x, at.y + 1),
    ]
    |> list.filter_map(fn(point) {
      result.map(dict.get(map, point), pair.new(point, _))
    })
    |> list.filter(fn(point) { point.1 == height })
    |> list.map(pair.first)
  case height {
    9 -> possible_path
    _ -> list.map(possible_path, do_parse(map, _, height + 1)) |> list.flatten
  }
}

pub fn pt_1(input: Input) {
  input.0
}

pub fn pt_2(input: Input) {
  input.1
}

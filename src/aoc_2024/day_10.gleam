import gleam/dict.{type Dict}
import gleam/int
import gleam/list
import gleam/pair
import gleam/result
import gleam/set
import gleam/string

pub type Point {
  Point(x: Int, y: Int)
}

pub fn parse(input: String) -> List(List(Point)) {
  let map = {
    use dict, line, x <- list.index_fold(string.split(input, "\n"), dict.new())
    use dict, grapheme, y <- list.index_fold(string.to_graphemes(line), dict)
    let assert Ok(grapheme) = int.parse(grapheme)
    dict.insert(dict, Point(x, y), grapheme)
  }
  dict.filter(map, fn(_, height) { height == 0 })
  |> dict.to_list
  |> list.map(pair.first)
  |> list.map(do_parse(map, _, 1))
}

fn do_parse(map: Dict(Point, Int), at: Point, height: Int) -> List(Point) {
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

pub fn pt_1(input: List(List(Point))) {
  use acc, points <- list.fold(input, 0)
  acc + { set.from_list(points) |> set.size }
}

pub fn pt_2(input: List(List(Point))) {
  input |> list.map(list.length) |> int.sum
}

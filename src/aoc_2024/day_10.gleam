import gleam/dict.{type Dict}
import gleam/int
import gleam/io
import gleam/list
import gleam/pair
import gleam/result
import gleam/set.{type Set}
import gleam/string

pub type Map =
  Dict(Point, Int)

pub type Point {
  Point(x: Int, y: Int)
}

pub fn parse(input: String) -> Map {
  use dict, line, x <- list.index_fold(string.split(input, "\n"), dict.new())
  use dict, grapheme, y <- list.index_fold(string.to_graphemes(line), dict)
  let assert Ok(grapheme) = int.parse(grapheme)
  dict.insert(dict, Point(x, y), grapheme)
}

pub fn pt_1(input: Map) {
  dict.fold(input, 0, fn(acc, point, height) {
    case height {
      0 -> {
        acc + set.size(silver(input, point, 0))
      }
      _ -> acc
    }
  })
}

fn silver(map: Map, point: Point, height: Int) -> Set(Point) {
  let next_height = height + 1
  let possible_path =
    suround(map, point)
    |> list.filter(fn(point) { point.1 == next_height })
    |> list.map(pair.first)

  case next_height {
    9 -> set.from_list(possible_path)
    _ -> {
      use acc, path <- list.fold(possible_path, set.new())
      set.union(acc, silver(map, path, next_height))
    }
  }
}

fn gold(map: Map, point: Point, height: Int) -> Int {
  let next_height = height + 1
  let possible_path =
    suround(map, point)
    |> list.filter(fn(point) { point.1 == next_height })
    |> list.map(pair.first)

  case next_height {
    9 -> list.length(possible_path)
    _ -> {
      use acc, path <- list.fold(possible_path, 0)
      acc + gold(map, path, next_height)
    }
  }
}

pub fn suround(map: Map, at at: Point) -> List(#(Point, Int)) {
  [
    Point(at.x - 1, at.y),
    Point(at.x + 1, at.y),
    Point(at.x, at.y - 1),
    Point(at.x, at.y + 1),
  ]
  |> list.filter_map(fn(point) {
    use height <- result.map(dict.get(map, point))
    #(point, height)
  })
}

pub fn pt_2(input: Map) {
  dict.fold(input, 0, fn(acc, point, height) {
    case height {
      0 -> {
        acc + gold(input, point, 0)
      }
      _ -> acc
    }
  })
}

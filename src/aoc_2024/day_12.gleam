import gleam/dict.{type Dict}
import gleam/int
import gleam/io
import gleam/list
import gleam/option
import gleam/pair
import gleam/result
import gleam/set.{type Set}
import gleam/string

pub type Point {
  Point(x: Int, y: Int)
}

type Direction {
  Up
  Down
  Right
  Left
}

pub fn parse(input: String) -> Dict(Point, String) {
  use dict, line, x <- list.index_fold(string.split(input, "\n"), dict.new())
  use dict, grapheme, y <- list.index_fold(string.to_graphemes(line), dict)
  dict.insert(dict, Point(x, y), grapheme)
}

fn find_patch(
  map: Dict(Point, String),
  visited: Set(Point),
  at: #(Point, String),
) -> #(Dict(Point, String), Set(Point)) {
  let map = dict.delete(map, at.0)
  let visited = set.insert(visited, at.0)

  let #(at, grapheme) = at

  let valid_points = {
    [
      Point(at.x - 1, at.y),
      Point(at.x + 1, at.y),
      Point(at.x, at.y - 1),
      Point(at.x, at.y + 1),
    ]
    |> list.filter_map(fn(point) {
      use other_grapheme <- result.try(dict.get(map, point))
      case other_grapheme == grapheme {
        True -> Ok(point)
        False -> Error(Nil)
      }
    })
  }

  list.fold(valid_points, #(map, visited), fn(acc, point) {
    find_patch(acc.0, acc.1, #(point, grapheme))
  })
}

fn do_all_patches(input: Dict(Point, String)) -> List(Set(Point)) {
  case dict.to_list(input) {
    [] -> []
    [x, ..] -> {
      let #(map, patch) = find_patch(input, set.new(), x)
      [patch, ..do_all_patches(map)]
    }
  }
}

fn edges(patch: Set(Point)) -> Set(#(Point, Int)) {
  use acc, at <- set.fold(patch, set.new())
  set.union(acc, {
    [
      Point(at.x - 1, at.y),
      Point(at.x + 1, at.y),
      Point(at.x, at.y - 1),
      Point(at.x, at.y + 1),
    ]
    |> list.index_map(pair.new)
    |> list.filter(fn(point) { !set.contains(patch, point.0) })
    |> set.from_list
  })
}

fn gold_edges(edges: Set(#(Point, Int))) -> Int {
  let #(left, right) = {
    set.fold(edges, dict.new(), fn(acc, edge) {
      let #(point, direction) = edge
      use option <- dict.upsert(acc, direction)
      [point, ..option.unwrap(option, [])]
    })
    |> dict.fold(#(dict.new(), dict.new()), fn(acc, direction, points) {
      case direction {
        0 | 1 -> #(
          list.fold(points, acc.0, fn(acc, point) {
            use option <- dict.upsert(acc, point.x)
            [point.y, ..option.unwrap(option, [])]
          }),
          acc.1,
        )

        2 | 3 -> #(
          acc.0,
          list.fold(points, acc.1, fn(acc, point) {
            use option <- dict.upsert(acc, point.y)
            [point.x, ..option.unwrap(option, [])]
          }),
        )
        _ -> panic
      }
    })
  }

  dict.fold(left |> io.debug, 0, fn(acc, _, list) {
    {
      list.fold(list |> list.sort(int.compare), #(acc, -999), fn(acc, y) {
        case { acc.1 + 1 } == y {
          True -> #(acc.0, y)
          False -> #(acc.0 + 1, y)
        }
      })
    }.0
  })
  + dict.fold(right |> io.debug, 0, fn(acc, _, list) {
    {
      list.fold(list |> list.sort(int.compare), #(acc, -999), fn(acc, x) {
        case { acc.1 + 1 } == x {
          True -> #(acc.0, x)
          False -> #(acc.0 + 1, x)
        }
      })
    }.0
  })
}

pub fn pt_1(input: Dict(Point, String)) {
  use acc, patch <- list.fold(do_all_patches(input), 0)
  let edges = edges(patch) |> set.size
  let area = set.size(patch) |> io.debug
  io.debug("")
  acc + edges * area
}

pub fn pt_2(input: Dict(Point, String)) {
  use acc, patch <- list.fold(do_all_patches(input), 0)
  let edges = edges(patch) |> gold_edges
  let area = set.size(patch)
  acc + edges * area
}

import gleam/bool
import gleam/dict.{type Dict}
import gleam/int
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

fn group_field(
  map: Dict(Point, String),
  visited: Set(Point),
  field: #(Point, String),
) -> #(Dict(Point, String), Set(Point)) {
  let #(at, grapheme) = field
  list.map(around(at), pair.first)
  |> list.filter_map(fn(point) {
    use other_grapheme <- result.try(dict.get(map, point))
    use <- bool.guard(other_grapheme != grapheme, Error(Nil))
    Ok(point)
  })
  |> list.fold(#(dict.delete(map, at), set.insert(visited, at)), fn(acc, point) {
    group_field(acc.0, acc.1, #(point, grapheme))
  })
}

fn do_all_patches(input: Dict(Point, String)) -> List(Set(Point)) {
  case dict.to_list(input) {
    [] -> []
    [x, ..] -> {
      let #(map, patch) = group_field(input, set.new(), x)
      [patch, ..do_all_patches(map)]
    }
  }
}

fn edges(patch: Set(Point)) -> Set(#(Point, Direction)) {
  use acc, at <- set.fold(patch, set.new())
  set.union(acc, {
    around(at)
    |> list.filter(fn(point) { !set.contains(patch, point.0) })
    |> set.from_list
  })
}

fn gold_edges(edges: Set(#(Point, Direction))) -> Int {
  set.fold(edges, dict.new(), fn(acc, edge) {
    let #(at, dir) = edge
    let #(x, y) = {
      case dir {
        Up | Down -> #(at.x, at.y)
        Right | Left -> #(at.y, at.x)
      }
    }
    use coordinate <- dict.upsert(acc, #(dir, x))
    [y, ..option.unwrap(coordinate, [])]
  })
  |> dict.fold(0, fn(acc, _, list) {
    let assert [x, ..xs] = list.sort(list, int.compare)
    list.fold(xs, #(acc + 1, x), fn(pair, y) {
      let #(acc, previous) = pair
      use <- bool.guard({ previous + 1 } == y, #(acc, y))
      #(acc + 1, y)
    })
    |> pair.first
  })
}

fn around(at: Point) -> List(#(Point, Direction)) {
  [
    #(Point(at.x - 1, at.y), Up),
    #(Point(at.x + 1, at.y), Down),
    #(Point(at.x, at.y - 1), Left),
    #(Point(at.x, at.y + 1), Right),
  ]
}

fn solve(
  input: Dict(Point, String),
  edge_score: fn(Set(#(Point, Direction))) -> Int,
) -> Int {
  use acc, patch <- list.fold(do_all_patches(input), 0)
  let edges = edges(patch) |> edge_score
  let area = set.size(patch)
  acc + edges * area
}

pub fn pt_1(input: Dict(Point, String)) {
  solve(input, set.size)
}

pub fn pt_2(input: Dict(Point, String)) {
  solve(input, gold_edges)
}

import gleam/bool
import gleam/dict.{type Dict}
import gleam/int
import gleam/list
import gleam/order.{Eq, Gt, Lt}
import gleam/result
import gleam/set.{type Set}
import gleam/string

pub opaque type Input {
  Input(
    map: Set(#(Int, Int)),
    reindeer: #(Int, Int),
    direction: #(Int, Int),
    end: #(Int, Int),
  )
}

pub fn parse(input: String) -> Input {
  let empty = Input(set.new(), #(-1, -1), #(0, 1), #(-1, -1))
  use acc, line, x <- list.index_fold(string.split(input, "\n"), empty)
  use acc, grapheme, y <- list.index_fold(string.to_graphemes(line), acc)
  case grapheme {
    "#" -> acc
    "." -> Input(..acc, map: set.insert(acc.map, #(x, y)))
    "S" -> Input(..acc, reindeer: #(x, y))
    "E" -> Input(..acc, map: set.insert(acc.map, #(x, y)), end: #(x, y))
    _ -> panic as "Unexpected character!"
  }
}

fn silver_rotations(current: #(Int, Int)) -> List(#(#(Int, Int), Int)) {
  case current {
    #(0, n) -> [#(#(1, 0), 1001), #(#(-1, 0), 1001), #(#(0, n), 1)]
    #(n, 0) -> [#(#(0, 1), 1001), #(#(0, -1), 1001), #(#(n, 0), 1)]
    _ -> panic as "Unexpected input"
  }
}

fn dijkstra(
  input: Input,
  current_score: Int,
  walked: Dict(#(Int, Int), Int),
  rotations: fn(#(Int, Int)) -> List(#(#(Int, Int), Int)),
) -> Dict(#(Int, Int), Int) {
  use <- bool.guard(
    case dict.get(walked, input.reindeer) {
      Ok(score) if score <= current_score -> True
      _ -> False
    },
    walked,
  )
  rotations(input.direction)
  |> list.fold(
    dict.insert(walked, input.reindeer, current_score),
    fn(walked, pair) {
      let #(direction, points) = pair
      result.map(walk(Input(..input, direction: direction)), dijkstra(
        _,
        current_score + points,
        walked,
        rotations,
      ))
      |> result.unwrap(walked)
    },
  )
}

fn walk(input: Input) -> Result(Input, Nil) {
  let Input(map, #(rx, ry), #(vecx, vecy), ..) = input
  let next = #(rx + vecx, ry + vecy)
  use <- bool.guard(!set.contains(map, next), Error(Nil))
  Ok(Input(..input, reindeer: next))
}

fn surround(place: #(Int, Int)) -> List(#(Int, Int)) {
  let #(x, y) = place
  [#(x + 1, y), #(x - 1, y), #(x, y + 1), #(x, y - 1)]
}

fn count_main_path(end: #(Int, Int), scores: Dict(#(Int, Int), Int)) -> Int {
  let assert Ok(end_score) = dict.get(scores, end)
  let map =
    scores |> dict.fold(set.new(), fn(map, key, _) { set.insert(map, key) })

  dict.map_values(scores, fn(key, score) {
    let min =
      [
        dijkstra(
          Input(map, key, #(-1, 0), end),
          score,
          dict.new(),
          silver_rotations,
        ),
        dijkstra(
          Input(map, key, #(1, 0), end),
          score,
          dict.new(),
          silver_rotations,
        ),
        dijkstra(
          Input(map, key, #(0, -1), end),
          score,
          dict.new(),
          silver_rotations,
        ),
        dijkstra(
          Input(map, key, #(0, 1), end),
          score,
          dict.new(),
          silver_rotations,
        ),
      ]
      |> list.filter_map(dict.get(_, end))
      |> list.fold(99_999_999_999_999_999, int.min)
    case int.compare(min, end_score) {
      Gt -> False
      Lt | Eq -> True
    }
  })
  |> dict.fold(0, fn(acc, _, bool) { acc + bool.to_int(bool) })
}

pub fn pt_1(input: Input) {
  dijkstra(input, 0, dict.new(), silver_rotations)
  |> dict.get(input.end)
  |> result.lazy_unwrap(fn() { panic })
}

pub fn pt_2(input: Input) {
  let res = dijkstra(input, 0, dict.new(), silver_rotations)
  count_main_path(input.end, res)
}

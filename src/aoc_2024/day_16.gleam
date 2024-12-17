import gleam/bool
import gleam/dict.{type Dict}
import gleam/int
import gleam/list
import gleam/result
import gleam/set.{type Set}
import gleam/string

type Tile {
  Empty
  End
}

pub opaque type Input {
  Input(
    map: Dict(#(Int, Int), Tile),
    reindeer: #(Int, Int),
    direction: #(Int, Int),
  )
}

pub fn parse(input: String) -> Input {
  let empty = Input(dict.new(), #(-1, -1), #(0, 1))
  use acc, line, x <- list.index_fold(string.split(input, "\n"), empty)
  use acc, grapheme, y <- list.index_fold(string.to_graphemes(line), acc)
  case grapheme {
    "#" -> acc
    "." ->
      Input(dict.insert(acc.map, #(x, y), Empty), acc.reindeer, acc.direction)
    "S" -> Input(acc.map, #(x, y), acc.direction)
    "E" ->
      Input(dict.insert(acc.map, #(x, y), End), acc.reindeer, acc.direction)
    _ -> panic as "Unexpected character!"
  }
}

fn rotations(current: #(Int, Int)) -> List(#(#(Int, Int), Int)) {
  case current {
    #(0, n) -> [#(#(1, 0), 1000), #(#(-1, 0), 1000), #(#(0, n), 0)]
    #(n, 0) -> [#(#(0, 1), 1000), #(#(0, -1), 1000), #(#(n, 0), 0)]
    _ -> panic as "Unexpected input"
  }
}

fn silver(input: Input, walked: Set(#(Int, Int))) -> Result(Int, Nil) {
  use <- bool.guard(dict.get(input.map, input.reindeer) == Ok(End), Ok(0))
  use <- bool.guard(set.contains(walked, input.reindeer), Error(Nil))
  let walked = set.insert(walked, input.reindeer)

  rotations(input.direction)
  |> list.filter_map(fn(elem) {
    let #(vec, points) = elem
    use input <- result.try(walk(Input(input.map, input.reindeer, vec)))
    use recursion_res <- result.map(silver(input, walked))
    recursion_res + points + 1
  })
  |> list.reduce(int.min)
}

fn walk(input: Input) -> Result(Input, Nil) {
  let Input(map, #(rx, ry), #(vecx, vecy)) = input
  let next = #(rx + vecx, ry + vecy)
  use _tile <- result.map(dict.get(map, next))
  Input(map, next, input.direction)
}

pub fn pt_1(input: Input) {
  let assert Ok(res) = silver(input, set.new())
  res
}

pub fn pt_2(input: Input) {
  todo as "part 2 not implemented"
}

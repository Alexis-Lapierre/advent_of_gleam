import gleam/bool
import gleam/dict.{type Dict}
import gleam/list
import gleam/pair
import gleam/result
import gleam/set.{type Set}
import gleam/string

pub opaque type Input {
  Input(available: List(String), desired: Set(String))
}

pub fn parse(input: String) -> Input {
  let assert Ok(#(available, desired)) = string.split_once(input, "\n\n")
  Input(
    string.split(available, ", "),
    string.split(desired, "\n") |> set.from_list,
  )
}

fn silver(possible: List(String), solve: String) -> Result(Nil, Nil) {
  use <- bool.guard(string.is_empty(solve), Ok(Nil))
  list.find_map(possible, fn(pattern) {
    use <- bool.guard(!string.starts_with(solve, pattern), Error(Nil))
    silver(possible, string.drop_start(solve, string.length(pattern)))
  })
}

fn gold(
  possible: List(String),
  cache: Dict(String, Int),
  solve: String,
) -> #(Int, Dict(String, Int)) {
  use <- bool.guard(string.is_empty(solve), #(1, cache))
  use <- result.lazy_unwrap(
    result.map(dict.get(cache, solve), pair.new(_, cache)),
  )
  let #(score, dict) =
    list.fold(possible, #(0, cache), fn(acc, pattern) {
      use <- bool.guard(!string.starts_with(solve, pattern), acc)
      let #(score, dict) =
        gold(possible, acc.1, string.drop_start(solve, string.length(pattern)))
      #(score + acc.0, dict)
    })
  #(score, dict.insert(dict, solve, score))
}

pub fn pt_1(input: Input) {
  set.fold(input.desired, 0, fn(acc, solve) {
    acc + { silver(input.available, solve) |> result.is_ok |> bool.to_int }
  })
}

pub fn pt_2(input: Input) {
  set.fold(input.desired, #(0, dict.new()), fn(acc, solve) {
    let #(score, dict) = gold(input.available, acc.1, solve)
    #(acc.0 + score, dict)
  })
  |> pair.first
}

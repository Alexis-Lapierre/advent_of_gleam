import gleam/dict.{type Dict}
import gleam/int
import gleam/list
import gleam/option
import gleam/pair
import gleam/result
import gleam/string
import gleam/yielder.{type Yielder, Next}

pub fn parse(input: String) -> List(Int) {
  string.split(input, "\n")
  |> list.map(int.parse)
  |> list.map(result.lazy_unwrap(_, fn() { panic }))
}

fn monkey_secrets(secret: Int) -> Yielder(Int) {
  let algo = fn(secret: Int, op: fn(Int) -> Int) {
    int.bitwise_exclusive_or(op(secret), secret) |> int.bitwise_and(0xffffff)
  }
  yielder.unfold(from: secret, with: fn(secret) {
    let next =
      secret
      |> algo(int.multiply(64, _))
      |> algo(fn(secret) { secret / 32 })
      |> algo(int.multiply(2048, _))
    Next(next, next)
  })
  |> yielder.take(2000)
}

fn delta_scores(in: List(List(#(Int, Int)))) -> Dict(#(Int, Int, Int, Int), Int) {
  use dict, list <- list.fold(in, dict.new())
  list.fold(list.window(list, 4), dict.new(), fn(dict, window) {
    let assert [#(a, _), #(b, _), #(c, _), #(d, score)] = window
    dict.upsert(dict, #(a, b, c, d), option.unwrap(_, score))
  })
  |> dict.combine(dict, int.add)
}

pub fn pt_1(input: List(Int)) {
  use acc, secret <- list.fold(input, 0)
  let assert Ok(last) = monkey_secrets(secret) |> yielder.last
  acc + last
}

pub fn pt_2(input: List(Int)) {
  list.map(input, fn(start) {
    monkey_secrets(start)
    |> yielder.map(fn(banana) { banana % 10 })
    |> yielder.fold(#(9999, []), fn(acc, banana) {
      #(banana, [#(banana - acc.0, banana), ..acc.1])
    })
    |> pair.second
    |> list.reverse
    |> list.drop(1)
  })
  |> delta_scores
  |> dict.fold(0, fn(acc, _, value) { int.max(acc, value) })
}

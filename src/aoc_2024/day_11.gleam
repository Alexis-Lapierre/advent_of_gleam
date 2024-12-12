import gleam/bool
import gleam/dict.{type Dict}
import gleam/int
import gleam/list
import gleam/option
import gleam/result
import gleam/string
import gleam/yielder

pub fn parse(input: String) -> Dict(Int, Int) {
  let initial_stones = {
    string.split(input, " ")
    |> list.map(to_int)
    |> list.fold(dict.new(), fn(dict, stone) { add(dict, stone, 1) })
  }
  yielder.range(from: 1, to: 25)
  |> yielder.fold(initial_stones, fn(dict, _) { blink(dict) })
}

pub fn pt_1(input: Dict(Int, Int)) {
  dict.fold(input, 0, fn(acc, _, count) { acc + count })
}

pub fn pt_2(input: Dict(Int, Int)) {
  yielder.range(from: 25, to: 75)
  |> yielder.fold(input, fn(dict, _) { blink(dict) })
  |> dict.fold(0, fn(acc, _, count) { acc + count })
}

fn blink(input: Dict(Int, Int)) -> Dict(Int, Int) {
  use dict, stone, count <- dict.fold(input, dict.new())
  use <- bool.lazy_guard(stone == 0, fn() { add(dict, 1, count) })
  let str_stone = int.to_string(stone)
  let length = string.length(str_stone)
  case int.is_even(length) {
    False -> add(dict, stone * 2024, count)
    True ->
      add(dict, string.drop_end(str_stone, length / 2) |> to_int, count)
      |> add(string.drop_start(str_stone, length / 2) |> to_int, count)
  }
}

fn add(dict: Dict(a, Int), key: a, count: Int) -> Dict(a, Int) {
  dict.upsert(dict, key, fn(old) { option.unwrap(old, or: 0) + count })
}

fn to_int(in: String) -> Int {
  int.parse(in) |> result.lazy_unwrap(fn() { panic as "unwrap" })
}

import gleam/bool
import gleam/dict.{type Dict}
import gleam/int
import gleam/io
import gleam/list
import gleam/option.{type Option}
import gleam/result
import gleam/set.{type Set}
import gleam/string

pub type Input =
  Dict(String, Set(String))

pub fn parse(input: String) -> Input {
  let add = fn(op: Option(Set(String)), elem: String) {
    option.lazy_unwrap(op, set.new) |> set.insert(elem)
  }
  use dict, res <- list.fold(
    string.split(input, "\n") |> list.map(string.split_once(_, "-")),
    dict.new(),
  )
  let assert Ok(#(left, right)) = res
  dict.upsert(dict, left, add(_, right)) |> dict.upsert(right, add(_, left))
}

fn silver(input: Input) -> Set(#(String, String, String)) {
  use acc, left, lconnection <- dict.fold(input, set.new())
  use acc, middle <- set.fold(lconnection, acc)
  dict.get(input, middle)
  |> result.map(fn(set) {
    use acc, right <- set.fold(set, acc)
    use <- bool.guard(!set.contains(lconnection, right), acc)
    use <- bool.guard(left == right, acc)
    set.insert(acc, {
      let assert [left, middle, right] =
        list.sort([left, middle, right], string.compare)
      #(left, middle, right)
    })
  })
  |> result.unwrap(acc)
}

fn gold(
  input: Input,
  current: String,
  subset: Set(String),
  building: Set(String),
  cuttoff_point: Int,
) -> Set(String) {
  use <- bool.guard(set.contains(building, current), building)
  let assert Ok(current_set) = dict.get(input, current)
  let intersect = set.intersection(current_set, subset)
  let building = building |> set.insert(current)
  use <- bool.guard(
    { set.size(intersect) + set.size(building) } < cuttoff_point,
    building,
  )
  use acc, other <- set.fold(intersect, building)
  max_set(acc, gold(input, other, intersect, building, { set.size(acc) }))
}

fn gold_gold(input: Input, on_key: String, partial: Set(String)) -> Set(String) {
  let assert Ok(value) = dict.get(input, on_key)
  let subset =
    dict.delete(input, on_key)
    |> dict.map_values(fn(_, othervalue) { set.intersection(value, othervalue) })
    |> dict.filter(fn(_, othervalue) { !set.is_empty(othervalue) })
  let new = set.insert(partial, on_key)
  use <- bool.guard(dict.is_empty(subset), new)
  use acc, key, _ <- dict.fold(subset, set.new())
  max_set(acc, gold_gold(subset, key, new))
}

fn max_set(a: Set(a), b: Set(a)) -> Set(a) {
  case set.size(a) < set.size(b) {
    True -> b
    False -> a
  }
}

pub fn pt_1(input: Input) {
  use acc, tuple <- set.fold(silver(input), 0)

  case tuple {
    #("t" <> _, _, _) | #(_, "t" <> _, _) | #(_, _, "t" <> _) -> acc + 1
    _ -> acc
  }
}

pub fn pt_2(input: Input) {
  dict.fold(input, set.new(), fn(acc, key, _) {
    max_set(acc, gold_gold(input, key, set.new()))
  })
  |> set.to_list
  |> list.sort(string.compare)
}

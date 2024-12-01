import gleam/int
import gleam/list
import gleam/option.{Some}
import gleam/regexp
import gleam/result

pub fn parse(input: String) -> #(List(Int), List(Int)) {
  let assert Ok(re) =
    regexp.compile(
      "(\\d++)\\s++(\\d++)",
      regexp.Options(case_insensitive: False, multi_line: True),
    )

  let list =
    input
    |> regexp.scan(re, _)
    |> list.map(fn(line) {
      let assert [Some(left), Some(right)] = line.submatches

      let assert Ok(left) = left |> int.parse
      let assert Ok(right) = right |> int.parse

      #(left, right)
    })

  let left =
    list |> list.map(with: fn(in) { in.0 }) |> list.sort(by: int.compare)
  let right =
    list |> list.map(with: fn(in) { in.1 }) |> list.sort(by: int.compare)

  #(left, right)
}

pub fn pt_1(input: #(List(Int), List(Int))) -> Int {
  input
  |> fn(in) {
    list.strict_zip(in.0, in.1) |> result.lazy_unwrap(fn() { panic })
  }
  |> list.map(fn(in) { int.absolute_value(in.0 - in.1) })
  |> int.sum
}

pub fn pt_2(input: #(List(Int), List(Int))) -> Int {
  let #(left, right) = input

  left
  |> list.fold(from: 0, with: fn(acc, elem) {
    acc + { elem * list.count(right, fn(in) { in == elem }) }
  })
}

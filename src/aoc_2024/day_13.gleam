import gleam/float
import gleam/int
import gleam/list
import gleam/option.{Some}
import gleam/order.{Eq}
import gleam/regexp
import gleam/string

type Point {
  Point(x: Int, y: Int)
}

pub opaque type Input {
  Input(a: Point, b: Point, prize: Point)
}

pub fn parse(input: String) -> List(Input) {
  let assert Ok(re) = regexp.from_string("X[+=](\\d++), Y[+=](\\d++)")
  let input = string.split(input, "\n\n")
  use input <- list.map(input)
  let assert [buttona, buttonb, prize] =
    regexp.scan(re, input)
    |> list.map(fn(match) {
      let assert [x, y] =
        match.submatches
        |> list.map(fn(option) {
          let assert Some(content) = option
          let assert Ok(value) = int.parse(content)
          value
        })
      Point(x, y)
    })
  Input(buttona, buttonb, prize)
}

fn solve(in: Input) -> Result(#(Int, Int), Nil) {
  let compare = fn(a: Point, b: Point) {
    #(int.compare(a.x, b.x), int.compare(a.y, b.y))
  }
  let mul = fn(point: Point, by: Int) -> Point {
    apply(point, int.multiply(by, _))
  }
  let add = fn(a: Point, b: Point) -> Point { Point(a.x + b.x, a.y + b.y) }

  let bax = int.to_float(in.a.x)
  let bay = int.to_float(in.a.y)
  let bbx = int.to_float(in.b.x)
  let bby = int.to_float(in.b.y)
  let px = int.to_float(in.prize.x)
  let py = int.to_float(in.prize.y)

  let b = { bax *. py -. bay *. px } /. { bax *. bby -. bay *. bbx }
  let a = { px -. bbx *. b } /. bax

  let a = float.round(a)
  let b = float.round(b)
  let supposed_result = add(mul(in.a, a), mul(in.b, b))
  case compare(supposed_result, in.prize) {
    #(Eq, Eq) -> Ok(#(a, b))
    _ -> Error(Nil)
  }
}

fn apply(point point: Point, fun op: fn(Int) -> Int) -> Point {
  Point(op(point.x), op(point.y))
}

fn score(ab: #(Int, Int)) -> Int {
  ab.0 * 3 + ab.1
}

pub fn pt_1(input: List(Input)) {
  list.filter_map(input, solve)
  |> list.filter(fn(tuple) { tuple.0 <= 100 && tuple.1 <= 100 })
  |> list.map(score)
  |> list.fold(0, int.add)
}

pub fn pt_2(input: List(Input)) {
  list.map(input, fn(input) {
    Input(input.a, input.b, apply(input.prize, int.add(10_000_000_000_000, _)))
  })
  |> list.filter_map(solve)
  |> list.map(score)
  |> list.fold(0, int.add)
}

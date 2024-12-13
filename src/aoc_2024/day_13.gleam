import gleam/bool
import gleam/int
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/order.{Eq, Gt, Lt}
import gleam/regexp
import gleam/result
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
    regexp.scan(re, input) |> list.map(to_point)
  Input(buttona, buttonb, prize)
}

fn to_point(match: regexp.Match) -> Point {
  let parse = fn(in) { unwrap(int.parse(in)) }
  let assert [x, y] =
    match.submatches
    |> list.map(fn(option) {
      let assert Some(content) = option
      parse(content)
    })
  Point(x, y)
}

fn unwrap(res: Result(a, _)) -> a {
  result.lazy_unwrap(res, fn() { panic as "unwrap" })
}

fn find_max_b(input: Input, b: Int, max: Int) -> Int {
  use <- bool.guard(b > max, max)
  case compare(mul(input.b, b), input.prize) {
    #(Gt, _) | #(_, Gt) -> b - 1
    _ -> find_max_b(input, b + 1, max)
  }
}

fn match_a(input: Input, a: Int, b: Int, max: Int) -> Option(#(Int, Int)) {
  use <- bool.guard(a > max, None)
  use <- bool.guard(b < 0, None)
  let pa = mul(input.a, a)
  let pb = mul(input.b, b)
  let reaches = Point(pa.x + pb.x, pa.y + pb.y)
  case compare(reaches, input.prize) {
    #(Gt, _) | #(_, Gt) -> match_a(input, a, b - 1, max)
    #(Lt, _) | #(_, Lt) -> match_a(input, a + 1, b, max)
    #(Eq, Eq) -> Some(#(a, b))
  }
}

fn compare(a: Point, b: Point) {
  #(int.compare(a.x, b.x), int.compare(a.y, b.y))
}

fn solve(input: Input, max: Int) -> Int {
  find_max_b(input, 1_000_000_000_000, max)
  |> match_a(input, 0, _, max)
  |> option.map(fn(ab) { ab.0 * 3 + ab.1 })
  |> option.unwrap(0)
}

fn apply(point point: Point, fun op: fn(Int) -> Int) -> Point {
  Point(op(point.x), op(point.y))
}

fn mul(point point: Point, by by: Int) -> Point {
  apply(point, int.multiply(by, _))
}

pub fn pt_1(input: List(Input)) {
  todo
  // list.fold(input, 0, fn(acc, input) { acc + solve(input, 100) })
}

pub fn pt_2(input: List(Input)) {
  list.map(input, fn(input) {
    Input(input.a, input.b, apply(input.prize, int.add(10_000_000_000_000, _)))
  })
  |> list.fold(0, fn(acc, input) { acc + solve(input, 10_000_000_000_000_000) })
}

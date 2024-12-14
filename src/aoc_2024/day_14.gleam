import gleam/dict.{type Dict}
import gleam/int
import gleam/io
import gleam/list
import gleam/option.{Some}
import gleam/order.{Eq, Gt, Lt}
import gleam/regexp
import gleam/result

pub type Point =
  #(Int, Int)

pub type Robot {
  Robot(pos: Point, vec: Point)
}

type Quadrent {
  TopLeft
  TopRight
  BottomLeft
  BottomRight
}

pub fn parse(input: String) -> List(Robot) {
  let parse = fn(option) {
    let assert Some(string) = option
    let assert Ok(out) = int.parse(string)
    out
  }
  let assert Ok(re) =
    regexp.compile(
      "^p=(\\d++),(\\d++)\\sv=(-?\\d++),(-?\\d++)$",
      regexp.Options(False, True),
    )
  use match <- list.map(regexp.scan(re, input))
  let assert [x, y, vx, vy] = list.map(match.submatches, parse)
  Robot(#(x, y), #(vx, vy))
}

pub fn step(robot: Robot, size: #(Int, Int)) -> Robot {
  let Robot(#(x, y), #(vx, vy)) = robot
  Robot(
    #({ x + vx + size.0 } % size.0, { y + vy + size.1 } % size.1),
    robot.vec,
  )
}

fn repeat(elem: a, fun: fn(a) -> a, n: Int) -> a {
  case n {
    0 -> elem
    _ -> fun(elem) |> repeat(fun, n - 1)
  }
}

fn score(
  dict: Dict(Quadrent, Int),
  robot: Robot,
  size: #(Int, Int),
) -> Dict(Quadrent, Int) {
  {
    use quadrent <- result.map(to_quadrent(robot.pos, size))
    use entry <- dict.upsert(dict, quadrent)
    option.unwrap(entry, 0) + 1
  }
  |> result.unwrap(dict)
}

fn to_quadrent(in: #(Int, Int), size: #(Int, Int)) -> Result(Quadrent, Nil) {
  case int.compare(in.0, size.0 / 2 + 1), int.compare(in.1, size.1 / 2 + 1) {
    Lt, Lt -> Ok(TopLeft)
    Gt, Lt -> Ok(TopRight)
    Lt, Gt -> Ok(BottomLeft)
    Gt, Gt -> Ok(BottomRight)
    Eq, _ | _, Eq -> Error(Nil)
  }
}

pub fn solve(input: List(Robot), step_n: Int, size: #(Int, Int)) -> Int {
  io.debug(list.length(input))
  list.map(input, repeat(_, step(_, size), step_n))
  |> list.fold(dict.new(), fn(acc, elem) { score(acc, elem, size) })
  |> dict.fold(1, fn(acc, _key, value) { acc * value })
}

pub fn pt_1(input: List(Robot)) {
  solve(input, 100, #(101, 103))
}

pub fn pt_2(input: List(Robot)) {
  todo as "part 2 not implemented"
}

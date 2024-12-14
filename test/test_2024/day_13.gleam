import aoc_2024/day_13
import gleeunit/should

const input = "Button A: X+94, Y+34
Button B: X+22, Y+67
Prize: X=8400, Y=5400"

pub fn silver_2024_13_test() {
  input |> day_13.parse |> day_13.pt_1 |> should.equal(280)
}

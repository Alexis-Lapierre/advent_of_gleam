import aoc_2024/day_21
import gleeunit/should

const example_input = "029A
980A
179A
456A
379A"

pub fn robot_type_test() {
  let assert [input, ..] = example_input |> day_21.parse
  day_21.robot_type(input.1)
  |> should.equal([
    #(1, -2),
    #(0, 0),
    #(0, -1),
    #(0, 0),
    #(1, 0),
    #(0, -1),
    #(0, -1),
    #(0, 0),
    #(1, -1),
    #(1, -1),
    #(1, -1),
    #(0, 0),
  ])
}

pub fn silver_2024_21_test() {
  day_21.parse(example_input) |> day_21.pt_1 |> should.equal(126_384)
}

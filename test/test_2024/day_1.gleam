import aoc_2024/day_1
import gleeunit/should

const test_input = "3   4
4   3
2   5
1   3
3   9
3   3"

pub fn silver_2024_01_test() {
  day_1.parse(test_input) |> day_1.pt_1 |> should.equal(11)
}

pub fn gold_2024_01_test() {
  day_1.parse(test_input) |> day_1.pt_2 |> should.equal(31)
}

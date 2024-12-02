import aoc_2024/day_2
import gleeunit/should

const test_input = "7 6 4 2 1
1 2 7 8 9
9 7 6 2 1
1 3 2 4 5
8 6 4 4 1
1 3 6 7 9"

pub fn silver_2024_02_test() {
  day_2.parse(test_input) |> day_2.pt_1 |> should.equal(2)
}

pub fn gold_2024_02_test() {
  day_2.parse(test_input) |> day_2.pt_2 |> should.equal(4)
}

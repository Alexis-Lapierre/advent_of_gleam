import aoc_2024/day_11
import gleeunit/should

const input = "125 17"

pub fn silver_2024_11_test() {
  input |> day_11.parse |> day_11.pt_1 |> should.equal(55_312)
}

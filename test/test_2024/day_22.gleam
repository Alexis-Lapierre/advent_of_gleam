import aoc_2024/day_22
import gleeunit/should

const silver_input = "1
10
100
2024"

const gold_input = "1
2
3
2024"

pub fn silver_day_22_test() {
  day_22.parse(silver_input) |> day_22.pt_1 |> should.equal(37_327_623)
}

pub fn gold_day_22_test() {
  day_22.parse(gold_input) |> day_22.pt_2 |> should.equal(23)
}

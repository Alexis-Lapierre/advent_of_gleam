import aoc_2024/day_3
import gleeunit/should

const silver = "xmul(2,4)%&mul[3,7]!@^do_not_mul(5,5)+mul(32,64]then(mul(11,8)mul(8,5))"

const gold = "xmul(2,4)&mul[3,7]!^don't()_mul(5,5)+mul(32,64](mul(11,8)undo()?mul(8,5))"

pub fn silver_2024_03_test() {
  day_3.parse(silver) |> day_3.pt_1 |> should.equal(161)
}

pub fn gold_2024_03_test() {
  day_3.parse(gold) |> day_3.pt_2 |> should.equal(48)
}

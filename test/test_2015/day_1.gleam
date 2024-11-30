import aoc_2015/day_1
import gleeunit/should

pub fn gold_2015_01_test() {
  day_1.pt_2(")") |> should.equal(1)
  day_1.pt_2("()())") |> should.equal(5)
}

import aoc_2024/day_9
import gleeunit/should

const input = "2333133121414131402"

pub fn silver_2024_09_test() {
  input |> day_9.parse |> day_9.pt_1 |> should.equal(1928)
}

pub fn gold_2024_09_test() {
  input |> day_9.parse |> day_9.pt_2 |> should.equal(2858)
}

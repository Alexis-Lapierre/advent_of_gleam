import aoc_2024/day_10
import gleeunit/should

const input = "89010123
78121874
87430965
96549874
45678903
32019012
01329801
10456732"

pub fn silver_2024_10_test() {
  input |> day_10.parse |> day_10.pt_1 |> should.equal(36)
}

pub fn gold_2024_10_test() {
  input |> day_10.parse |> day_10.pt_2 |> should.equal(81)
}

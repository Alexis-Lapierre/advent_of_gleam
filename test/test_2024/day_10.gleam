import aoc_2024/day_10.{Point}
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

pub fn suround() {
  input
  |> day_10.parse
  |> day_10.suround(Point(6, 0))
  |> should.equal([#(Point(5, 0), 3), #(Point(7, 0), 1), #(Point(6, 1), 1)])
}

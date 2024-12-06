import aoc_2024/day_6
import gleeunit/should

const input = "....#.....
.........#
..........
..#.......
.......#..
..........
.#..^.....
........#.
#.........
......#..."

pub fn silver_2024_06_test() {
  input |> day_6.parse |> day_6.pt_1 |> should.equal(41)
}

pub fn gold_2024_06_test() {
  input |> day_6.parse |> day_6.pt_2 |> should.equal(6)
}

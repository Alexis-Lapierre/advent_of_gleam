import aoc_2024/day_12
import gleeunit/should

const silver_input = "RRRRIICCFF
RRRRIICCCF
VVRRRCCFFF
VVRCCCJFFF
VVVVCJJCFE
VVIVCCJJEE
VVIIICJJEE
MIIIIIJJEE
MIIISIJEEE
MMMISSJEEE"

pub fn silver_2024_12_test() {
  silver_input |> day_12.parse |> day_12.pt_1 |> should.equal(1930)
}

pub fn gold_2024_12_test() {
  let gold_input =
    "EEEEE
EXXXX
EEEEE
EXXXX
EEEEE"

  gold_input |> day_12.parse |> day_12.pt_2 |> should.equal(236)
}

pub fn second_gold_2024_12_test() {
  let gold_input =
    "AAAAAA
AAABBA
AAABBA
ABBAAA
ABBAAA
AAAAAA"

  gold_input |> day_12.parse |> day_12.pt_2 |> should.equal(368)
}

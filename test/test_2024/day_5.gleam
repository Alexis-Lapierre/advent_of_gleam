import aoc_2024/day_5
import gleeunit/should

pub fn silver_2024_05_test() {
  input |> day_5.parse |> day_5.pt_1 |> should.equal(143)
}

pub fn gold_2024_05_test() {
  input |> day_5.parse |> day_5.pt_2 |> should.equal(123)
}

const input = "47|53
97|13
97|61
97|47
75|29
61|13
75|53
29|13
97|29
53|29
61|53
97|53
61|29
47|13
75|47
97|75
47|61
75|61
47|29
75|13
53|13

75,47,61,53,29
97,61,53,29,13
75,29,13
75,97,47,61,53
61,13,29
97,13,75,29,47"

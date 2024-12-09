import aoc_2024/day_9
import gleeunit/should

const input = "2333133121414131402"

pub fn silver_2024_09_test() {
  input |> day_9.parse |> day_9.pt_1 |> should.equal(1928)
}

pub fn gold_2024_09_test() {
  input |> day_9.parse |> day_9.pt_2 |> should.equal(2858)

  "23331331214141314022113" |> day_9.parse |> day_9.pt_2 |> should.equal(3317)
}

pub fn replace_test() {
  day_9.replace([1, 2, 3, 4, 5], fn(elem) {
    case elem {
      4 -> Ok(9)
      _ -> Error(Nil)
    }
  })
  |> should.equal(#(4, [1, 2, 3, 9, 5]))
}

import aoc_2024/day_14
import gleeunit/should

const input = "p=0,4 v=3,-3
p=6,3 v=-1,-3
p=10,3 v=-1,2
p=2,0 v=2,-1
p=0,0 v=1,3
p=3,0 v=-2,-2
p=7,6 v=-1,-3
p=3,0 v=-1,-2
p=9,3 v=2,3
p=7,3 v=-1,2
p=2,4 v=2,-3
p=9,5 v=-3,-3"

pub fn silver_2024_14_test() {
  input |> day_14.parse |> day_14.solve(100, #(11, 7)) |> should.equal(12)
}

pub fn fuck_test() {
  day_14.Robot(#(2, 4), #(2, -3))
  |> day_14.step(#(11, 7))
  |> day_14.step(#(11, 7))
  |> day_14.step(#(11, 7))
  |> day_14.step(#(11, 7))
  |> day_14.step(#(11, 7))
  |> should.equal(day_14.Robot(#(1, 3), #(2, -3)))
}

import aoc_2024/day_4
import gleeunit/should

const silver_input = "....XXMAS.
.SAMXMS...
...S..A...
..A.A.MS.X
XMASAMX.MM
X.....XA.A
S.S.S.S.SS
.A.A.A.A.A
..M.M.M.MM
.X.X.XMASX"

const gold_input = ".M.S......
..A..MSMS.
.M.S.MAA..
..A.ASMSM.
.M.S.M....
..........
S.S.S.S.S.
.A.A.A.A..
M.M.M.M.M.
.........."

pub fn silver_2024_04_test() {
  silver_input |> day_4.pt_1 |> should.equal(18)
}

pub fn gold_2024_04_test() {
  gold_input |> day_4.pt_2 |> should.equal(9)
}

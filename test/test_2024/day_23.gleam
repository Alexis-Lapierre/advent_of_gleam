import aoc_2024/day_23
import gleeunit/should

pub fn silver_day_23_test() {
  day_23.parse(input) |> day_23.pt_1 |> should.equal(7)
}

pub fn gold_day_23_test() {
  day_23.parse(input) |> day_23.pt_2 |> should.equal(["co", "de", "ka", "ta"])
}

const input = "kh-tc
qp-kh
de-cg
ka-co
yn-aq
qp-ub
cg-tb
vc-aq
tb-ka
wh-tc
yn-cg
kh-ub
ta-co
de-co
tc-td
tb-wq
wh-td
ta-ka
td-qp
aq-cg
wq-ub
ub-vc
de-ta
wq-aq
wq-vc
wh-yn
ka-de
kh-ta
co-tc
wh-qp
tb-vc
td-yn"

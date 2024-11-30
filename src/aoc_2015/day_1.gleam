import gleam/string

pub fn pt_1(input: String) -> Int {
  case input {
    "(" <> xs -> 1 + pt_1(xs)
    ")" <> xs -> -1 + pt_1(xs)
    "" -> 0
    _ -> panic as "Unexpected input character"
  }
}

pub fn pt_2(input: String) {
  do_gold(input, 0, 0)
}

fn do_gold(input: String, level: Int, position: Int) -> Int {
  case level {
    -1 -> position
    _ -> {
      let new_position = position + 1

      let assert Ok(#(head, tail)) = string.pop_grapheme(input)

      let new_level =
        level
        + case head {
          "(" -> 1
          ")" -> -1
          _ -> panic as "Unexpected input!"
        }

      do_gold(tail, new_level, new_position)
    }
  }
}

import gleam/int
import gleam/list
import gleam/result
import gleam/string
import gleam/yielder

pub type Input =
  List(Alloc)

pub opaque type Alloc {
  Alloc(id: Int, start: Int, length: Int)
}

pub fn parse(input: String) -> Input {
  {
    string.to_graphemes(input)
    |> list.index_map(fn(grapheme, index) {
      let assert Ok(grapheme) = int.parse(grapheme)
      #(int.is_even(index), grapheme)
    })
    |> list.fold(#(0, 0, []), fn(acc, tuple) {
      let #(id, start, acc) = acc
      let #(is_allocation, length) = tuple

      case is_allocation {
        True -> #(id + 1, start + length, [Alloc(id, start, length), ..acc])
        False -> #(id, start + length, acc)
      }
    })
  }.2
}

pub fn pt_1(input: Input) {
  let assert [last, ..xs] = input
  let xs = list.reverse(xs)
  silver(0, xs, last)
}

fn silver(last_writen_pos: Int, input: List(Alloc), last: Alloc) -> Int {
  case input {
    [] -> score(Alloc(last.id, last_writen_pos, last.length))
    [x, ..xs] -> {
      case x.start > last_writen_pos {
        False -> score(x) + silver(last_writen_pos + x.length, xs, last)
        True -> {
          let gap_size = x.start - last_writen_pos
          case gap_size < last.length {
            True ->
              score(Alloc(last.id, last_writen_pos, gap_size))
              + score(x)
              + silver(
                x.start + x.length,
                xs,
                Alloc(last.id, last.start, last.length - gap_size),
              )
            False -> {
              let #(new_last, xs) = pop_last(xs)
              score(Alloc(last.id, last_writen_pos, last.length))
              + silver(last_writen_pos + last.length, [x, ..xs], new_last)
            }
          }
        }
      }
    }
  }
}

fn gold(input: List(Alloc)) -> List(Alloc) {
  list.map(input, fn(alloc) { alloc.id })
  |> list.fold_right(input, do_gold_id)
}

fn do_gold_id(input: List(Alloc), id: Int) -> List(Alloc) {
  let #(last, xs) =
    replace(input, fn(elem) {
      case elem.id == id {
        True -> Ok(Alloc(-1, elem.start, 0))
        False -> Error(Nil)
      }
    })
  result.map(do_gold(0, last, xs), fn(input) {
    find_pop(input, fn(elem) { elem.id == -1 }).1
  })
  |> result.unwrap(input)
}

pub fn replace(input: List(a), cond: fn(a) -> Result(a, Nil)) -> #(a, List(a)) {
  case input {
    [] -> panic
    [x, ..xs] -> {
      case cond(x) {
        Ok(res) -> #(x, [res, ..xs])
        Error(Nil) -> {
          let succ = replace(xs, cond)
          #(succ.0, [x, ..succ.1])
        }
      }
    }
  }
}

fn find_pop(input: List(a), cond: fn(a) -> Bool) -> #(a, List(a)) {
  case input {
    [] -> panic
    [x, ..xs] -> {
      case cond(x) {
        True -> #(x, xs)
        False -> {
          let succ = find_pop(xs, cond)
          #(succ.0, [x, ..succ.1])
        }
      }
    }
  }
}

fn do_gold(
  last_writen_pos: Int,
  last: Alloc,
  input: List(Alloc),
) -> Result(List(Alloc), Nil) {
  case input {
    [] -> Error(Nil)
    [x, ..xs] -> {
      let end = x.start + x.length
      case x.start == last_writen_pos {
        True -> {
          use res <- result.map(do_gold(end, last, xs))
          [x, ..res]
        }
        False -> {
          let gap_size = x.start - last_writen_pos
          case gap_size >= last.length {
            True -> Ok([Alloc(last.id, last_writen_pos, last.length), x, ..xs])
            False -> {
              use res <- result.map(do_gold(end, last, xs))
              [x, ..res]
            }
          }
        }
      }
    }
  }
}

fn score(alloc: Alloc) -> Int {
  yielder.range(from: alloc.start, to: alloc.start + alloc.length - 1)
  |> yielder.map(int.multiply(_, alloc.id))
  |> yielder.fold(0, int.add)
}

fn pop_last(input: List(a)) -> #(a, List(a)) {
  case input {
    [] -> panic
    [x] -> #(x, [])
    [x, ..xs] -> {
      let res = pop_last(xs)
      #(res.0, [x, ..res.1])
    }
  }
}

pub fn pt_2(input: Input) {
  list.reverse(input)
  |> gold
  |> list.fold(0, fn(acc, elem) { acc + score(elem) })
}

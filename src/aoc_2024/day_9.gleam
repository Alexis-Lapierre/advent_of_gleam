import gleam/int
import gleam/io
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/result
import gleam/string
import gleam/yielder

pub type Input =
  List(Option(Int))

pub fn parse(input: String) -> List(Option(Int)) {
  let to_int = fn(s) {
    int.parse(s) |> result.lazy_unwrap(fn() { panic as "unwrap" })
  }

  let graphemes = string.to_graphemes(input)
  {
    use acc, elem, index <- list.index_fold(graphemes, #([], 0))
    let #(acc, current_id) = acc
    let repeats = to_int(elem)
    case int.bitwise_and(index, 1) == 0 {
      True -> #(
        list.append(acc, list.repeat(Some(current_id), repeats)),
        current_id + 1,
      )
      False -> #(list.append(acc, list.repeat(None, repeats)), current_id)
    }
  }.0
}

pub fn pt_1(input: Input) {
  use acc, elem, index <- list.index_fold(silver(input), 0)
  acc + { index * elem }
}

fn silver(input: Input) -> List(Int) {
  case input {
    [] -> []
    [Some(x), ..xs] -> [x, ..silver(xs)]
    [None, ..xs] -> {
      {
        use #(xs, last) <- result.map(
          take_last_cond(xs, option.to_result(_, Nil)),
        )
        [last, ..silver(xs)]
      }
      |> result.unwrap([])
    }
  }
}

fn take_last_cond(
  in: List(a),
  fun: fn(a) -> Result(b, Nil),
) -> Result(#(List(a), b), Nil) {
  use res <- result.try(take_last(in) |> option.to_result(Nil))
  case fun(res.1) {
    Ok(b) -> Ok(#(res.0, b))
    Error(_) -> take_last_cond(res.0, fun)
  }
}

fn take_last(in: List(a)) -> Option(#(List(a), a)) {
  case in {
    [] -> None
    [x] -> Some(#([], x))
    [x, ..xs] -> {
      use res <- option.map(take_last(xs))
      #([x, ..res.0], res.1)
    }
  }
}

type GoldInput =
  List(#(Option(Int), Int))

fn to_gold(input: Input) -> GoldInput {
  let assert [head, ..tail] = input
  do_to_gold(tail, #(head, 1))
}

fn do_to_gold(input: Input, partial: #(Option(Int), Int)) -> GoldInput {
  case input {
    [] -> [partial]
    [x, ..xs] if x == partial.0 -> do_to_gold(xs, #(partial.0, partial.1 + 1))
    [x, ..xs] -> [partial, ..do_to_gold(xs, #(x, 1))]
  }
}

fn gold(input: GoldInput, find: Int) -> GoldInput {
  case find_and_remove_first_chunk(input, find) {
    Ok(res) -> {
      let #(new_list, elem) = res
      let assert #(Some(id), _) = elem
      case do_gold(new_list, elem) {
        Some(new_new_list) -> gold(new_new_list, id)
        None -> gold(input, id)
      }
    }
    Error(_) -> input
  }
}

fn do_gold(input: GoldInput, place: #(Option(Int), Int)) -> Option(GoldInput) {
  case input {
    [] -> None
    [#(None, length), ..xs] if length == place.1 -> Some([place, ..xs])
    [#(None, length), ..xs] if length > place.1 ->
      Some([place, #(None, length - place.1), ..xs])
    [x, ..xs] -> option.map(do_gold(xs, place), fn(xs) { [x, ..xs] })
  }
}

fn find_and_remove_first_chunk(
  reversed: GoldInput,
  id_under: Int,
) -> Result(#(GoldInput, #(Option(Int), Int)), Nil) {
  case reversed {
    [#(Some(id), length), ..xs] if id <= id_under -> {
      Ok(#([#(None, length), ..xs], #(Some(id), length)))
    }

    [x, ..xs] -> {
      use res <- result.map(find_and_remove_first_chunk(xs, id_under))
      #([x, ..res.0], res.1)
    }
    [] -> Error(Nil)
  }
}

pub fn pt_2(input: Input) {
  {
    to_gold(input)
    |> io.debug
    |> gold(9_999_999_999)
    |> io.debug
    |> list.fold(#(0, 0), fn(acc, elem) {
      let #(index, acc) = acc
      case elem {
        #(None, length) -> #(index + length, acc)
        #(Some(id), length) -> {
          let score =
            yielder.range(from: index, to: index + length)
            |> yielder.map(fn(index) { index * id })
            |> yielder.fold(0, int.add)

          #(index + length, acc + score)
        }
      }
    })
  }.1
}

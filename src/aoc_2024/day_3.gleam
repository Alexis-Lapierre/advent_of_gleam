import gleam/int
import gleam/list
import gleam/option.{Some}
import gleam/regexp
import gleam/result

pub type Instructions =
  List(Instruction)

pub type Instruction {
  Do
  Dont
  Multiply(Int, Int)
}

pub fn pt_1(input: Instructions) -> Int {
  input
  |> list.fold(from: 0, with: fn(acc, elem) {
    case elem {
      Multiply(left, right) -> acc + left * right
      _ -> acc
    }
  })
}

pub fn pt_2(input: Instructions) -> Int {
  list.fold(over: input, from: #(True, 0), with: gold_action).1
}

fn gold_action(acc: #(Bool, Int), input: Instruction) -> #(Bool, Int) {
  case input {
    Do -> #(True, acc.1)
    Dont -> #(False, acc.1)
    Multiply(left, right) -> {
      case acc.0 {
        True -> #(acc.0, acc.1 + left * right)
        False -> acc
      }
    }
  }
}

pub fn parse(input: String) -> Instructions {
  let assert Ok(re) =
    regexp.from_string("mul\\((\\d{1,3}),(\\d{1,3})\\)|do\\(\\)|don't\\(\\)")

  let unwrap = fn(result: Result(a, b)) -> a {
    result |> result.lazy_unwrap(fn() { panic as "unwrap" })
  }

  regexp.scan(re, input)
  |> list.map(fn(action) {
    case action.content {
      "do()" -> Do
      "don't()" -> Dont
      _ -> {
        let assert [Some(left), Some(right)] = action.submatches
        let parse = fn(in: String) { in |> int.parse |> unwrap }
        Multiply(left |> parse, right |> parse)
      }
    }
  })
}

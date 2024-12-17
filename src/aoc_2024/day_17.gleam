import gleam/bool
import gleam/dict.{type Dict}
import gleam/float
import gleam/int
import gleam/io
import gleam/list
import gleam/option.{Some}
import gleam/regexp
import gleam/result
import gleam/string

pub opaque type Input {
  Input(
    a: Int,
    b: Int,
    c: Int,
    instruction_ptr: Int,
    program: Dict(Int, Int),
    result: List(Int),
  )
}

pub fn parse(input: String) -> Input {
  let assert Ok(register) = regexp.from_string("Register [A-C]: (\\d++)")
  let assert Ok(prog) = regexp.from_string("Program: ([0-7,]++)")

  let assert Ok(#(top, bottom)) = string.split_once(input, "\n\n")

  let assert [a, b, c] =
    regexp.scan(register, top)
    |> list.map(fn(match) {
      let assert [Some(value)] = match.submatches
      let assert Ok(value) = int.parse(value)
      value
    })
  let assert [instructions] =
    regexp.scan(prog, bottom)
    |> list.map(fn(match) {
      let assert [Some(instructions)] = match.submatches
      string.split(instructions, ",")
      |> list.map(fn(num) {
        let assert Ok(value) = int.parse(num)
        value
      })
    })
  let instructions =
    list.index_fold(instructions, dict.new(), fn(acc, elem, index) {
      dict.insert(acc, index, elem)
    })
  Input(a, b, c, 0, instructions, [])
}

fn operand(state: Input, in: Int) -> Int {
  case in {
    0 | 1 | 2 | 3 -> in
    4 -> state.a
    5 -> state.b
    6 -> state.c
    _ -> panic as "invalid state"
  }
}

fn instruction(state: Input, in: Int) -> fn(Int) -> Input {
  let next = Input(..state, instruction_ptr: state.instruction_ptr + 2)
  let combo = operand(next, _)
  case in {
    0 -> fn(in) {
      let assert Ok(power) = int.power(2, int.to_float(combo(in)))
      let power = float.truncate(power)
      Input(..next, a: { state.a / power })
    }
    1 -> fn(in) { Input(..next, b: int.bitwise_exclusive_or(state.b, in)) }
    2 -> fn(in) { Input(..next, b: int.bitwise_and(combo(in), 0b111)) }
    3 -> fn(in) {
      use <- bool.guard(state.a == 0, next)
      Input(..state, instruction_ptr: in)
    }

    4 -> fn(_) { Input(..next, b: int.bitwise_exclusive_or(state.b, state.c)) }
    5 -> fn(in) {
      Input(
        ..next,
        result: list.append(next.result, [int.bitwise_and(combo(in), 0b111)]),
      )
    }
    6 -> fn(in) {
      let assert Ok(power) = int.power(2, int.to_float(combo(in)))
      let power = float.truncate(power)
      Input(..next, b: next.a / power)
    }
    7 -> fn(in) {
      let assert Ok(power) = int.power(2, int.to_float(combo(in)))
      let power = float.truncate(power)
      Input(..next, c: next.a / power)
    }
    _ -> panic as "Illegal instruction"
  }
}

fn read_ptr(input: Input) -> Result(#(Int, Int), Nil) {
  let instruction = dict.get(input.program, input.instruction_ptr)
  use instruction <- result.try(instruction)
  let op = dict.get(input.program, input.instruction_ptr + 1)
  use op <- result.map(op)
  #(instruction, op)
}

fn run(input: Input) {
  case read_ptr(input) {
    Ok(#(instruct, op)) -> {
      run(instruction(input, instruct)(op))
    }
    Error(_) -> {
      input
    }
  }
}

pub fn pt_1(input: Input) {
  run(input).result
}

fn gold(input: Input) {
  let result =
    run(input).result
    |> list.index_fold(dict.new(), fn(acc, elem, index) {
      dict.insert(acc, index, elem)
    })
  case result == input.program {
    True -> input.a
    False -> gold(Input(..input, a: input.a + 1))
  }
}

pub fn pt_2(input: Input) {
  gold(Input(..input, a: 0))
}

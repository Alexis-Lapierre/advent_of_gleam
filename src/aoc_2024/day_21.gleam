import gleam/bool
import gleam/int
import gleam/io
import gleam/list
import gleam/order.{Eq, Gt, Lt}
import gleam/result
import gleam/string

pub type Input =
  List(#(Int, List(#(Int, Int))))

pub fn parse(input: String) -> Input {
  use line <- list.map(string.split(input, "\n"))
  #(
    string.drop_end(line, 1) |> int.parse |> result.lazy_unwrap(fn() { panic }),
    {
      use grapheme <- list.map(string.to_graphemes(line))
      case grapheme {
        "A" -> #(0, 0)
        "0" -> #(0, -1)
        "3" -> #(-1, 0)
        "2" -> #(-1, -1)
        "1" -> #(-1, -2)
        "6" -> #(-2, 0)
        "5" -> #(-2, -1)
        "4" -> #(-2, -2)
        "9" -> #(-3, 0)
        "8" -> #(-3, -1)
        "7" -> #(-3, -2)
        _ -> panic as "unexpected input"
      }
    },
  )
}

pub fn robot_type(keys: List(#(Int, Int))) -> List(#(Int, Int)) {
  do_robot_type(keys, #(0, 0), []) |> list.reverse()
}

fn do_robot_type(
  in: List(#(Int, Int)),
  current: #(Int, Int),
  out: List(#(Int, Int)),
) -> List(#(Int, Int)) {
  use <- bool.lazy_guard(current == #(0, -2), fn() {
    panic as "Illegal position!"
  })
  case in {
    [] -> out
    [#(objx, objy) as objective, ..xs] -> {
      let updown = {
        let deltax = current.0 - objx
        case int.compare(deltax, 0) {
          Gt -> list.repeat(#(0, -1), deltax)
          Eq -> []
          Lt -> list.repeat(#(1, -1), -deltax)
        }
      }
      let rightleft = {
        let deltay = current.1 - objy
        case int.compare(deltay, 0) {
          Gt -> list.repeat(#(1, -2), deltay)
          Eq -> []
          Lt -> list.repeat(#(1, 0), -deltay)
        }
      }
      let #(left, right) = case current, objective {
        #(0, _), #(_, -2) | #(_, -2), #(0, _) -> {
          #(rightleft, updown)
        }
        _, _ -> {
          case rightleft, updown {
            [#(rx, ry), ..], [#(ux, uy), ..] ->
              case
                int.compare(
                  int.absolute_value(-current.0 + rx),
                  int.absolute_value(-current.0 + ux),
                )
              {
                Lt -> #(rightleft, updown)
                Eq ->
                  case
                    int.compare(
                      int.absolute_value(-current.1 + ry),
                      int.absolute_value(-current.1 + uy),
                    )
                  {
                    Lt | Eq -> #(rightleft, updown)
                    Gt -> #(updown, rightleft)
                  }
                Gt -> #(updown, rightleft)
              }
            _, _ -> #(updown, rightleft)
          }
        }
      }
      do_robot_type(
        xs,
        objective,
        list.flatten([[#(0, 0), ..left], right, out]),
      )
    }
  }
}

pub fn pt_1(input: Input) {
  use acc, code <- list.fold(input, 0)
  acc
  + code.0
  * {
    robot_type(code.1)
    |> robot_type
    |> robot_type
    |> io.debug
    |> list.length
    |> io.debug
  }
}

pub fn pt_2(_input: Input) {
  todo as "part 2 not implemented"
}

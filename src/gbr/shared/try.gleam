///
/// Gleam shared try like gleam/result with more charm.
///
import gleam/list
import gleam/result
import gleam/string

pub type Stack =
  List(String)

pub type Wrapper(error) =
  error

pub type Try(error) {
  Try(error: Wrapper(error), stack: Stack)
}

pub type From(t, error) =
  Result(t, error)

pub type In(t, error) =
  Result(t, Try(error))

pub fn new(from result: From(t, error)) -> In(t, error) {
  case result {
    Ok(t) -> Ok(t)
    Error(_) -> result.map_error(result, try_new)
  }
}

fn try_new(error) {
  Try(error:, stack: [])
}

pub fn unwrap(in try: In(t, error)) -> From(t, error) {
  case try {
    Ok(t) -> Ok(t)
    Error(_) -> result.map_error(try, try_unwrap)
  }
}

fn try_unwrap(try: Try(error)) {
  try.error
}

pub fn map_error(
  in try: In(t, error),
  map mapper: fn(error) -> error_map,
) -> In(t, error_map) {
  result.map_error(try, try_map_error(_, mapper))
}

fn try_map_error(try, mapper) {
  Try(..try, error: mapper(try.error))
}

pub fn map(in try: In(t, error), map parser: fn(t) -> c) -> In(c, error) {
  result.map(try, parser)
}

pub fn wrap(
  in try: In(t, error),
  map parser: fn(From(t, error)) -> From(a, b),
  like describe: fn(Try(error)) -> String,
) -> In(a, b) {
  let stack = case try {
    Ok(_) -> []
    Error(e) -> [describe(e), ..e.stack]
  }

  try
  |> unwrap()
  |> parser()
  |> new()
  |> result.map_error(fn(t) { Try(error: t.error, stack: stack) })
}

pub fn with_context(error_context: String, next) {
  next()
  |> context(error_context)
}

pub fn context(in try: In(t, error), with context: String) {
  let add = fn(error) { stack_add(error, context) }
  result.map_error(try, add)
}

fn stack_add(error, context) {
  Try(..error, stack: [context, ..error.stack])
}

pub fn print_line(try: Try(error), like describe: fn(error) -> String) -> String {
  pretty_print_with_joins(try, " < ", " < ", describe)
}

pub fn print(in try: Try(error), like describe: fn(error) -> String) -> String {
  pretty_print_with_joins(try, "\n\nstack:\n  ", "\n  ", describe)
}

fn pretty_print_with_joins(
  try,
  join_current: String,
  join_stack: String,
  to_s: fn(err) -> String,
) -> String {
  let current = to_s(try_unwrap(try))

  let stack =
    join_current
    <> try.stack
    |> stack_to_lines
    |> string.join(join_stack)

  let stack = case try.stack {
    [] -> ""
    _ -> stack
  }

  current <> stack
}

fn stack_to_lines(stack: Stack) -> List(String) {
  stack
  |> list.reverse
}

import gleam/bool
import gleam/float
import gleam/function
import gleam/int
import gleam/result
import gleam/string
import gleeunit/should

import gbr/shared/try

pub type ModelErrorNested {
  ModelErrorNested(msg: String)
}

pub type ModelError {
  ModelError(desc: String, count: Int, mean: Float, nested: ModelErrorNested)
}

pub type CustomError {
  ErrorString(msg: String)
  ErrorStringList(msg: List(String))
  ErrorInt(msg: Int)
  ErrorFloat(msg: Float)
  ErrorBool(msg: Bool)
  ErrorModel(model: ModelError)
}

pub fn try_new_test() {
  let one = Ok("Ok msg")
  let two = error_str() |> Error()
  let tree = error_str_list() |> Error()
  let four = error_int() |> Error()
  let five = error_float() |> Error()
  let six = error_bool() |> Error()
  let seven = error_model() |> Error()

  one
  |> try.new()
  |> should.be_ok()
  |> should.equal("Ok msg")

  two
  |> try.new()
  |> should.be_error()
  |> should.equal(try.Try(error_str(), []))

  tree
  |> try.new()
  |> should.be_error()
  |> should.equal(try.Try(error_str_list(), []))

  four
  |> try.new()
  |> should.be_error()
  |> should.equal(try.Try(error_int(), []))

  five
  |> try.new()
  |> should.be_error()
  |> should.equal(try.Try(error_float(), []))

  six
  |> try.new()
  |> should.be_error()
  |> should.equal(try.Try(error_bool(), []))

  seven
  |> try.new()
  |> should.be_error()
  |> should.equal(try.Try(error_model(), []))

  let seven =
    seven
    |> try.new()
    |> result.map_error(fn(e) { e.error })
    |> should.be_error()

  assert error_model() == seven
}

pub fn try_unwrap_test() {
  let one = Ok("Ok msg")
  let two = error_str() |> Error()
  let tree = error_str_list() |> Error()

  one
  |> try.new()
  |> try.unwrap()
  |> should.equal(Ok("Ok msg"))

  two
  |> try.new()
  |> try.unwrap()
  |> should.equal(Error(error_str()))

  tree
  |> try.new()
  |> try.unwrap()
  |> should.equal(Error(error_str_list()))
}

pub fn try_map_test() {
  let one = Ok("Ok msg")
  let two = fn(_) { error_str() |> Error() }
  let tree = fn(_) { error_str_list() |> Error() }

  one
  |> try.new()
  |> try.wrap(two, desc)
  |> try.wrap(tree, desc)
  |> should.be_error()
  |> should.equal(try.Try(error_str_list(), ["Msg error"]))
}

pub fn try_map_multi_test() {
  let one = Ok("Ok msg")
  let two = fn(_) { error_str() |> Error() }
  let tree = fn(_) { error_str_list() |> Error() }
  let four = fn(_) { Ok("Ok four") }
  let five = fn(_) { error_model() |> Error() }

  error_str_list()
  |> Error()
  |> try.new()
  |> try.context("Context 01")
  |> try.map_error(fn(_) { error_str() })
  |> try.map_error(fn(_) { error_model() })
  |> try.context("Context 02")
  |> should.be_error()
  |> should.equal(try.Try(error_model(), ["Context 02", "Context 01"]))

  one
  |> try.new()
  |> try.wrap(two, desc)
  |> try.wrap(tree, desc)
  |> try.wrap(five, desc)
  |> should.be_error()
  |> should.equal(
    try.Try(error_model(), ["Msg error 1 Msg error 2", "Msg error"]),
  )

  one
  |> try.new()
  |> try.wrap(two, desc)
  |> try.wrap(tree, desc)
  |> try.wrap(four, desc)
  |> try.wrap(five, desc)
  |> try.wrap(two, desc)
  |> try.wrap(tree, desc)
  |> should.be_error()
  |> should.equal(
    try.Try(error_str_list(), ["Msg error", "Msg error model Nested msg"]),
  )
}

pub fn with_context_test() {
  let process = fn(user_id: String) {
    use <- try.with_context("in " <> user_id)

    Error("failure")
    |> try.new
    |> try.context("failed")
  }

  let actual = process("123")
  let expected = try.Try(error: "failure", stack: ["in 123", "failed"])

  assert actual == Error(expected)
}

pub fn unwrap_test() {
  let actual =
    Error("error")
    |> try.new
    |> try.unwrap

  assert actual == Error("error")
}

fn pretty_print_outcome(outcome: Result(t, try.Try(String))) -> String {
  case outcome {
    Ok(_) -> "Ok"
    Error(problem) -> try.print(problem, function.identity)
  }
}

fn print_line_outcome(outcome: Result(t, try.Try(String))) -> String {
  case outcome {
    Ok(_) -> "Ok"
    Error(problem) -> try.print_line(problem, function.identity)
  }
}

pub fn pretty_print_test() {
  let error =
    Error("defect")
    |> try.new
    |> try.context("context inner")
    |> try.context("context outer")

  let actual = pretty_print_outcome(error)

  let expected =
    "defect

stack:
  context inner
  context outer"

  assert actual == expected
}

pub fn pretty_print_without_context_test() {
  let error =
    Error("defect")
    |> try.new

  let actual = pretty_print_outcome(error)

  assert actual == "defect"
}

pub fn print_line_test() {
  let error =
    Error("defect")
    |> try.new
    |> try.context("context inner")
    |> try.context("context outer")

  let actual = print_line_outcome(error)

  assert actual == "defect < context inner < context outer"
}

pub fn print_line_without_context_test() {
  let error = Error("defect") |> try.new

  let actual = print_line_outcome(error)

  assert actual == "defect"
}

fn desc(t: try.Try(CustomError)) {
  case t.error {
    ErrorString(msg) -> msg
    ErrorStringList(list) -> string.join(list, " ") |> string.trim()
    ErrorInt(number) -> int.to_string(number)
    ErrorFloat(number) -> float.to_string(number)
    ErrorBool(logic) -> bool.to_string(logic)
    ErrorModel(model) -> model.desc <> " " <> model.nested.msg
  }
}

fn error_str() {
  ErrorString("Msg error")
}

fn error_str_list() {
  ErrorStringList(["Msg error 1", "Msg error 2"])
}

fn error_int() {
  ErrorInt(1)
}

fn error_float() {
  ErrorFloat(1.5)
}

fn error_bool() {
  ErrorBool(True)
}

fn error_model() {
  ErrorModel(ModelError(
    desc: "Msg error model",
    count: 5,
    mean: 1.5,
    nested: ModelErrorNested(msg: "Nested msg"),
  ))
}

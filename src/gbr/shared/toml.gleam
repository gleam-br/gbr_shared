////
//// Gleam shared file toml parser.
////

import gleam/dict
import gleam/result
import gleam/string

import tom

pub type Toml =
  dict.Dict(String, tom.Toml)

/// Parse toml file.
///
/// - `file` The string/path location of toml file.
///
pub fn parse(file: String) -> Result(Toml, String) {
  use parsed <- result.map(
    tom.parse(file)
    |> result.map_error(tom_error_parse),
  )

  parsed
}

/// Get name from toml file.
///
/// - `file` The string/path location of toml file.
///
pub fn get_string(toml: Toml, key: List(String)) -> Result(String, String) {
  use name <- result.map(
    tom.get_string(toml, key)
    |> result.map_error(tom_error_get),
  )

  name
}

// PRIVATE
//

fn tom_error_get(err: tom.GetError) {
  case err {
    tom.NotFound(key) -> "Error not found key '" <> join_key(key) <> "'"
    tom.WrongType(key:, expected:, got:) ->
      "Error wrong type key '"
      <> join_key(key)
      <> "' type="
      <> expected
      <> " got="
      <> got
  }
}

fn tom_error_parse(err: tom.ParseError) {
  case err {
    tom.KeyAlreadyInUse(key:) ->
      "Error parser already in use key '" <> join_key(key) <> "'"
    tom.Unexpected(got:, expected:) ->
      "Error parser unexpected char=" <> got <> " expected=" <> expected
  }
}

fn join_key(key) {
  string.join(key, ".")
}

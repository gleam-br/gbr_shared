////
//// Error translate
////

import gleam/dynamic/decode
import gleam/string

pub fn decode_to_string(err: decode.DecodeError) -> String {
  let decode.DecodeError(expected:, found:, path:) = err

  "Error decode expected: "
  <> expected
  <> "; found="
  <> found
  <> "; path="
  <> string.join(path, "/")
}

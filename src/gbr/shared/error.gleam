////
//// 🚨 Error generic type translate to string
////

import gleam/dynamic/decode
import gleam/json
import gleam/list
import gleam/string

/// decode.DecodeError type to string
///
pub fn decode_to_string(err: decode.DecodeError) -> String {
  let decode.DecodeError(expected:, found:, path:) = err

  "Error decode expected: "
  <> expected
  <> "; found="
  <> found
  <> "; path="
  <> string.join(path, "/")
}

/// json.DecodeError type to string
///
pub fn json_to_string(err: json.DecodeError) -> String {
  case err {
    json.UnexpectedEndOfInput -> "Json unexpected end of input"
    json.UnexpectedByte(byte) -> "Json unexpected byte " <> byte
    json.UnexpectedSequence(seq) -> "Json unexpected sequence " <> seq
    json.UnableToDecode(dec_errors) ->
      "Json error unable to decode:\n"
      <> {
        use er <- list.map(dec_errors)
        "Expected: "
        <> er.expected
        <> " Found: "
        <> er.found
        <> ": "
        <> string.join(er.path, ",")
      }
      |> string.join("\n")
  }
}

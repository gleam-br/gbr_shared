////
//// Utilities functions
////

import gleam/bit_array
import gleam/dict.{type Dict}
import gleam/dynamic
import gleam/dynamic/decode
import gleam/json
import gleam/list
import gleam/option.{None, Some}

/// Uses in definitions
///
pub type Never {
  Never(Never)
}

/// Generic any wrapper to native type
///
pub type Any {
  Object(Fields)
  Array(List(Any))
  Boolean(Bool)
  Integer(Int)
  Number(Float)
  String(String)
  Null
}

/// Represent fields of any types
///
pub type Fields =
  Dict(String, Any)

/// Decoder any value
///
pub fn any_decoder() {
  use <- decode.recursive
  decode.one_of(decode.map(fields_decoder(), Object), [
    decode.list(any_decoder()) |> decode.map(Array),
    decode.bool |> decode.map(Boolean),
    decode.int |> decode.map(Integer),
    decode.float |> decode.map(Number),
    decode.map(decode.optional(decode.string), fn(decoded) {
      case decoded {
        Some(str) -> String(str)
        None -> Null
      }
    }),
  ])
}

/// Any value to json
///
/// - any: Any type value
///
pub fn any_to_json(any) {
  case any {
    Object(fields) -> fields_to_json(fields)
    Array(list) -> json.array(list, any_to_json)
    Boolean(bool) -> json.bool(bool)
    Integer(int) -> json.int(int)
    Number(float) -> json.float(float)
    String(string) -> json.string(string)
    Null -> json.null()
  }
}

/// Decoder fields of any values
///
pub fn fields_decoder() {
  decode.dict(decode.string, any_decoder())
}

/// Json to array bits
///
/// - json: String json representation
///
pub fn json_to_bits(json) {
  json
  |> json.to_string
  |> bit_array.from_string
}

/// Fields of any values to json
///
/// - fields: Fields of any type values
///
pub fn fields_to_json(fields) {
  json.dict(fields, fn(x) { x }, any_to_json)
}

/// Any value to dynamic
///
/// - any: Any type value
///
pub fn any_to_dynamic(any) {
  case any {
    Object(fields) -> fields_to_dynamic(fields)
    Array(items) -> dynamic.list(list.map(items, any_to_dynamic))
    Boolean(bool) -> dynamic.bool(bool)
    Integer(int) -> dynamic.int(int)
    Number(float) -> dynamic.float(float)
    String(string) -> dynamic.string(string)
    Null -> dynamic.nil()
  }
}

/// Fields of any type values to dynamic
///
/// - fields: Fields of any type values
///
pub fn fields_to_dynamic(fields) {
  dynamic.properties(
    fields
    |> dict.to_list
    |> list.map(fn(entry) {
      let #(key, value) = entry
      #(dynamic.string(key), any_to_dynamic(value))
    }),
  )
}

/// Json dictionary
///
/// - dict: Dict type
/// - values: Function convert key to value json
///
pub fn dict(dict, values) {
  json.dict(dict, fn(x) { x }, values)
}

/// Convert list of tuple key and value json to object of any.
///
/// - entries: list of tuple #(String, json.Json)
///
pub fn object(entries: List(#(String, json.Json))) {
  list.filter(entries, fn(entry) {
    let #(_, v) = entry
    v != json.null()
  })
  |> json.object
}

// Experimental
//
// - [ ] How send and catch event via effect pattern
// - [ ] How decode additional with except

/// Decoder additional
///
/// TODO
///
pub fn decode_additional(_except, _decoder, next) {
  // use r <- decode.then(decode.dict(decode.string, decoder))
  // let additional = dict.drop(r, except)
  // TODO
  use additional <- decode.then(decode.success(dict.new()))
  next(additional)
}

pub fn header_code_generated(timestamp, contents) {
  "// Licensed under the Lucid License (Individual Sovereignty & Non-Aggression)
// See LICENSE file in the root of the repository.
//......................=#%%*:...............................
//....................:#@%##@@+..............................
//....................=@%****%@#.............................
//...................:@@#+=+**#@@=...........................
//...................*@#*===+***@@#..........................
//..................-@@*=====+***%@%-........................
//..................@@*=---==++***#@@*:......................
//.................*@#=-::--==+++***#@@@@@@@@@@@@@@@%+:......
//................+@@-:.:::--=++++************######%@%:.....
//.............+#@@%-:...:::--=++++++************###%@@-.....
//........:*%@@@%+-:......::--==+++++++++++++++*###%@@*......
//....-#@@@@%*+=:.........:::--=+++++++++++++======@@*.......
//..+@@@#*++=::::::......::::::.:::::::::::::-===+@@+........
//.:@@#**+=====--::::..........:::::-++=-:::-===+@@=.........
//.:%@%%##**+++=-:...........::::::*%*+#%=:-===*@@-..........
//..:*@@@%##*+-:::::-#%%#=::::::::=%+:::++-===*@%-...........
//.....+@@@#==--:::-@*::+@=::-::++::::::::-===@%-............
//.......-%@@*====--%-:::-::=#++#%:::::::-===+@#:............
//.........:#@@#==-::::::::::-**=-=+++++++####@@=............
//............#@@*=-:::::::::-=+++++++++++*###%@#:...........
//.............-@%+=-::::::-+++++++++++++++*##%@@-...........
//.............:%@+=-::::-++++++++++++++++++###%@#...........
//.............:#@+=-::-=++++**########***++*##%@@=..........
//..............#@*==:-+++*#####################%@@..........
//..............*@*==-++*#####%%@@@@@@%%#########@@=.........
//..............+@*==+######%@@@#-:-*%@@@@@@%%##%@@-.........
//..............=@#=+#####%@@%=..........:=#@@@@@@-..........
//..............=@#=*##%@@@#:................................
//..............:%@*%%@@%=...................................
//...............:*%%%*:.....................................
//
//
//###########################################################
//# Code auto generate with love by Gleam BR in:
//# " <> timestamp <> "
//###########################################################
//
" <> contents
}

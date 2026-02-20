////
//// Jwt read only functions.
////

import gleam/bit_array
import gleam/bool
import gleam/dict.{type Dict}
import gleam/dynamic/decode.{type DecodeError, type Decoder, type Dynamic}
import gleam/json
import gleam/list
import gleam/option.{type Option}
import gleam/result
import gleam/string

/// A decoded JWT that can be read.
///
pub opaque type Jwt {
  Jwt(
    raw: String,
    header: Dict(String, Dynamic),
    payload: Dict(String, Dynamic),
  )
}

/// Errors that can occur when attempting to decode a JWT from a String or read from a successfully decoded JWT string.
///
pub type JwtDecodeError {
  TokenEmpty
  HeaderEmpty
  HeaderInvalid
  PayloadEmpty
  PayloadInvalid
  ClaimEmpty
  ClaimInvalid(List(DecodeError))
}

/// From string encoded jwt
///
pub fn from_string(raw: String) -> Result(Jwt, JwtDecodeError) {
  use <- bool.guard(string.is_empty(raw), Error(TokenEmpty))

  use #(header, payload, _) <- result.map(parts(raw))

  Jwt(raw:, header:, payload:)
}

/// To string encoded jwt
///
pub fn to_string(in: Jwt) -> String {
  in.raw
}

/// Retrieve the iss from the JWT's payload.
///
pub fn get_issuer(from jwt: Jwt) -> Result(String, JwtDecodeError) {
  get_payload_claim(jwt, "iss", decode.string)
}

/// Retrieve the sub from the JWT's payload.
///
pub fn get_subject(from jwt: Jwt) -> Result(String, JwtDecodeError) {
  get_payload_claim(jwt, "sub", decode.string)
}

/// Retrieve the aud from the JWT's payload.
///
pub fn get_audience(from jwt: Jwt) -> Result(String, JwtDecodeError) {
  get_payload_claim(jwt, "aud", decode.string)
}

/// Retrieve the jti from the JWT's payload.
///
pub fn get_jwt_id(from jwt: Jwt) -> Result(String, JwtDecodeError) {
  get_payload_claim(jwt, "jti", decode.string)
}

/// Retrieve the iat from the JWT's payload.
///
pub fn get_issued_at(from jwt: Jwt) -> Result(Int, JwtDecodeError) {
  get_payload_claim(jwt, "iat", decode.int)
}

/// Retrieve the nbf from the JWT's payload.
///
pub fn get_not_before(from jwt: Jwt) -> Result(Int, JwtDecodeError) {
  get_payload_claim(jwt, "nbf", decode.int)
}

/// Retrieve the exp from the JWT's payload.
///
pub fn get_expiration(from jwt: Jwt) -> Result(Int, JwtDecodeError) {
  get_payload_claim(jwt, "exp", decode.int)
}

/// Retrieve and decode a claim from a JWT's payload.
///
pub fn get_payload_claim(
  from jwt: Jwt,
  claim claim: String,
  decoder decoder: Decoder(a),
) -> Result(a, JwtDecodeError) {
  use claim_value <- result.try(
    jwt.payload
    |> dict.get(claim)
    |> result.replace_error(ClaimEmpty),
  )

  decode.run(claim_value, decoder)
  |> result.map_error(fn(e) { ClaimInvalid(e) })
}

pub fn error(err: JwtDecodeError) {
  case err {
    TokenEmpty -> "Token string is empty or null"
    HeaderEmpty -> "Header is empty or null"
    HeaderInvalid -> "Header is invalid"
    PayloadEmpty -> "Payload is empty or null"
    PayloadInvalid -> "Payload is invalid"
    ClaimEmpty -> "Claim is empty or null"
    ClaimInvalid(list_dec_error) -> {
      let dec_errors =
        list.map(list_dec_error, fn(dec_error) {
          "Expected: " <> dec_error.expected <> "Found: " <> dec_error.found
        })
      "Claim is invalid: " <> string.join(dec_errors, "\n")
    }
  }
}

// PRIVATE
//

fn parts(
  jwt_string: String,
) -> Result(
  #(Dict(String, Dynamic), Dict(String, Dynamic), Option(String)),
  JwtDecodeError,
) {
  let parts = string.split(jwt_string, ".")

  use encoded_header <- result.try(
    list.first(parts)
    |> result.replace_error(HeaderEmpty),
  )

  let parts = list.drop(parts, 1)

  use header_string <- result.try(
    encoded_header
    |> bit_array.base64_url_decode()
    |> result.try(bit_array.to_string)
    |> result.replace_error(HeaderInvalid),
  )

  use header <- result.try(
    header_string
    |> json.parse(decode.dict(decode.string, decode.dynamic))
    |> result.replace_error(HeaderInvalid),
  )

  use encoded_payload <- result.try(
    list.first(parts)
    |> result.replace_error(PayloadEmpty),
  )

  let parts = list.drop(parts, 1)

  use payload_string <- result.try(
    encoded_payload
    |> bit_array.base64_url_decode()
    |> result.try(bit_array.to_string)
    |> result.replace_error(PayloadInvalid),
  )

  use payload <- result.map(
    json.parse(payload_string, decode.dict(decode.string, decode.dynamic))
    |> result.replace_error(PayloadInvalid),
  )

  let signature =
    parts
    |> list.first()
    |> option.from_result()

  #(header, payload, signature)
}

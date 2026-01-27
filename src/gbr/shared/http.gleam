////
//// Http util functions
////

import gleam/http/request
import gleam/list
import gleam/option.{None, Some}

/// Set http method to request
///
pub fn set_method(request, method) {
  request.set_method(request, method)
}

/// Append path to request
///
pub fn append_path(request, path) {
  request.set_path(request, request.path <> path)
}

/// Set query string to request
///
pub fn set_query(request, query) {
  let query =
    list.filter_map(query, fn(q) {
      let #(k, v) = q
      case v {
        Some(v) -> Ok(#(k, v))
        None -> Error(Nil)
      }
    })
  case query {
    [] -> request
    _ -> request.set_query(request, query)
  }
}

/// Set body and content type to header in request
///
pub fn set_body(request, mime, content) {
  request
  |> request.prepend_header("content-type", mime)
  |> request.set_body(content)
}

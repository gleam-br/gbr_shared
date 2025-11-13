# 👯 Gleam shared library

Shared libraries to target `javascript` and `erlang` by @gleam-br.

[![Package Version](https://img.shields.io/hexpm/v/gbr_shared)](https://hex.pm/packages/gbr_shared)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/gbr_shared/)

```sh
gleam add gbr_shared@1
```

```gleam
import gbr/shared

pub fn main() -> Nil {
  shared.try()
}
```

Further documentation can be found at <https://hexdocs.pm/gbr_shared>.

## Development

```sh
gleam run   # Run the project
gleam test  # Run the tests
```

## 🌄 Roadmap

- [ ] Unit tests
- [ ] More docs
- [x] GH workflow
  - [x] test & build
  - [x] changelog & issue to doc
  - [x] ~~auto publish~~ manual publish
    - [x] `gleam publish`

# Python — examples

These are seed examples, not a checklist. Explore the actual project and think about what fits it. Check flag and rule names against the docs for the versions in use. The "typical level" column assumes the item is missing. Rank the final level with the SKILL.md grid.

## Versions
| version | adds |
|---|---|
| 3.10 | `match`, `X \| Y` unions |
| 3.11 | `assert_never`, `Self`, `LiteralString`, `StrEnum` |
| 3.12 | `type` alias statement and `class C[T]` syntax (PEP 695), `@override` |
| 3.13 | `TypeIs`, `ReadOnly` for TypedDict, TypeVar defaults |
| 3.14 | deferred annotation evaluation (PEP 649) |

`typing_extensions` backports most typing names to older versions. New syntax (`match`, PEP 695) can't be backported, so tag it `requires: <version>`.

## Making checks non-blocking
- **pyright / basedpyright:** set rule severity to `"warning"` in `[tool.pyright]` or `pyrightconfig.json`. basedpyright also supports a baseline file for existing errors. Per-file `# pyright: strict` works for new modules.
- **mypy:** has no warning severity. Options:
  - run the stricter config as an advisory job
  - turn on strict options per module with `[[tool.mypy.overrides]]`
  - silence legacy packages with `ignore_errors`
- **Ruff:** has no warning severity. Options:
  - run the extra rule sets as an advisory command (`ruff check --exit-zero` or a separate config)
  - `per-file-ignores` for legacy paths

## Basic checks
| item | typical level | notes |
|---|---|---|
| A typechecker that runs in CI: mypy, pyright or basedpyright (ty, Pyrefly and Zuban are newer Rust options) | HIGH | many web frameworks run without one |
| Strict mode: `mypy --strict` or pyright `typeCheckingMode = "strict"` | HIGH | advisory or per-module first |
| Ruff with typing-related rule sets: `ANN`, `UP`, `B`, `TC`, `PGH` (blanket `# type: ignore`), `FA` (if < 3.10) | HIGH | advisory |
| Stubs for untyped dependencies (`types-*`, `django-stubs`, …); `py.typed` marker for libraries | HIGH | |
| Typechecker plugins for frameworks already in use (pydantic mypy plugin, django-stubs, SQLAlchemy 2 `Mapped[]`) | HIGH | |
| Codegen output (OpenAPI clients, protobuf, GraphQL) regenerated and checked with `git diff --exit-code` | HIGH | advisory step |

## Advanced checks
| item | typical level | notes |
|---|---|---|
| mypy `warn_unreachable` + `enable_error_code = ["ignore-without-code", "redundant-expr", "truthy-bool", "possibly-undefined", "explicit-override", "unused-awaitable"]` | MEDIUM-HIGH | advisory |
| basedpyright `"all"` / `reportAny`, `reportUnknown*`, `reportImplicitOverride` as warnings | MEDIUM-HIGH | |
| Ruff `FBT` (boolean traps), `SLF` (private access), `RUF`, `ARG` | MEDIUM-HIGH | advisory |
| Type assertions in tests (`assert_type`), property tests (Hypothesis `st.from_type`) | MEDIUM-HIGH | |
| Runtime type checking across the whole package (`beartype.claw`), contracts (deal, icontract), CrossHair | LOW | changes runtime behavior |

## Patterns and libraries
| item | typical level | notes |
|---|---|---|
| `@dataclass(frozen=True, slots=True, kw_only=True)` for value objects | MEDIUM-HIGH | new code first |
| `NewType` for IDs and values | MEDIUM-HIGH | zero cost |
| Tagged unions: `Literal` discriminator field + `match` + `assert_never` | MEDIUM-HIGH | |
| `TypedDict` (with `NotRequired`/`ReadOnly`) for dict payloads instead of `dict[str, Any]` | MEDIUM-HIGH | |
| `Protocol`, `Final`, `@final`, `@override`, `LiteralString` (SQL/shell inputs), `StrEnum` | MEDIUM-HIGH | |
| Parse at boundaries: pydantic v2 (`strict=True`, discriminated unions, `Annotated` constraints), msgspec, attrs + cattrs | MEDIUM-HIGH | |
| Result/Maybe types: `returns` (has a mypy plugin), `result` | MEDIUM-HIGH | new modules |
| Data shapes: pandera (DataFrames), jaxtyping / `numpy.typing` (arrays), pint (units) | MEDIUM-HIGH | only if the domain needs them |
| Result types or runtime checking everywhere; moving from untyped dicts to models across the codebase | LOW | migration |
| Upgrading Python to unlock new syntax | LOW | `requires: <version>` |

## Feature markers (yes/no greps, never counts)
`NewType(`, `Literal[`, `assert_never`, `TypedDict`, `Protocol`, `@final`, `@override`, `frozen=True`, `BaseModel`, `msgspec.Struct`, `@beartype`, `# type: ignore`, `cast(`, `: Any`

## Per-file and fast commands
- `ruff check <file>`
- `pyright <file>` / `basedpyright <file>`: checks the file but still resolves its imports.
- `mypy <file>`: follows imports and is slower. `dmypy run -- <file>` keeps a daemon running for faster repeat checks.
- `ty check <file>`: very fast, pre-1.0.

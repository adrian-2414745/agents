# Scala — examples

These are seed examples, not a checklist. Explore the actual project and think about what fits it. Check flag names against the docs for the project's Scala and tool versions. The "typical level" column assumes the item is missing. Rank the final level with the SKILL.md grid.

## Versions
- Scala 2.13 vs Scala 3 matters most. Opaque types, `enum`, union/intersection types, `derives`, explicit nulls and `CanEqual` are Scala 3 only.
- Scala 2 backports: `scala-newtype` or `AnyVal` for newtypes, `enumeratum` for enums, `-Xsource:3` for private `apply`/`copy` on private constructors.
- Some flags were renamed, e.g. `-Ysafe-init` became `-Wsafe-init`. Check the docs for the version in use.

## Making checks non-blocking
- Compiler warnings: `-Wconf:<filter>:w` keeps a category as a warning, and `:e` makes it an error. Don't turn on `-Werror` until the owner wants it.
- **sbt-tpolecat:** the default CI mode makes warnings fatal. To keep warnings non-fatal, use `tpolecatExcludeOptions += ScalacOptions.fatalWarnings` or DevMode.
- **WartRemover:** `wartremoverWarnings ++= …` instead of `wartremoverErrors`.
- **Scalafix lint:** run `scalafix --check` as an advisory CI step that's allowed to fail.

## Basic checks
| item | typical level | notes |
|---|---|---|
| sbt-tpolecat, or the same flags set by hand: `-deprecation -feature -unchecked -Wunused:all -Wvalue-discard` (plus `-Xlint` on 2.13) | HIGH | warnings first |
| Non-exhaustive match warnings visible, not suppressed with `@unchecked` or `-Wconf:…:s`; on 2.13 add `-Xlint:strict-unsealed-patmat` | HIGH | |
| Scalafix `DisableSyntax`: `noNulls`, `noAsInstanceOf`, `noIsInstanceOf`, `noReturns`, `noThrows` (optional), `noVars` (optional) | HIGH | syntactic rules, no build changes |
| WartRemover `Warts.unsafe` (`Any`, `AsInstanceOf`, `Null`, `OptionPartial`, `IterableOps`, `Return`, `Throw`, `Var`, …) | HIGH | as warnings |
| Codegen output (caliban, smithy4s, protobuf/scalapb, sbt-buildinfo) regenerated in CI and checked with `git diff --exit-code` | HIGH | advisory step |

## Advanced checks
| item | typical level | notes |
|---|---|---|
| `-Wnonunit-statement`, `-Wsafe-init`, `-source:future` deprecations | MEDIUM-HIGH | warnings |
| WartRemover `Warts.all` (or a curated extra set: `Equals`, `DefaultArguments`, `ToString`, …) | MEDIUM-HIGH | warnings |
| `-language:strictEquality` + `CanEqual` derivation | LOW | compile errors only |
| `-Yexplicit-nulls` | LOW | whole-codebase migration |
| Capture checking (`language.experimental.captureChecking`) | LOW | experimental |
| Stainless (formal verification for a subset of Scala) | LOW | |
| Type-level tests (`compiletime.testing.typeChecks`), property tests (ScalaCheck, zio-test `check`) | MEDIUM-HIGH | |

## Patterns and libraries
| item | typical level | notes |
|---|---|---|
| Newtypes for IDs and values: Scala 3 `opaque type`; libraries `neotype`, zio-prelude `Newtype`/`Subtype`, `monix-newtypes` | MEDIUM-HIGH | new code first |
| ADTs for states and variants: `enum`, `sealed trait` + case classes, instead of flags plus `Option` fields | MEDIUM-HIGH | |
| Smart constructors: `final case class X private (…)` + `from: Either[E, X]` | MEDIUM-HIGH | |
| Refinement types at boundaries: **Iron** (Scala 3), **refined** (Scala 2) | MEDIUM-HIGH | has codec integrations |
| Non-empty collections and accumulated validation: cats `NonEmptyList`/`ValidatedNec`, zio-prelude `NonEmptyChunk`/`Validation` | MEDIUM-HIGH | |
| Typed error ADTs in the error channel (`ZIO[R, AppError, A]` instead of `Throwable`) | MEDIUM-HIGH | when ZIO/cats-effect is already used |
| Type-safe model mapping: **chimney**, **ducktape** | MEDIUM-HIGH | catches missing fields at compile time |
| Typed boundaries: tapir / smithy4s / caliban; doobie / skunk / quill / magnum; derived codecs (circe, zio-json, jsoniter-scala) | MEDIUM-HIGH | |
| Units of measure: squants, coulomb | MEDIUM-HIGH | only if the domain needs them |
| Adopting an effect system (ZIO, cats-effect) in an imperative codebase | LOW | migration |
| Typestate / phantom types across public APIs; heavy type-level code (match types) | LOW | |
| Scala 2 → 3 to unlock the above | LOW | `requires: Scala 3` |

## Feature markers (yes/no greps, never counts)
`opaque type`, `enum `, `sealed trait`, `derives `, `CanEqual`, `:|` (Iron), `Refined[`, `Newtype[`, `NonEmptyList`, `NonEmptyChunk`, `Validated`, `Validation[`, `.asInstanceOf[`, `null`

## Per-file and fast commands
- There's no reliable per-file typecheck. Use the incremental build: `sbt --client <module>/compile` (or `Test/compile`) with the sbt server kept warm.
- IDE diagnostics (Metals/BSP, IntelliJ) through an LSP or IDE integration can give per-file results when available.
- Scalafix syntactic rules (e.g. `DisableSyntax`) can run on one file with the scalafix CLI. Semantic rules need a compiled classpath.

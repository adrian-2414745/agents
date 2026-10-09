# TypeScript — examples

These are seed examples, not a checklist. Explore the actual project and think about what fits it. Check flag and rule names against the docs for the versions in use. The "typical level" column assumes the item is missing. Rank the final level with the SKILL.md grid.

## Versions
| version | adds |
|---|---|
| 4.9 | `satisfies` |
| 5.0 | `const` type parameters |
| 5.2 | `using` |
| 5.4 | `NoInfer` |
| 5.5 | inferred type predicates |
| 5.6 | `noUncheckedSideEffectImports` |
| 5.8 | `erasableSyntaxOnly` |
| 6.0 | bridge release; check whether `strict` is now the default |
| 7 | native Go compiler (`tsgo`), much faster typecheck |

## Making checks non-blocking
- **ESLint:** set the rule to `"warn"`. ESLint 9.24+ also has bulk suppressions (`eslint --suppress-all`) for existing violations.
- **tsc:** has no warning severity. Use an advisory config `tsconfig.strict.json` (`extends` the base config and adds the flags), run with `tsc -p tsconfig.strict.json --noEmit` without failing CI. Alternatively, make new packages strict through project references.
- **type-coverage:** advisory, or with `--at-least <current>` as a ratchet.

## Basic checks
| item | typical level | notes |
|---|---|---|
| A real typecheck step (`tsc --noEmit` / `tsc -b`) in CI and scripts | HIGH | Vite, esbuild, swc, Bun and tsx strip types **without checking them** |
| `strict: true` | HIGH | advisory config first |
| `noImplicitReturns`, `noFallthroughCasesInSwitch`, `noImplicitOverride` | HIGH | advisory config |
| typescript-eslint `recommended-type-checked`: `no-explicit-any`, `no-unsafe-*`, `no-floating-promises`, `no-misused-promises` | HIGH | as warnings |
| `@ts-ignore` banned in favor of `@ts-expect-error` with a description (`ban-ts-comment`) | HIGH | |
| Codegen output (graphql-codegen, openapi-typescript, Prisma client) regenerated and checked with `git diff --exit-code` | HIGH | advisory step |

## Advanced checks
| item | typical level | notes |
|---|---|---|
| `noUncheckedIndexedAccess`, `exactOptionalPropertyTypes`, `noPropertyAccessFromIndexSignature` | MEDIUM-HIGH | advisory config |
| typescript-eslint `strict-type-checked`, `switch-exhaustiveness-check`, `strict-boolean-expressions`, `no-unnecessary-condition`, `consistent-type-assertions` (`assertionStyle: "never"`), `no-non-null-assertion` | MEDIUM-HIGH | warnings |
| `prefer-readonly-parameter-types`, eslint-plugin-functional (immutability) | MEDIUM-HIGH | warnings, can be noisy |
| type-coverage | MEDIUM-HIGH | advisory |
| Type tests: vitest `expectTypeOf`, tsd, expect-type; property tests: fast-check | MEDIUM-HIGH | |
| ts-reset (makes `JSON.parse` / `.json()` return `unknown`) | MEDIUM-HIGH | advisory config |
| `erasableSyntaxOnly` (removes enums and namespaces), `verbatimModuleSyntax`, `isolatedModules` | LOW | compile errors only, `requires: 5.8` for the first |

## Patterns and libraries
| item | typical level | notes |
|---|---|---|
| Discriminated unions + exhaustive `default: x satisfies never` | MEDIUM-HIGH | new code first |
| Branded types for IDs and values (`string & { readonly [brand]: "UserId" }`), type-fest `Tagged` | MEDIUM-HIGH | |
| `as const` + `satisfies`, literal unions instead of `enum`, `readonly` / `ReadonlyArray` | MEDIUM-HIGH | |
| Parse at boundaries (fetch, env, `JSON.parse`, queue messages): Zod, Valibot, ArkType, TypeBox, Typia | MEDIUM-HIGH | |
| ts-pattern `.exhaustive()`; Result types: neverthrow, true-myth | MEDIUM-HIGH | |
| Typed API and DB layers: tRPC, ts-rest, openapi-typescript, GraphQL codegen; Kysely, Drizzle, Prisma | MEDIUM-HIGH | |
| Effect (typed errors and dependencies, Schema, Brand) as the app's core; XState for complex flows | LOW | migration |
| Upgrading TypeScript to unlock features | LOW | `requires: <version>` |

## Feature markers (yes/no greps, never counts)
`__brand`, `unique symbol`, `satisfies never`, `: never =`, `as const`, `z.object(`, `v.object(`, `.exhaustive()`, `neverthrow`, `from "effect"`, `as any`, `@ts-ignore`, `!.`

## Per-file and fast commands
- `eslint <file>`, `oxlint <file>`, `biome check <file>`
- tsc can't check one file under the project config. Use incremental `tsc -b` / `tsc --noEmit --incremental`, or `tsgo --noEmit` (TS 7) for speed.
- IDE/LSP diagnostics give per-file typecheck results when available.

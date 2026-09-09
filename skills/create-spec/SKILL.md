# Spec: <slug / feature name>

> A specification describes **what** the system must do, not **how** it is built.
> Implementation (interfaces, functions, data types, schema, data flow) belongs in `plan-<slug>.md`.


## 2. Problem

Plain english. What is wrong or missing today.

## 3. Context / Background

*(Optional — include only if "why now" is not obvious from the problem.)*

## 4. Goals & Non-Goals

**Goals**
- We will 

**Non-Goals**
- We explicitly will not 

## 5. Solution

Plain english. The high-level intended behavior once shipped — the *what*, not the *how*.

## 6. Actual / Current Behavior

Reference to a file describing today's behavior. *(Skip if none provided.)*

## 7. Scope

- **Changes**: what this spec adds or alters.
- **Unchanged**: what stays as-is.
- **Adjacent — adapted**: nearby features/behaviors that must be adjusted to fit.
- **Adjacent — out of scope**: nearby features/behaviors explicitly left untouched.

## 8. Assumptions

Facts we treat as true for the proposed solution and acceptance criteria. If one is false, the spec may not hold.

## 9. Observability

What signals prove, in production, that the behavior is correct: metrics, logs, traces, alerts.

## 10. Rollout & Config

How the behavior is turned on and controlled: feature flag, traffic-percent, kill switch, default values, staged rollout.

## 11. Migration Strategy

Plain english. How we move from current behavior to the new behavior (data, traffic, consumers).

## 12. Rollback Plan

Plain english. How we safely return to prior behavior if something goes wrong.

## 13. Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |


## 14. Acceptance Criteria (BDD)

Each scenario in Given / When / Then. Cover success, corner-cases, expected-failure, and migration.

**Success**
- **Scenario:** 
  - Given
  - When
  - Then

**Corner cases**
- **Scenario:** 
  - Given
  - When
  - Then

**Expected failures**
- **Scenario:** 
  - Given
  - When
  - Then

**Migration**
- **Scenario:** 
  - Given  (pre-migration state)
  - When  (migration runs)
  - Then  (post-migration state)

### 14a. Coverage Matrix

Combinatorial coverage — exposes combinations not written as a named scenario above.
Rows/columns are the dimensions that matter for this feature (inputs × states × config buckets × vendors ).

| Dimension A \ Dimension B | Condition B1 | Condition B2 | Condition B3 |
|---|---|---|---|
| Condition A1 | expected result | | |
| Condition A2 | | | |
| Condition A3 | | | |

### 14b. Traceability Matrix

Ties every acceptance criterion to a real test and makes "are we done" objective.

| # | Acceptance scenario name | Test level (unit / IT / e2e / manual) | Automated? | Status |
|---|---|---|---|---|
| AC-1 | | | | not-started |
| AC-2 | | | | not-started |

## 15. Open Questions

Unresolved unknowns. The spec can ship at `draft` with these listed.

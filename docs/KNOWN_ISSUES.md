# Known Issues

No known parser, missing-resource, grid-mechanics, camera-mechanics, visual-layering, world-object-selection, reskin-coupling, or integration issue through the built Phase 1 world-object-selection slice.

No known parser, validation, lookup, ordering, partial-publication, or presentation-metadata-coupling issue in the built Phase 2 resource-catalog slice.

No known initialization, balance-query, credit/debit, affordability, copied-view, or presentation-metadata-coupling issue in the built Phase 2 resource-ledger slice.

No known parser, reward-contract, resource-target validation, ordering, lookup, atomic-publication, copied-view, or presentation-metadata-coupling issue in the built Phase 2 gathering-action catalog slice. GUI and export behavior were not involved or claimed.

No known dependency-validation, action-resolution, exact-credit, balance-isolation, repeated-execution, result-status, catalog-mutation, or presentation-metadata-coupling issue in the built Phase 2 gathering-action executor slice. The executor is runtime-only; GUI and export behavior were not involved or claimed.

No known parser, dependency-validation, catalog-order, explicit-refresh, balance-isolation, invalid-setup, or presentation-metadata-coupling issue in the built Phase 2 resource-HUD slice. Subjective GUI readability, spacing, and mobile hierarchy remain unverified; no export behavior is claimed.

No known startup-composition, semantic-control binding, exact-credit, repeated-accumulation, rejection-safety, HUD-refresh, or presentation-metadata-coupling issue in the built Phase 2 playable gathering-loop slice. Mobile tap targets, UI/world overlap, readability, hierarchy, camera coexistence, and click feel remain unverified in the headless builder environment; no export behavior is claimed.

QA verified the visual-layering slice at builder commit `85f1d9f` with no integration fix required.

QA verified the world-object-selection slice at builder commit `4f2fd6d` with no integration fix required.

QA verified the Phase 2 resource-catalog slice at builder commit `d79fc1f` with no integration fix required.

QA verified the Phase 2 resource-ledger slice at builder commit `178f874` with no integration fix required.

QA verified the Phase 2 gathering-action catalog slice at builder commit `0f9aaca` with no integration fix required.

QA verified the Phase 2 gathering-action executor slice at builder commit `dd199c9` with no integration fix required.

QA verified the Phase 2 resource-HUD slice at builder commit `28dc399` with no integration fix required. Subjective HUD readability, spacing, and mobile hierarchy remain unverified in the headless QA environment.

QA verified the Phase 2 playable gathering-loop slice at builder commit `5178e43` with no integration fix required. Mobile tap targets, UI/world overlap, readability, hierarchy, camera coexistence, and click feel remain unverified in the headless QA environment.

QA verified the Phase 3 building-definition catalog slice at builder commits `65916b8` and `a248fa0` with no integration fix required. No known authority, numeric-validation, resource-reference, atomic-publication, copied-view, persistence, or presentation-coupling issue was found; GUI and export behavior were not involved or claimed.

Manual GUI world-object pointer feel, selection-marker readability, pointer-drag and wheel feel, camera framing, placeholder overlap/readability, and equal-depth sibling-order appearance remain unverified in the headless QA environment. Browser/export validation has not been claimed.

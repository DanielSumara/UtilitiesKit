# Implementation plans

Skill `plan-increment` turns an `Approved` spec `docs/specs/{feature}/{name}.md` into `docs/plans/{feature}/{name}.md`: ordered slices, each with its ACs, area, review depth (`full` or `diff-only`) and a Progress row.
Skill `implement-increment` runs it on `main`: per slice implement → lint and gate → commit → review → fix → gate → commit, then a review of the whole increment and its fixes.
Regenerate a plan when its spec changes; keep `Done` slices and their commits.

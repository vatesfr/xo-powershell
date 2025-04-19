Implementation notes
--------------------

- `ValueFromPipelineByPropertyName` and similar params are not bound in `begin{}`. Do all the filter/limit prep in `end{}` instead.
- In general, try/catch should be reserved for cleanup, and the error handling should be controlled by `$ErrorActionPreference`.
- Module-level variables should not be globals (e.g. by using `$Script:VariableName` instead).

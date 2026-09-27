# Shared lint pilot

The [pilot workflow](workflows/zsh-lint-pilot.yml) qualifies the shared reporting wrapper under [issue #30](https://github.com/z-shell/zunit/issues/30). It runs on every pull request targeting `main`, including documentation-only changes and forks, and every push to `main`.

The explicit [configuration](../zsh-lint.json) selects only `build.zsh`, with the `standalone-executable` profile and unchanged Zsh 5.5.1 floor. Runtime libraries, generated `zunit`, tests and the ZUnit DSL retain their existing validation and are outside this analyzer inventory.

The config uses schema v2 and identifier `zunit`, replacing the obsolete schema-v1 empty namespace list. The existing lint job and pilot both pin released analyzer v1.3.0 at `999cb76cc65ef6af56c0ae65ab0f3622eb527944`; that release rejects schema v1. The existing required check name remains unchanged. Direct and wrapped analyzer invocations must be compared at the same revision and configuration to isolate wrapper behavior.

The pilot pins the reviewed shared workflow at `af725f0ad9c7b24dd4f4527e582ade2eb8e9ea7b`. Its artifact records both revisions, the resolved inventory, diagnostics, stderr and outcome. Artifact retention is 14 days; lasting qualification evidence belongs on issue #30.

`mode: observe` reports semantic findings without failing the job. Parser failures, malformed configuration and infrastructure failures still fail. The caller grants only `contents: read`, passes no secrets and uses the ordinary `pull_request` event. The new check remains advisory; required-check changes need separate approval after hosted check-name, trigger and fork qualification.

Native syntax, compilation and functional workflows remain active. The analyzer profile's declared minimum is not a replacement for runtime testing at that version. Roll back this enrollment by reverting the pilot workflow and this guide, and restore the old config and analyzer commit `1e8b0a6c02d4aa433e6aee8ca141e11ef62ba76b` together. Mixing schema v1 with v1.3.0 fails configuration validation.

# Release & Versioning

## Release Checklist

When `lib/solid/process/version.rb` is changed:
1. Verify `CHANGELOG.md` has a matching version entry (e.g., `## [0.5.0] - YYYY-MM-DD`)
2. Verify `README.md` compatibility matrix is up-to-date if Ruby/Rails support changed

## Ruby/Rails Version Alignment

When modifying Ruby or Rails version support, ensure these files stay aligned:

| File | Purpose |
|------|---------|
| `Appraisals` | Source of truth for gem dependencies per Rails version |
| `Rakefile` | Local `rake matrix` task conditions |
| `.github/workflows/main.yml` | CI matrix and step conditions |
| `README.md` | Compatibility matrix table |

**Key checks:**
1. Ruby version conditions must match across `Appraisals`, `Rakefile`, and CI
2. CI string values (e.g., `'head'`) need explicit checks since numeric comparisons won't match them
3. README table must reflect the actual tested combinations
4. Ruby `head` should only run against Rails edge (not stable Rails versions)

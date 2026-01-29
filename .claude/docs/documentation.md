# Documentation Conventions

## Back-to-Top Anchors

Both `README.md` and `docs/REFERENCE.md` use back-to-top navigation after each main section. When adding a new numbered section to `REFERENCE.md`:

1. Add `<p align="right"><a href="#table-of-contents">⬆️ &nbsp;back to top</a></p>` before the `---` that closes the section
2. Update the Table of Contents with the new entry

## Overview File Structure

Each file in `docs/overview/` follows this layout:

1. **Header nav** — `<small>` block with `` `Previous` `` and `` `Next` `` links
2. **`---`** separator
3. **Content** — starts with a `#` title
4. **`---`** separator
5. **Footer nav** — `<small>` block with the same `` `Previous` ``/`` `Next` `` links as the header

Navigation chain: `010_KEY_CONCEPTS` → `020_BASIC_USAGE` → … → `100_PORTS_AND_ADAPTERS`. The first file's `Previous` links to `../README.md#further-reading`; the last file's `Next` links to `../REFERENCE.md`.

When adding a new overview file:

1. Follow the numbered naming convention (e.g., `110_NEW_TOPIC.md`)
2. Add header and footer nav blocks with `---` separators
3. Update the `Previous`/`Next` links in the adjacent files to include the new file

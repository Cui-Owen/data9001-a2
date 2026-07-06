# DATA9001 A2 Reference Site

Static GitHub Pages site for Assignment 2 reference materials.

Published Pages URL:

https://cui-owen.github.io/data9001-a2/

Expected repository:

https://github.com/Cui-Owen/data9001-a2

Republish from this directory after local content changes:

```bash
./publish_to_github_pages.sh
```

The script creates the public repository if needed, pushes the local `main` branch, and enables GitHub Pages from the repository root.

The downloadable `assets/reference-answer.tex` is self-contained (plot data and the R appendix are inlined), so it compiles standalone on Overleaf with no external files. The `assets/a2-analysis-code.R` download is the Chinese-annotated teaching version shown in the R tab.

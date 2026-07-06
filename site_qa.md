# DATA9001 A2 reference site QA

Date: 2026-07-06

## Output

- Site entry: `index.html`
- PDF: `assets/reference-answer.pdf`
- LaTeX source: `assets/reference-answer.tex`
- R source: `assets/a2-analysis-code.R`
- Data files:
  - `assets/Apartment_prices.csv`
  - `assets/Historical_demographic.csv`
  - `assets/Projected_demographic.csv`

## 2026-07-06 revision

- Report body expanded to ~500 words (was ~413, below the 450 lower bound) and
  now explicitly discusses the Gauss-Markov assumptions (exogeneity /
  omitted-variable bias and possible heteroskedasticity). All numbers, tables,
  coefficients and the SEAFORD/DROUIN recommendation are unchanged.
- `assets/reference-answer.tex` is now self-contained: the histogram and scatter
  data are inlined as coordinates and the R appendix is inlined via `lstlisting`,
  so the downloaded `.tex` compiles standalone (verified in an empty directory
  and on the Overleaf-equivalent tectonic engine) with no external `.dat` files.
  This fixes the previous missing-dependency issue.
- The "R 代码" tab and the downloadable `assets/a2-analysis-code.R` now carry
  detailed Chinese comments explaining each cleaning/modelling choice. The code
  tokens are byte-identical to the uncommented version (verified), so results are
  unchanged. The PDF R appendix keeps the clean English listing.
- Verified independently (pure recomputation from the raw CSVs): R^2 = 0.5225,
  all five coefficients, and the predicted rankings all reproduce exactly.

## Browser Checks

- Local preview URL: `http://127.0.0.1:9022/`
- Page title: `DATA9001 A2 Reference Solution`
- Main heading present.
- MathJax script present for web formula rendering.
- PDF iframe points to `assets/reference-answer.pdf`.
- SEAFORD and DROUIN recommendation content present.
- R code content includes `parse_number` and `predict`, plus Chinese comments.
- Tabs checked: web answer, PDF, LaTeX source, R code, data files.
- Browser console errors: none.
- Mobile viewport check: 390px wide, no horizontal overflow.

## Publishing Notes

This folder is published as a GitHub Pages static site. It includes `.nojekyll` so assets are served directly.

Published URL:

https://cui-owen.github.io/data9001-a2/

Repository:

https://github.com/Cui-Owen/data9001-a2

The helper script `publish_to_github_pages.sh` checks GitHub CLI authentication, creates `Cui-Owen/data9001-a2` if needed, pushes `main`, and enables GitHub Pages from the repository root. It requires a clean working tree, so commit changes before running it.

Public access checks completed (before the 2026-07-06 revision; re-run after publishing):

- `index.html`: HTTP 200
- `assets/reference-answer.pdf`: HTTP 200
- `assets/reference-answer.tex`: HTTP 200
- `assets/a2-analysis-code.R`: HTTP 200
- `assets/Apartment_prices.csv`: HTTP 200

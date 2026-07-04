# DATA9001 A2 reference site QA

Date: 2026-07-04

## Output

- Site entry: `index.html`
- PDF: `assets/reference-answer.pdf`
- LaTeX source: `assets/reference-answer.tex`
- R source: `assets/a2-analysis-code.R`
- Data files:
  - `assets/Apartment_prices.csv`
  - `assets/Historical_demographic.csv`
  - `assets/Projected_demographic.csv`

## Browser Checks

- Local preview URL: `http://127.0.0.1:9022/`
- Page title: `DATA9001 A2 Reference Solution`
- Main heading present.
- MathJax script present for web formula rendering.
- PDF iframe points to `assets/reference-answer.pdf`.
- SEAFORD and DROUIN recommendation content present.
- R code content includes `parse_number` and `predict`.
- Tabs checked: web answer, PDF, R code, data files.
- Browser console errors: none.
- Mobile viewport check: 390px wide, no horizontal overflow.

## Publishing Notes

This folder is ready to publish as a GitHub Pages static site. It includes `.nojekyll` so assets are served directly.

The helper script `publish_to_github_pages.sh` checks GitHub CLI authentication, creates `Cui-Owen/data9001-a2` if needed, pushes `main`, and enables GitHub Pages from the repository root.

# Site QA

Date: 2026-07-06

## Output

- Site entry: `index.html`
- PDF: `assets/m01.pdf`
- LaTeX source: `assets/m01.tex`
- R source: `assets/m02.R`
- Sample PDF: `assets/m03.pdf`
- Data files:
  - `assets/d01.csv`
  - `assets/d02.csv`
  - `assets/d03.csv`

## Privacy-oriented publishing changes

- Existing public URL and repository target are preserved.
- Public asset names changed to short neutral names.
- HTML title, description, footer, and repository docs were changed to neutral
  labels.
- The page includes a `noindex` robots meta tag.
- `robots.txt` discourages crawling of downloadable assets and repository notes.

## Browser checks

- Page title: `Study Notes`
- MathJax script present for web formula rendering.
- PDF iframe points to `assets/m01.pdf`.
- Tabs checked: web answer, PDF, LaTeX source, R code, data files.
- Web answer includes the Sample download and a section explaining what
  to learn from the sample report.
- Web answer hierarchy separates supplement materials from the three-part
  reference answer: Data Summary, Model Estimation, and Model Interpretation.
- Recommendation is intentionally placed at the end of Model Interpretation,
  after data handling, model estimation, coefficient interpretation, and
  projected-data prediction.
- Mobile viewport target: 390px wide, no horizontal overflow expected.

## Publishing notes

Published URL after sync:

https://cui-owen.github.io/data9001-a2/

Repository after sync:

https://github.com/Cui-Owen/data9001-a2

Run `./sync.sh` from this directory after committing local changes. GitHub CLI
authentication is required.

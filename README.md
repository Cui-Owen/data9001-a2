# DATA9001 A2 Reference Site

Static GitHub Pages site for Assignment 2 reference materials.

Target Pages URL after publishing:

https://cui-owen.github.io/data9001-a2/

Expected repository:

https://github.com/Cui-Owen/data9001-a2

Publish from this directory after GitHub authentication is restored:

```bash
gh auth login -h github.com
./publish_to_github_pages.sh
```

The script creates the public repository if needed, pushes the local `main` branch, and enables GitHub Pages from the repository root.

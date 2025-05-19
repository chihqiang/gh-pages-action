# Publish to Git Branch

> A GitHub Action to publish a specified directory to a target Git branch (e.g., `gh-pages`), with optional CNAME support.

---

## Features

- Publish the contents of a local directory (e.g., `dist`) to a specified branch, ideal for deploying static sites.
- Customize the commit message.
- Optionally create a `CNAME` file for custom domain support.
- Specify the target repository (defaults to the current repository).
- Uses a token for HTTPS authentication.

---

## Usage Example

```yaml
- name: Publish to gh-pages branch
  uses: chihqiang/gh-pages-action@main
  with:
    publish_dir: dist
    target_branch: gh-pages
    commit_message: 'Deploy Static Site to Github gh-pages Branch'
    cname: example.com
    repository: user/repo  # Optional, defaults to current repo
    token: ${{ secrets.GITHUB_TOKEN }}  # Required, authentication token
```

## Inputs

| Input            | Required | Default                                  | Description                                                  |
| ---------------- | -------- | ---------------------------------------- | ------------------------------------------------------------ |
| `token`          | ✅ Yes    | —                                        | Token for HTTPS authentication, usually `${{ secrets.GITHUB_TOKEN }}` |
| `publish_dir`    | ✅ Yes    | —                                        | The local directory to publish (e.g., `dist`)                |
| `target_branch`  | ❌ No     | `gh-pages`                               | The branch to publish to                                     |
| `commit_message` | ❌ No     | `🔄 update commit: 12345`                 | Commit message for the push                                  |
| `cname`          | ❌ No     | —                                        | Custom domain for a `CNAME` file                             |
| `repository`     | ❌ No     | Current repository (`GITHUB_REPOSITORY`) | The repo to push to, e.g., `user/repo`                       |

## Notes

- Ensure the token has permission to push to the repository.
- If `repository` is not set, the action pushes to the current repository.
- The `cname` input is used to create a `CNAME` file for custom domains.

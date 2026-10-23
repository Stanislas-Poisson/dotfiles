# Contributing

Thank you for helping. This repository is the shell setup of one person: fixes and suggestions are welcome, but a change that does not fit the author's own setup may be declined.

---

## Development workflow

| Step | Command / Action | Description |
| :--- | :--- | :--- |
| **1. Issue** | Open or pick an issue | Optional for a small fix. |
| **2. Branch** | `git checkout -b type/short-name main` | Create a branch from `main`. |
| **3. Code** | *(your editor)* | Keep the change small. Each file of `bashrc.d/` does one thing. |
| **4. Check** | `shellcheck -s bash -S warning bashrc bashrc.d/*.sh bin/store-token install.sh scripts/*.sh` | ShellCheck must stay clean. |
| **5. Scan** | `scripts/check-secrets.sh --all` | No secret, ever. The pre-commit hook runs it on the staged files. |
| **6. Commit** | `git commit -m "type(scope): subject"` | In English, 72 characters at most. |
| **7. Push** | `git push origin type/short-name` | Push and open a pull request to `main`. |

The `ci` check must pass. A pull request is merged with a merge commit, and direct pushes to `main` are blocked.

---

## Checks

| Command | Tool | Description |
| :--- | :--- | :--- |
| `shellcheck -s bash -S warning ...` | ShellCheck | Lint every shell file. |
| `scripts/check-secrets.sh` | Secret scanner | Staged files only, used by the pre-commit hook. |
| `scripts/check-secrets.sh --all` | Secret scanner | Every tracked file, used by the CI. |
| `bash -ic exit` | Bash | The shell must start without any message. |

After a change to `bashrc.d/`, open a new terminal, or run `exec bash`, before the pull request. `source ~/.bashrc` is safe too: PATH and the prompt hook are added once.

---

## Rules of the files

- A file of `bashrc.d/` holds no secret, no address, no host name. Tokens live in `~/.config/tokens/`.
- Scripts that other files call must not print anything when everything is fine.
- Comments are on their own line, above the code.
- No long dashes: use `-`.

---

## Language

Code, comments, commits, issues and pull requests are in English.

# dotfiles

[![CI][ci-badge]][ci]
[![License][license-badge]][license]

The shell setup of Stanislas Poisson (Debian on WSL2): a thin `~/.bashrc` that loads one file per topic from `~/.bashrc.d/`, a prompt that shows the state of the repository at a glance, and the small tooling that keeps secrets out of the shell and out of Git.

## The principle

- **No secret in this repository.** Tokens live outside, in `~/.config/tokens/`, one file each, readable by the owner only. A pre-commit hook and the CI refuse anything that looks like a secret.
- **A token reaches only the process that needs it.** `claude`, `ghp` and `ghz` load the tokens in a sub-shell for one command. The terminal itself never holds them.
- **One topic per file, loaded once.** The files can be sourced again safely: PATH entries are deduplicated and the prompt hook is added once.
- **Expiry is tracked.** A list of names and dates warns when a secret expires soon.

## Layout

| Path | Purpose |
| :--- | :--- |
| `bashrc` | Linked as `~/.bashrc`. Interactive guard, loads `~/.bashrc.d/*.sh` in order, then the optional `~/.bash_aliases` (local, not versioned). |
| `bashrc.d/00-env.sh` | Environment, PATH, history, colors, `shopt` options, arrow-key history search. |
| `bashrc.d/10-prompt.sh` | Prompt: time, user and host, exit code on failure, shortened path, cached git status. |
| `bashrc.d/20-aliases.sh` | Aliases (ls, git, docker, safety, navigation). |
| `bashrc.d/30-functions.sh` | `maj`, `mkcd`, `extract`, `psg`, `serve`, `vps-clear`, `myip`. |
| `bashrc.d/40-wsl.sh` | WSL only: `explore`, `open`. |
| `bashrc.d/50-tools.sh` | Bash completion. Node is the system package, there is no version manager. |
| `bashrc.d/60-ai-tokens.sh` | `claude`, `ghp`, `ghz`: load tokens for one process only. |
| `bashrc.d/70-token-expiry.sh` | `tokens` command and the warning shown when a secret expires soon. |
| `bin/store-token` | Stores a secret in `~/.config/tokens/<NAME>.env` without showing it. |
| `tokens/expiry.list.example` | Format of the expiry list (names and dates only). |
| `scripts/check-secrets.sh` | Secret scanner, run by the pre-commit hook and by the CI. |
| `install.sh` | Links everything into `$HOME`. |

## Install

```bash
git clone git@github.com:Stanislas-Poisson/dotfiles.git ~/code/Stanislas-Poisson/dotfiles
~/code/Stanislas-Poisson/dotfiles/install.sh
exec bash
```

`install.sh` links `~/.bashrc`, `~/.bashrc.d` and `~/.local/bin/store-token` to the repository, creates `~/.config/tokens` (mode 700), enables the pre-commit hook, and creates `~/.config/tokens/expiry.list` from the example when it is missing. An existing file is moved to `<name>.bak-<date>`, never deleted. The script can be run again safely.

Requires bash 5 and git. The commands below also use `claude`, `gh` and `ssh`.

## Prompt

```text
(18:34:36) user@host ✗ 1
~/code/project
git: main +2 ~1 ?3 📦1 ↑1 ↓2
>
```

| Symbol | Meaning |
| :--- | :--- |
| `✗ N` (red) | The last command failed with exit code N. Hidden on success. |
| `+N` | N staged files. |
| `~N` | N modified, unstaged files. |
| `?N` | N untracked files. |
| `📦N` | N stashes. |
| `↑N` | N commits to push. |
| `↓N` | N commits to pull. |
| `✓` | Clean working tree. |

The git status is cached for 2 seconds to keep large repositories fast.

## Commands

| Command | What it does |
| :--- | :--- |
| `claude` | Starts Claude Code with the tokens of `~/.config/tokens/*.env` loaded into that process only (sub-shell and `exec`). |
| `ghp ...` / `ghz ...` | Runs `gh` with the personal or the organization token, for one command. |
| `tokens` | Lists the secrets with the days left before expiry (red under 15 days, yellow under 31). |
| `store-token NAME` | Stores a secret read silently into `~/.config/tokens/NAME.env`. |
| `maj` | Updates Debian (apt) and the global npm tools. |
| `mkcd`, `extract`, `psg`, `serve`, `myip` | Small helpers. |
| `vps`, `vps-clear` | SSH to the host `vps` of `~/.ssh/config`, forget its known_hosts entry. |
| `reload` | Restarts the shell (`exec bash`). |

Shell options: `autocd` (type a directory to enter it), `cdspell` (fixes small `cd` typos), `globstar` (`**` matches recursively). The Up and Down arrows search the history for what is already typed. The history is written after every command, so terminals share it.

## Secrets

- Each secret is one file `~/.config/tokens/<NAME>.env` (mode 600, directory mode 700), created with `store-token`. Only `claude`, `ghp` and `ghz` load them, for the duration of the command.
- `~/.config/tokens/expiry.list` holds `NAME YYYY-MM-DD description` lines. At shell start, a single line is printed when something expires within 14 days. `tokens` shows the full list.
- `scripts/check-secrets.sh` blocks a commit that contains a known token format, a private key header or a hard-coded password assignment. It only warns about public IPv4 addresses. Run it on the whole repository with `scripts/check-secrets.sh --all`.
- Tokens are created with an expiry (90 days to 1 year): the list above reminds the date.

## Node

Node.js is the system package from NodeSource (current LTS), kept up to date by `maj`. Global npm tools install in `~/.local` (`prefix` in `~/.npmrc`), so neither `sudo` nor a version manager is involved. `~/.npmrc` also sets `fund=false` and `update-notifier=false` to keep the output quiet.

## Uninstall

Remove the links (`~/.bashrc`, `~/.bashrc.d`, `~/.local/bin/store-token`) and move back the `*.bak-<date>` files that `install.sh` created. Nothing else is touched.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md). Security reports: [SECURITY.md](SECURITY.md).

## License

MIT, see [LICENSE](LICENSE).

[ci]: https://github.com/Stanislas-Poisson/dotfiles/actions/workflows/ci.yml
[ci-badge]: https://github.com/Stanislas-Poisson/dotfiles/actions/workflows/ci.yml/badge.svg
[license]: LICENSE
[license-badge]: https://img.shields.io/github/license/Stanislas-Poisson/dotfiles

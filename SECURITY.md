# Security Policy

## Reporting vulnerabilities

| Channel | Description | Contact / Link |
| :--- | :--- | :--- |
| **Private report** | Preferred channel for sensitive reports. | [Report a vulnerability][advisories] |
| **Issues** | Non-sensitive problems. | [Open an issue][issues] |
| **Email** | Alternative contact. | `security@the-white-rabbits.fr` |

Please **do not disclose a vulnerability publicly** until it has been reviewed and fixed.

---

## Supported versions

| Version | Supported |
| :--- | :--- |
| `main` | Yes |

There are no releases: only the latest commit of `main` receives fixes.

---

## Scope

- dotfiles is a shell setup: its files run in the shell of the person who installs them, and `install.sh` and `bin/store-token` write in the home directory.
- Report any way to make a file of this repository leak a token, run a command that was not asked for when the shell starts, or store a secret with permissions wider than the owner only.
- A missing feature, a wrong alias or a prompt that looks different is not a vulnerability: open an issue.
- No secret is stored in this repository. If you find something that looks like one, report it privately: it is a mistake.

[advisories]: https://github.com/Stanislas-Poisson/dotfiles/security/advisories/new
[issues]: https://github.com/Stanislas-Poisson/dotfiles/issues

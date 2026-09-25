# MetaDesk

One window for your Meta services — WhatsApp, Instagram, and Facebook — as a
lightweight native desktop wrapper (WebView2 on Windows).

> **Upstream credit:** MetaDesk is a rebranded extension of
> [vianziro/Whatsapp-Dekstop](https://github.com/vianziro/Whatsapp-Dekstop),
> used under the MIT license. All original copyright notices are retained in
> [LICENSE](./LICENSE).

## Services

| # | Service | URL | Shortcut |
|---|---------|-----|----------|
| 1 | WhatsApp | `https://web.whatsapp.com` | `Ctrl+1` (`Cmd+1` on macOS) |
| 2 | Instagram | `https://www.instagram.com` | `Ctrl+2` (`Cmd+2` on macOS) |
| 3 | Facebook (full site) | `https://www.facebook.com` | `Ctrl+3` (`Cmd+3` on macOS) |

Switch via the 48px dock rail on the left edge or the keyboard shortcuts.
Switching navigates inside the **same window** — one session per service, one
Meta ecosystem in one window. There is intentionally **no multi-account**
support: each service holds a single login in the shared profile.

## Windows-first

Primary target is Windows 10/11 (x64) with WebView2 (ships with Windows 11,
present on virtually all current Windows 10 machines).

- Portable: `MetaDesk.exe`
- Zip: `MetaDesk-Windows-x64.zip`
- Installer (per-user, no admin): `MetaDesk-Windows-x64-Setup.exe`

```bash
# Windows binary (v1.0.0 example)
bash build_windows.sh 1.0.0
# Full installer (requires makensis)
bash build_windows_installer.sh 1.0.0
```

Tagged `v*` pushes build Windows automatically via
[`.github/workflows/windows.yml`](.github/workflows/windows.yml) and attach
artifacts to the GitHub release.

## Development

```bash
go build ./...
GOOS=windows CGO_ENABLED=0 go build -o /dev/null .
go vet ./...
go test ./...
```

## Disclaimer

MetaDesk is an independent project and is **not affiliated with, endorsed by,
or sponsored by Meta Platforms, Inc.** WhatsApp, Instagram, and Facebook are
trademarks of their respective owners. Log in only on machines you trust.

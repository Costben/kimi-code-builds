# AGENTS.md

Conventions for this repository. Read this before changing anything here.

## What this repo is

Patched native builds of [Kimi Code](https://github.com/MoonshotAI/kimi-code),
published as Releases. The repo stores only workflows, one apply script and the
patches; upstream source is checked out fresh in CI for every run.

| patch | 作用 |
| --- | --- |
| `kimi-code-acp-steering.patch` | `kimi acp` 新增 `_session/steering`，并在 `initialize` 的 `_meta.steering.supported` 中声明；回合运行中把输入注入该回合（与 TUI 的 Ctrl+S 同一路径），无回合时返回 `unconsumed` 由客户端改发 `session/prompt` |
| `kimi-code-update-feed.patch` | 应用内更新（`latest` / `latest.json` / `canary.json` / `manifest.json` / `.zst`）改为读取本仓库的 Release；插件市场、rg、fd 等仍走官方 CDN |

Upstream tracking issue for the steering half: MoonshotAI/kimi-code#2370. Once
upstream ships an equivalent, drop `kimi-code-acp-steering.patch`.

## This repo is edited on the remote only

`main` on GitHub is the single working copy.

- Do not keep a local checkout. Read with `gh api repos/Costben/kimi-code-builds/contents/<path>`,
  write with the contents API or the git data API. **A git data API tree must pass
  `base_tree`** (the current `main` tree), or the commit drops every other file.
- Refreshing a patch needs an editable upstream tree: clone the upstream tag into a
  throwaway directory under `$TMPDIR`, apply the series, fix, regenerate with
  `git diff` (new files `git add -N` first), and delete the directory afterwards.
- Never `pnpm install`, build or test on a laptop. `patch-verify.yml` does that.

## Pre-flight and verification are CI

```bash
# Patch refresh: apply + build packages + typecheck + the touched tests
gh workflow run patch-verify.yml --repo Costben/kimi-code-builds \
  -f tag=@moonshot-ai/kimi-code@2.4.0

# Patch-only rebuild of a version that is already published
gh workflow run build.yml --repo Costben/kimi-code-builds \
  -f tag=@moonshot-ai/kimi-code@2.4.0 -f force=true
```

- `upstream-release-watch.yml` polls every 30 minutes and dispatches `build.yml`
  for a new stable upstream release. Do not dispatch new versions by hand.
- `build.yml` runs `patch-verify.yml` first; the native matrix only starts when it
  is green. Targets: `darwin-arm64`, `win32-x64`, `linux-x64`.
- The Release keeps upstream's version number. A patch-only rebuild (`force=true`)
  does not bump it, so installed clients do not see it as an update: reinstall by
  hand (see README).

## Commits

Conventional Commits, subject in Chinese, imperative, no trailing period.

| scope | 用途 |
| --- | --- |
| `acp` | ACP 补丁 |
| `update` | 更新源补丁 |
| `patches` | 补丁结构与 apply 脚本 |
| `ci` | workflow |

No attribution lines: no `Co-Authored-By`, no `Generated with`, no emoji.

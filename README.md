# kimi-code-builds

[Kimi Code](https://github.com/MoonshotAI/kimi-code) 的补丁版原生构建。每个上游稳定版发布后约 30 分钟内自动构建，版本号与上游一致。

## 与官方版的区别

- **ACP 支持引导**：`kimi acp` 新增 `_session/steering`，并在 `initialize` 响应里声明 `_meta.steering.supported: true`。客户端（如 Paseo）可以在回合运行中把消息插进当前回合，效果与 TUI 的 Ctrl+S 一致。接口沿用 `claude-agent-acp` / `codex-acp` 的写法。
  - 返回 `injected`：已并入当前回合
  - 返回 `unconsumed`：当前没有由客户端发起的回合，内容未被使用，请改用 `session/prompt` 发送
  - 返回 `startedNewTurn`：回合恰好在送达前结束，引擎把这条消息作为新回合启动，没有 `session/prompt` 请求负责这个回合
- **AskUserQuestion 表单**：`kimi acp` 在 `session/request_permission` 的 `_meta.questions` 里下发完整题目（选项、多选、允许自由输入），并从 `_meta.answers` 读回答案。Paseo 这类客户端会渲染成带输入框的问题卡；不认识 `_meta` 的客户端行为不变，仍然只看到选项按钮。
- **更新源**：`kimi upgrade` 和自动更新从本仓库的 Release 获取，不会被官方版覆盖回去。插件市场、rg、fd 仍然走官方 CDN。

上游需求：[MoonshotAI/kimi-code#2370](https://github.com/MoonshotAI/kimi-code/issues/2370)。上游合入后，ACP 引导补丁会撤掉。

## 平台

`darwin-arm64`、`win32-x64`、`linux-x64`。macOS 版只有 ad-hoc 签名，没有公证。

## 首次安装

替换官方安装位置里的可执行文件；之后的更新会自动从这里拉取。

macOS（Apple Silicon）：

```bash
cp ~/.kimi-code/bin/kimi ~/.kimi-code/bin/kimi.official.bak
curl -fL https://github.com/Costben/kimi-code-builds/releases/latest/download/kimi-code-darwin-arm64.tar.gz \
  | tar -xz -C ~/.kimi-code/bin kimi
xattr -d com.apple.quarantine ~/.kimi-code/bin/kimi 2>/dev/null || true
kimi -V
```

Windows（PowerShell）：

```powershell
$bin = "$env:USERPROFILE\.kimi-code\bin"
Copy-Item "$bin\kimi.exe" "$bin\kimi.official.bak.exe"
$zip = "$env:TEMP\kimi-code-win32-x64.zip"
Invoke-WebRequest https://github.com/Costben/kimi-code-builds/releases/latest/download/kimi-code-win32-x64.zip -OutFile $zip
Expand-Archive $zip -DestinationPath $bin -Force
kimi -V
```

补丁重建（版本号不变）不会被当成更新，需要按上面的步骤重新安装一次。

## 回到官方版

把 `kimi.official.bak` 拷回 `kimi`（Windows 为 `kimi.exe`），或重新运行官方安装脚本。

## 维护

见 [AGENTS.md](AGENTS.md)。

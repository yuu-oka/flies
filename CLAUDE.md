# プロジェクトルール

## 公開フロー
「公開して」「pushして」などの指示があった場合、以下の手順で進める:
1. project.godotのPlugins設定でGodot MCPが有効になっている場合、
   エクスポート・コミット前に必ずaddons/godot_mcpとMCP用autoload登録を除外する
2. ヘッドレスエクスポート: godot --headless --path <このプロジェクトのパス> --export-release "Web" web-build/index.html
3. commit & push

## Godot操作の注意
- Godotエディタは事前に起動しておくこと(godot-mcp接続の前提)
- 日本語表示にはNoto Sans JP等の日本語フォントが必要
- WSLg特有の問題: エディタ起動時は --display-driver x11 を付ける

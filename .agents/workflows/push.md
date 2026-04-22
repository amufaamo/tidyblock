---
description: Commit all changes and push to GitHub
---
// turbo-all

## 方法1: Windows PowerShell（推奨）

ユーザーが **PowerShell** または **コマンドプロンプト** で以下を実行:

```powershell
cd "G:\マイドライブ\void_shiny"
git add -A
git commit -m "UPDATE_MESSAGE_HERE"
git push origin main
```

`UPDATE_MESSAGE_HERE` を変更内容の説明に置き換えてください。

## 方法2: run_app.bat と同じフォルダにあるバッチファイルを使用

`push.bat` をダブルクリックで実行（メッセージ入力を求められます）。

## コミットメッセージ命名規則

| プレフィックス | 用途 | 例 |
|---|---|---|
| `feat:` | 新機能 | `feat: add plot merging functionality` |
| `fix:` | バグ修正 | `fix: correct filter modal crash` |
| `docs:` | ドキュメント | `docs: update README for JOSS` |
| `refactor:` | リファクタ | `refactor: simplify plotTabUI labels` |
| `test:` | テスト追加 | `test: add filter operation tests` |
| `chore:` | その他 | `chore: update DESCRIPTION version` |

## 注意
- 修正するたびにcommit & pushして、JOSSが求める6ヶ月の公開開発履歴を蓄積すること。
- 投稿目標: **2026年8月15日以降**

# TidyBlock デバッグガイド

## 🐛 デバッグ機能が追加されました

Pipeline Toolのボタンが反応しない問題をデバッグしやすくするため、詳細なログ機能を追加しました。

## 📋 デバッグログの確認方法

### 1. Rコンソールでログを確認

アプリを実行すると、以下のようなデバッグメッセージがRコンソールに出力されます:

```r
# アプリ起動時
[DEBUG] ========================================
[DEBUG] TidyBlock app_server initializing...
[DEBUG] ========================================
[DEBUG] Reactive state initialized
[DEBUG] Import module server initialized
[DEBUG] Module counter initialized

# データアップロード時
[DEBUG] File input triggered
[DEBUG] File detected: iris.csv
[DEBUG] Dataset name: iris
[DEBUG] CSV read successfully, rows: 150, cols: 5
[DEBUG] Dataset added to state$datasets
[DEBUG] Set as active dataset: iris
[DEBUG] File import completed successfully

# デモデータ読み込み時
[DEBUG] Demo data button clicked
[DEBUG] Iris dataset loaded successfully
[DEBUG] state$raw_data set: TRUE
[DEBUG] state$active_dataset: iris

# Pipeline Toolボタンをクリックした時
[DEBUG] Filter button clicked
[DEBUG] Creating filter module with id: filter_1
[DEBUG] Filter UI inserted for id: filter_1
[DEBUG] Filter server initialized for id: filter_1
```

### 2. エラーメッセージの確認

エラーが発生した場合、以下のような詳細なエラーメッセージが表示されます:

```r
[ERROR] Failed to add filter module: <エラーの詳細>
```

また、アプリ内にも赤いエラー通知が表示されます。

## 🔍 問題の特定方法

### ボタンが反応しない場合の確認手順

1. **アプリを起動**
   ```r
   shiny::runApp()
   ```

2. **Rコンソールで初期化メッセージを確認**
   - `[DEBUG] TidyBlock app_server initializing...` が表示されるか確認
   - エラーメッセージが出ていないか確認

3. **データをアップロードまたはデモデータを読み込み**
   - `[DEBUG] Demo data button clicked` または `[DEBUG] File input triggered` が表示されるか確認
   - `[DEBUG] state$raw_data set: TRUE` が表示されるか確認

4. **Pipeline Toolボタンをクリック**
   - 例: Filterボタンをクリック
   - `[DEBUG] Filter button clicked` が表示されるか確認

5. **ログから問題を特定**

   **ケース1: ボタンをクリックしても何も表示されない**
   - → ボタンのイベントハンドラが動作していない可能性
   - → ブラウザのJavaScriptコンソールも確認してください

   **ケース2: `[DEBUG] XXX button clicked` は表示されるが、その後にエラーが出る**
   - → エラーメッセージから原因を特定
   - → モジュールのUIまたはサーバー関数に問題がある可能性

   **ケース3: データ読み込みのログが出ない**
   - → `state$raw_data` が正しく設定されていない
   - → データのアップロードまたは読み込みに失敗している

## 🛠️ よくある問題と解決方法

### 問題1: ボタンをクリックしても `[DEBUG]` メッセージが出ない

**原因**: アプリのJavaScript側で問題が発生している可能性

**対処法**:
1. ブラウザのデベロッパーツールを開く (F12キー)
2. Consoleタブでエラーがないか確認
3. アプリをリロード (Ctrl+R / Cmd+R)

### 問題2: `[ERROR] Failed to add XXX module` が表示される

**原因**: モジュールの初期化中にエラーが発生

**対処法**:
1. エラーメッセージの詳細を確認
2. 該当するモジュールファイル (`mod_filter.R` など) のコードをチェック
3. 必要なパッケージがインストールされているか確認

### 問題3: データを読み込んでもボタンが反応しない

**原因**: `state$raw_data` が正しく設定されていない

**対処法**:
1. デモデータボタンをクリックして `[DEBUG] state$raw_data set: TRUE` が表示されるか確認
2. 表示されない場合は `mod_import.R` のコードに問題がある可能性

## 📝 デバッグログを無効にする

本番環境では、デバッグログを無効にすることを推奨します。

以下のコードを各ファイルの先頭に追加:

```r
DEBUG_MODE <- FALSE

# message()の代わりに使用する関数
debug_msg <- function(...) {
  if (DEBUG_MODE) message(...)
}
```

そして、`message("[DEBUG] ...")` を `debug_msg("[DEBUG] ...")` に置き換えてください。

## 🚀 次のステップ

1. アプリを起動してログを確認
2. Irisデータをアップロードまたはデモデータを読み込み
3. Pipeline Toolボタンをクリック
4. Rコンソールのログから問題を特定
5. 必要に応じて各モジュールのコードをチェック

---

**作成日**: 2026-02-14  
**バージョン**: 1.0

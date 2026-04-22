# **プロジェクト計画書: TidyBlock (Tidyverse GUI Implementation)**

**～ R Shiny x rhandsontable: ノンプログラマーのためのスプレッドシート型データ分析プラットフォーム ～**

## **1\. プロジェクト概要 (Project Overview)**

* **Goal:** Rを使えないプログラミング未経験者が、Tidyverse・ggplot2の**全機能**をGUI操作だけで利用できるアプリケーションを開発する。操作感はExcelのように直感的なスプレッドシート型とし、コードを一切書かずにデータ整形・集計・可視化の全工程を完結できることを目指す。
* **Target Journal:** **JOSS (Journal of Open Source Software)** — 論文の投稿から\*\*出版（Publication）\*\*まで完遂することを目標とする。
* **Core Value:**
  1. **Excel-like Intuitive Operation:** Rの知識ゼロでも使えるスプレッドシートUIを最優先とし、セル編集・右クリックメニュー・モーダルダイアログによる完全GUI操作を実現する。
  2. **Full Tidyverse Coverage:** dplyr・tidyr・ggplot2・stringr・forcats・lubridateを網羅し、Tidyverseエコシステムの全主要機能をGUIから利用可能にする。
  3. **Modern UX:** bslib と rhandsontable を駆使した、デスクトップアプリのような滑らかな操作感。
  4. **Reproducibility:** Conda環境とRパッケージ構造による完全な再現性。

## **2\. 開発環境 (Environment)**

* **Virtual Environment:** **Conda (Void / Clean Env)**
* **Environment File (environment.yml):**
* YAML

name: void  
channels:

* conda-forge
* nodefaultsdependencies:
* r-base >= 4.3.0
* r-shiny
* r-bslib # UI Framework (Zephyr theme)
* r-tidyverse # Core logic
* r-rlang # Metaprogramming
* r-dt # Data Tables
* r-rhandsontable # Excel-like Data Tables
* r-shinyjqui # Popups / Interactions
* r-bsicons # Icons
* r-testthat # Unit Testing
* r-roxygen2 # Documentation
* r-usethis # Package management
* r-devtools # Development tools

## **3\. UI/UX デザイン仕様 (Modern Interactions)**

**重要: パネル操作の「モダンさ」と「スプレッドシートとしての使いやすさ」を最優先する。**

* **Layout Strategy (bslib::page\_fillable):**
  * **Top Bar:** メニューバー (File, Edit, Data, Transform, Visualize)
  * **Toolbar:** ショートカットアイコン (Undo, Save, Filter, Mutate, Summariseなど)
  * **Main Canvas (Spread Area):** `rhandsontable` によるスプレッドシート画面。複数データセットはタブ (`navset_tab`) で管理し、画面全体を無駄なく使う。
* **Table Interactions:**
  * セルの直接編集
  * カラムや行のドラッグ＆ドロップ移動・リサイズ
  * コンテキストメニュー（右クリック）からのDplyr操作（Arrange, Filter, Mutateなど）起動

## **4\. アプリケーション・ロジック (Logic & State)**

* **Reactive State:** `rv <- reactiveValues(datasets = list(), history = list(), action_log = list(), selected_cols = list())`
* **Dataset Management:** 個々のデータセットは独立したタブとして管理され、変換（Summariseなど）の結果は「新しいタブ（新規データセット）」として開く。
* **History Management:** 各タブごとに操作履歴（Undo用）をリスト形式で保持する。

---

## **5\. 実行プロンプト集 (Execution Prompts for AI)**

**開発者は以下のプロンプトを順番にAIにコピー＆ペーストして指示を出すこと。**

### **➤ Phase 1: Setup & Foundation (土台構築)**

**指示:**

プロジェクト計画書の **Phase 1** を実行してください。

1. **環境構築:** 標準的なRパッケージ構造と `environment.yml` のセットアップ。
2. **アーキテクチャ:** 単一ファイル `app.R` をベースにしたスプレッドシート型UIを作成します。bslibの `page_fillable` を使用し、トップにメニューバーとツールバーを配置してください。
3. **基本機能:**
  * メニューバーからの「File > Upload」でCSV等を取り込む機能（タブとして新規追加）。
  * `rhandsontable` を用いたスプレッドシートの表示機能。

### **➤ Phase 2: Core Wrangling & UX (主要機能と操作性)**

**指示:**

**Phase 2** の実装を行います。ここがUXの肝です。

1. **メニューとツールバーの設定:** DataやTransformメニューから `Arrange`, `Filter`, `Mutate`, `Summarise` が呼び出せるようにする。
2. **モーダルUI:** 各操作はポップアップ（モーダルダイアログ）でパラメータを設定するようにする。
3. **Arrange & HandsonContextMenu:** 右クリックメニューから並べ替えなどを実行できるようにする。
4. **Summariseの非破壊的動作:** Summariseなどデータ構造が大きく変わる操作の結果は、元データを書き換えるのではなく「新規タブ」として別データセットで表示する。

### **➤ Phase 3: Advanced Features (高度機能)**

**指示:**

**Phase 3** の実装です。論文のユースケースに対応できる高度な機能を拡充します。

1. **プロット機能 (Plot Layer Builder):**
  * データから新規に「Plot\_XXX」というグラフ専用タブ（nav\_panel）を作成して独立した環境を提供する。
  * **Side-by-side UI (UIレイアウト):** 新規作成されたグラフ専用タブの内部は、\*\*「左側にLayer Builder等の操作パネル、右側にプロットの表示領域」\*\*という画面分割レイアウト (`layout_sidebar` 等) を採用する。
  * **データ範囲の指定:** 対象データとして「データポイント全体を使う（Use entire dataset）」か「現在ハイライト中のセルだけを使う（Use selected cells only）」かを選択できる。
  * **Layer Builder (左側パネル):** 左側の操作パネルで「+ Add Layer」ボタンを押し、グラフ（散布図、棒グラフ、折れ線など）を多層に重ねながら、右側のプロットをリアルタイムに更新していくエクセル風・直感的な操作を実現する。
2. **Joinの実装 (Join Modal):**
  * Transformメニューに「Join」を追加。現在開いているタブのデータをLeft、他のタブのデータをRightとして結合し、新規タブとして結果を出力する。
3. **Mutateの強化:**
  * 既存の Mutate モーダルに、文字列処理（`stringr`）、因子処理（`forcats`）、および日付・時間処理（`lubridate`）など高度な変換を補助するテンプレート選択機能（Helper UI）を追加する。
4. **Tidyrによるデータ変形 (Reshaping):**
  * Transformメニューに「Pivot Longer (縦持ちへ)」および「Pivot Wider (横持ちへ)」を追加。スプレッドシート間で重宝される構造変換を専用モーダルで直感的に実行可能にする。
5. **高度なデータ操作 (Advanced Wrangling):**
  * 直接編集では困難な巨大データの列をさばくための「Select / Rename (列の選択とリネーム) UI」の実装。
  * 前処理として不可欠な重複行の削除（`distinct`）機能の実装。

### **➤ Phase 4: ggplot2 Aesthetics & Geoms (Geom/Aes層の完全実装)**

**指示:**

**Phase 4** の実装です。`report_ggplot2.md` で定義されたマッピングと幾何的オブジェクトを網羅します。

1. **Aesthetics (美的マッピング) の拡張:**
  * x, y, colour, fill, alpha, size, shape, linetype, group の全属性をUIからマッピング可能にする。
  * 遅延評価パイプライン (`after_stat()`, `after_scale()`) をUIから指定できる機能（高度なマッピングモード）を実装。
2. **Geoms (幾何的オブジェクト) の完全網羅:**
  * **1次元連続分布:** `geom_point`, `geom_line`, `geom_histogram`, `geom_density`, `geom_dotplot` など。
  * **2変数・多変数の関係性:** `geom_boxplot`, `geom_violin`, `geom_jitter`, `geom_col`, `geom_bin_2d` など。
  * **不確実性・統計モデリング:** `geom_errorbar`, `geom_smooth`, `geom_ribbon`, `geom_qq` など。
  * **注釈・特殊レイヤー:** `geom_text` / `geom_label` (必須となる `label` 引数の入力UI)、`geom_hline` / `geom_vline` (基準線となる `yintercept` / `xintercept` の入力UIなど)、特殊レイヤーとその専用引数設定UIの完全実装。

### **➤ Phase 5: ggplot2 Stats, Scales & Coordinates (統計変換・スケール・座標系)**

**指示:**

**Phase 5** の実装です。描画の背後にある計算エンジンと次元・空間の制御機能をUIに統合します。

1. **Stats (統計的変換):**
  * 各Geomに対して明示的にStat（`stat_identity`, `stat_count`, `stat_summary`, `stat_boxplot`など）をオーバーライド設定する拡張メニュー。
2. **Scales (スケール) & Guides:**
  * 位置スケールの制御（`scale_x_continuous` 等における、`limits` による厳密な描画範囲の制限設定や、`scales::oob_squish` 等を用いた範囲外データの処理ルール設定 UI）。
  * カラースケールの体系的選択 UI（Brewer, Viridis, Gradient パレット）。
  * ガイド（凡例やカラーバー）の振る舞いを制御するUI。
3. **Coordinate Systems (座標系):**
  * 直交座標系 (`coord_cartesian`), アスペクト比固定 (`coord_fixed`), 非線形空間変換 (`coord_trans`)。
  * 新世代極座標系モジュール (`coord_radial`, `coord_polar`) の統合オプション。

### **➤ Phase 6: ggplot2 Facets & Themes (ファセットとテーマの統合)**

**指示:**

**Phase 6** の実装です。プロットの構造分割と非データインク（デザイン）を最適化します。

1. **Faceting (ファセット):**
  * `facet_wrap` と `facet_grid` によるスモール・マルチプル作成パネル。
  * パネルごとの軸スケール独立化（`scales = "free"` 等）設定。
2. **Themes (テーマ):**
  * 組み込みテーマ（`theme_bw`, `theme_minimal`, `theme_classic`, `theme_void` など）の一括適用。
  * 凡例（Legend）の配置変更（bottom, top, none等）オプションの追加。
  * `theme()` を用いた要素レベルのカスタマイズ（`element_text`, `element_line`, `element_rect`）による非データインク制御（背景色やグリッド線の有無など）の完全なGUI化。
  * v4.0アーキテクチャに準拠した `theme(geom)` などのロール指向スタイル調整へのUI対応。

### **➤ Phase 7: JOSS Polish (論文・品質保証・出版)**

**指示:**

**Phase 7** の実装です。JOSS への投稿から\*\*出版（Publication）\*\*まで完遂することを目標に最終仕上げを行います。

1. **テスト作成:** `testthat` をセットアップし、データ変換ロジックが正しく機能するかテストを作成。
2. **ドキュメント整備:** 実装したロジックに関する主要なコメント・ドキュメントを整理。
3. **CI/CD:** GitHub Actions のワークフローを作成し検証。
4. **論文ドラフト:** JOSSのガイドラインに従い、`paper.md` の下書きを作成。
5. **査読対応:** JOSS査読者からのフィードバックに対応し、論文・ソフトウェア双方を改善して**出版まで完遂**する。

---

## **6\. 機能要件: 実装するTidyverse機能一覧 (Technical Scope)**

### **Category A: 行と列の基本操作**

* **Rows:** filter, arrange, distinct (重複行削除)
* **Columns:** select (列の一括選択・除外), rename (列名設定)
* **IO:** read\_csv, read\_tsv, read\_excel

### **Category B: 変数作成と変換**

* **Core:** mutate (四則演算)
* **Helpers:** str\_detect, str\_replace (Stringr), fct\_reorder (Forcats), case\_when, lubridate (日付処理)

### **Category C: 構造変換と集計**

* **Reshaping:** pivot\_longer, pivot\_wider (結果は別タブ出力)
* **Aggregation:** group\_by, summarise (結果は別タブ出力)
* **Joins:** left\_join, inner\_join

### **Category D: Data Visualization (ggplot2 System)**

* **Geoms & Aesthetics:** グローバル/レイヤーごとのx, y, colour, fill等フルマッピング、after\_stat/after\_scale遅延評価、1次元/2次元/不確実性/注釈を含む全基本Geom網羅。
* **Stats & Scales:** 各種統計変換(Stat)の明示的指定、Brewer/Viridis/Gradient等の各種カラースケール・位置スケールの制御、Guides(凡例)詳細設定。
* **Coords & Facets:** 直交・極座標(coord\_radial)等の座標系操作、facet\_wrap/facet\_gridによる分割描画。
* **Themes:** 組み込みテーマ(theme\_minimal等)の適用と、element\_text等の非データインク詳細制御。
* **Output:** スプレッドシートUIからの直感的なLayer Builder操作およびプロット専用タブでの全画面表示。

---

## **7\. JOSS投稿準備 — 適格性評価 & アクションプラン**

### **7.1. JOSSとは**

**Journal of Open Source Software (JOSS)** は、研究ソフトウェアの査読付きオープンアクセスジャーナルである。

* 投稿料なし。論文は750〜1750語の短い形式。
* GitHubのIssue上で公開査読が行われる。
* 査読基準: ソフトウェアの機能・テスト・ドキュメント・コミュニティ貢献。
* **Web-basedツールの重要注意:** R/Shinyアプリは「コアライブラリをWeb経由で公開する」形態として **スコープ内** と明記されている。

### **7.2. 適格性チェックリスト**

| #   | JOSS要件                 | 現状                               | 対応状況          |
| --- | ------------------------ | ---------------------------------- | ----------------- |
| 1   | OSI承認ライセンス        | MIT License ✅                      | ☑ OK              |
| 2   | 公開GitHubリポジトリ     | github.com/amufaamo/tidyblock ✅    | ☑ OK              |
| 3   | 明確な研究応用           | 実証研究のデータ分析ワークフロー ✅ | ☑ OK              |
| 4   | paper.md + paper.bib     | 存在する ✅                         | ☑ OK (要リライト) |
| 5   | 機能完成（半完成品はNG） | 全主要機能実装済み ✅               | ☑ OK              |
| 6   | テストスイート           | `tests/` に testthat あり ✅        | ⚠️ 要拡充          |
| 7   | ドキュメント (README)    | README.md あり ✅                   | ⚠️ 要更新          |
| 8   | CONTRIBUTING.md          | **未作成** ❌                       | ☐ 要作成          |
| 9   | 6ヶ月以上の公開開発履歴  | **確認要** ⚠️                       | ☐ 要確認          |
| 10  | AI Usage Disclosure      | paper.mdに記載あり ✅               | ☑ OK (要詳細化)   |

### **7.3. paper.md の必須セクション（JOSS最新要件）**

JOSSは以下の **6セクション** を必須としている（2025年更新）:

| #   | 必須セクション                | 現paper.md | 状態                                           |
| --- | ----------------------------- | ---------- | ---------------------------------------------- |
| 1   | **Summary**                   | ✅ あり     | ☑ OK                                           |
| 2   | **Statement of Need**         | ✅ あり     | ☑ OK                                           |
| 3   | **State of the Field**        | ✅ あり     | ☑ OK                                           |
| 4   | **Software Design**           | ✅ あり     | ⚠️ 要修正（モジュール構成の記述が実際と異なる） |
| 5   | **Research Impact Statement** | ✅ あり     | ⚠️ 要強化（具体的なエビデンスを追加）           |
| 6   | **AI Usage Disclosure**       | ✅ あり     | ⚠️ 要詳細化（ツール名・バージョン・使用範囲）   |

### **7.4. 判定結果**

> **✅ TidyBlockはJOSSに投稿可能である。**
> 
>
> 
> R/ShinyアプリはJOSSのスコープ内と明記されている。MIT License、GitHub公開リポジトリ、テスト、  
> ドキュメントの基本要件を満たしている。投稿前に以下の修正を行えば査読準備完了となる。

### **7.5. アクションプラン（実施順序）**

| Step | タスク                     | 詳細                                                                                               | 状態 |
| ---- | -------------------------- | -------------------------------------------------------------------------------------------------- | ---- |
| 1    | **paper.md のリライト**    | 最新JOSS要件に完全準拠。Software Design節は実際のアーキテクチャに合わせ修正。AI Disclosure詳細化。 | ☑    |
| 2    | **paper.bib の確認・補完** | 引用キーが全て正しいか確認。bslib引用追加。                                                        | ☑    |
| 3    | **CONTRIBUTING.md 作成**   | JOSS査読で必須のコミュニティガイドライン                                                           | ☑    |
| 4    | **README.md 更新**         | R特有用語削除の反映、最新機能リスト更新                                                            | ☑    |
| 5    | **DESCRIPTION 更新**       | Authors@R にORCID付き著者情報追加                                                                  | ☑    |
| 6    | **GitHub Actions確認**     | CI/CDワークフローが正しく動作することを確認                                                        | ☑    |

### **7.6. JOSS投稿タイムライン**

JOSSは投稿前に **6ヶ月以上の公開開発履歴** を求めている。

| 項目             | 日付                  |
| ---------------- | --------------------- |
| リポジトリ公開日 | **2026年2月15日**     |
| 6ヶ月到達日      | **2026年8月15日**     |
| 投稿可能最短日   | **2026年8月15日以降** |

### **7.7. 投稿までの開発ロードマップ**

6ヶ月の公開開発履歴を蓄積するため、以下を継続的に実施する:

| 期間                                                                           | タスク                                                       |
| ------------------------------------------------------------------------------ | ------------------------------------------------------------ |
| 3月〜4月                                                                       | 機能改善の継続（UI改善、エラーハンドリング強化）、テスト拡充 |
| 4月〜5月                                                                       | v0.2.0 リリース、GitHub Issuesにバグ・機能リクエスト記録     |
| 5月〜6月                                                                       | 外部ユーザーテスト実施、フィードバック対応                   |
| 6月〜7月                                                                       | v1.0.0 リリース、ドキュメント最終整理                        |
| 8月                                                                            | paper.md 最終確認 → **JOSS投稿**                             |
| `                                                                              |                                                              |
| **重要**: 修正を行うたびにGitHub に commit & push して開発履歴を蓄積すること。 |                                                              |
| 自動 commit-push ワークフローを `.agents/workflows/push.md` に定義済み。       |                                                              |

---`

---

## **8\. 未実装・改善バックログ (Future Improvements)**

*2026-03-21 記録*

| #   | 機能                                  | 詳細                                                                                                                                                                                                                                                                                               |
| --- | ------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 1   | Mutate のカラム名補完                 | 数式入力フィールドで既存カラム名を予測・補完入力できるようにする                                                                                                                                                                                                                                   |
| 2   | **Plot のデータフレーム変更自動反映** | 元データにカラムが増えた場合など、既存 Plot タブの Data Mapping ドロップダウンに自動で反映されない問題を修正する                                                                                                                                                                                   |
| 3   | **エラーバーのワークフロー改善**      | 現在の手順（Summarize×2 → Join → Mutate で ymin/ymax 作成 → Plot）が煩雑。Excel 並みの操作感を目指す。現ワークフロー: (1) Summarize → Average タブ + S.D. タブ取得, (2) Join で結合, (3) Mutate で mean-sd / mean+sd 列を作成, (4) Plot で Bar Chart + Error Bar レイヤーに ymin/ymax をマッピング |
| 4   | **Plot の列選択をアルファベット順に** | Data Mapping のドロップダウンがカラム出現順になっているため ABC 順に並べ替える                                                                                                                                                                                                                     |
| 5   | **タブ名の変更機能**                  | データセットタブ・プロットタブの名前をダブルクリックなどで変更できるようにする                                                                                                                                                                                                                     |
| 6   | **コマンドヒストリーの表示**          | R StudioのHistoryペインのように、実際に実行されたTidyverse等のコマンドを履歴として新しいタブ等に表示し、AIへの質問や学習に役立てられるようにする                                                                                                                                                   |

---

## **7\. UI用語の一般化 (R-specific → User-friendly Rename Map)**

**目的:** 一般ユーザーが直感的に理解できるよう、R/ggplot2/dplyr特有の関数名・用語をUIから排除する。

### **A. Plot Builder — Geom 選択肢（ドロップダウン）**

| #   | 現在の表記 (R特有) | 変更後 (一般向け) | 状態 |
| --- | ------------------ | ----------------- | ---- |　  
| A1 | `geom_point` | Scatter (Points) | ☑ |  
| A2 | `geom_line` | Line | ☑ |  
| A3 | `geom_histogram` | Histogram | ☑ |　  
| A4 | `geom_density` | Density Curve | ☑ |  
| A5 | `geom_dotplot` | Dot Plot | ☑ |  
| A6 | `geom_boxplot` | Box Plot | ☑ |  
| A7 | `geom_violin` | Violin Plot | ☑ |  
| A8 | `geom_jitter` | Jitter (Scattered Points) | ☑ |  
| A9 | `geom_col` | Bar Chart | ☑ |  
| A10 | `geom_bin_2d` | 2D Heatmap (Bin) | ☑ |  
| A11 | `geom_errorbar` | Error Bar | ☑ |  
| A12 | `geom_smooth` | Trend Line (Smooth) | ☑ |  
| A13 | `geom_ribbon` | Ribbon (Area Band) | ☑ |  
| A14 | `geom_qq` | Q-Q Plot | ☑ |  
| A15 | `geom_text` | Text Label | ☑ |  
| A16 | `geom_label` | Label (Boxed Text) | ☑ |  
| A17 | `geom_hline` | Horizontal Line | ☑ |  
| A18 | `geom_vline` | Vertical Line | ☑ |  
| A19 | `geom_sf` | Map (SF Geometry) | ☑ |

### **B. Plot Builder — Stat 選択肢**

| #   | 現在の表記              | 変更後                | 状態 |
| --- | ----------------------- | --------------------- | ---- |
| B1  | `identity`              | As-is (Raw Values)    | ☑    |
| B2  | `count`                 | Count                 | ☑    |
| B3  | `density`               | Density               | ☑    |
| B4  | `bin`                   | Binning               | ☑    |
| B5  | `summary`               | Summary               | ☑    |
| B6  | `boxplot`               | Box Plot Stats        | ☑    |
| B7  | 「Stat override」ラベル | Statistical Transform | ☑    |

### **C. Plot Builder — セクションタイトル・ラベル**

| #   | 現在の表記                  | 変更後                    | 状態 |
| --- | --------------------------- | ------------------------- | ---- |
| C1  | `1. Layers (Geoms & Stats)` | 1\. Chart Type & Layers   | ☑    |
| C2  | `2. Aesthetics (Aes)`       | 2\. Data Mapping          | ☑    |
| C3  | `Annotation (Static)`       | Reference Lines           | ☑    |
| C4  | `geom_hline yintercept`     | Horizontal Line (Y value) | ☑    |
| C5  | `geom_vline xintercept`     | Vertical Line (X value)   | ☑    |
| C6  | `Alpha`                     | Opacity                   | ☑    |
| C7  | `Linetype`                  | Line Style                | ☑    |
| C8  | `Label (geom_text/label)`   | Text Label Column         | ☑    |
| C9  | `Delayed / Adv. Aes`        | Advanced Mapping          | ☑    |

### **D. Plot Builder — Scales & Coordinates**

| #   | 現在の表記               | 変更後               | 状態 |
| --- | ------------------------ | -------------------- | ---- |
| D1  | `coord_cartesian`        | Standard (Cartesian) | ☑    |
| D2  | `coord_fixed`            | Fixed Aspect Ratio   | ☑    |
| D3  | `coord_polar`            | Polar                | ☑    |
| D4  | `coord_radial`           | Radial               | ☑    |
| D5  | `coord_trans`            | Transformed          | ☑    |
| D6  | `scales::censor`         | Hide (Censor)        | ☑    |
| D7  | `scales::squish`         | Compress (Squish)    | ☑    |
| D8  | `scales::keep`           | Keep All             | ☑    |
| D9  | `scale_colour_brewer`    | Color Brewer         | ☑    |
| D10 | `scale_colour_viridis_d` | Viridis (Discrete)   | ☑    |
| D11 | `scale_colour_viridis_c` | Viridis (Continuous) | ☑    |
| D12 | `scale_colour_gradient`  | Gradient             | ☑    |

### **E. Plot Builder — Facets**

| #   | 現在の表記                            | 変更後                                    | 状態 |
| --- | ------------------------------------- | ----------------------------------------- | ---- |
| E1  | `4. Facets`                           | 4\. Split by Group (Facets)               | ☑    |
| E2  | `Facet Type`                          | Split Layout                              | ☑    |
| E3  | `facet_wrap`                          | Wrap (Flexible Grid)                      | ☑    |
| E4  | `facet_grid`                          | Grid (Row × Column)                       | ☑    |
| E5  | `Facet Var 1 (Row/Wrap)`              | Split Variable 1                          | ☑    |
| E6  | `Facet Var 2 (Col for grid)`          | Split Variable 2                          | ☑    |
| E7  | `Scales` → `free`, `free_x`, `free_y` | Independent, Independent X, Independent Y | ☑    |

### **F. Plot Builder — Themes**

| #   | 現在の表記      | 変更後          | 状態 |
| --- | --------------- | --------------- | ---- |
| F1  | `theme_minimal` | Minimal         | ☑    |
| F2  | `theme_bw`      | Black & White   | ☑    |
| F3  | `theme_classic` | Classic         | ☑    |
| F4  | `theme_light`   | Light           | ☑    |
| F5  | `theme_dark`    | Dark            | ☑    |
| F6  | `theme_void`    | Blank (No Axes) | ☑    |
| F7  | `theme_grey`    | Grey            | ☑    |

### **G. Toolbar — ボタン・メニュー表記**

| #   | 現在の表記                   | 変更後                | 状態 |
| --- | ---------------------------- | --------------------- | ---- |
| G1  | `Mutate` (ボタン / メニュー) | Add Column            | ☑    |
| G2  | `Distinct` (メニュー)        | Remove Duplicates     | ☑    |
| G3  | `Summarise` (ボタン)         | Summarize             | ☑    |
| G4  | `Pivot Longer` (メニュー)    | Unpivot (Wide → Long) | ☑    |
| G5  | `Pivot Wider` (メニュー)     | Pivot (Long → Wide)   | ☑    |

### **H. モーダルダイアログ — タイトル・ラベル**

| #   | 現在の表記                                                         | 変更後                                       | 状態 |
| --- | ------------------------------------------------------------------ | -------------------------------------------- | ---- |
| H1  | `Mutate (Compute Column)` (モーダルタイトル)                       | Add / Compute Column                         | ☑    |
| H2  | `Apply Mutate` (ボタン)                                            | Apply                                        | ☑    |
| H3  | `Apply Summarise` (ボタン)                                         | Apply                                        | ☑    |
| H4  | `Distinct (Remove Duplicated Rows)` (タイトル)                     | Remove Duplicate Rows                        | ☑    |
| H5  | `Apply Distinct` (ボタン)                                          | Apply                                        | ☑    |
| H6  | `Keep other columns (.keep_all = TRUE)`                            | Keep all other columns                       | ☑    |
| H7  | `Pivot Longer` (モーダルタイトル)                                  | Unpivot (Wide → Long)                        | ☑    |
| H8  | `names_to (New category column name)`                              | New Category Column Name                     | ☑    |
| H9  | `values_to (New value column name)`                                | New Value Column Name                        | ☑    |
| H10 | `Pivot Wider` (モーダルタイトル)                                   | Pivot (Long → Wide)                          | ☑    |
| H11 | `names_from (Column containing new names)`                         | Column for New Headers                       | ☑    |
| H12 | `values_from (Column containing new values)`                       | Column for New Values                        | ☑    |
| H13 | `Join Type` → `left_join`, `inner_join`, `right_join`, `full_join` | Left Join, Inner Join, Right Join, Full Join | ☑    |

### **I. 右クリック コンテキストメニュー**

| #   | 現在の表記              | 変更後       | 状態 |
| --- | ----------------------- | ------------ | ---- |
| I1  | `Dplyr: Arrange (Asc)`  | Sort A → Z   | ☑    |
| I2  | `Dplyr: Arrange (Desc)` | Sort Z → A   | ☑    |
| I3  | `Dplyr: Filter`         | Filter Rows  | ☑    |
| I4  | `Dplyr: Mutate`         | Add Column   | ☑    |
| I5  | `Dplyr: Join`           | Join Tables  | ☑    |
| I6  | `Visualize: Plot`       | Create Chart | ☑    |

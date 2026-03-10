# **プロジェクト計画書: TidyBlock (Tidyverse GUI Implementation)**

**～ R Shiny x rhandsontable: ノンプログラマーのためのスプレッドシート型データ分析プラットフォーム ～**

## **1. プロジェクト概要 (Project Overview)**

* **Goal:** プログラミング未経験者が、直感的なGUI操作（エクセル風・スプレッドシート型）を通じてTidyverseによるデータ整形（Wrangling）を行い、データ操作を自然に行えるアプリケーションを開発する。  
* **Target Journal:** **JOSS (Journal of Open Source Software)**  
* **Core Value:**  
  1. **Spreadsheet-like Workflow:** 使い慣れたスプレッドシートUIでのデータ操作と、背後でのTidyverse処理の統合。
  2. **Modern UX:** bslib と rhandsontable を駆使した、デスクトップアプリのような滑らかな操作感。  
  3. **Reproducibility:** Conda環境とRパッケージ構造による完全な再現性。

## **2. 開発環境 (Environment)**

* **Virtual Environment:** **Conda (Void / Clean Env)**  
* **Environment File (environment.yml):**  
* YAML

name: void
channels:
  - conda-forge
  - nodefaults
dependencies:
  - r-base >= 4.3.0
  - r-shiny
  - r-bslib       # UI Framework (Zephyr theme)
  - r-tidyverse   # Core logic
  - r-rlang       # Metaprogramming
  - r-dt          # Data Tables
  - r-rhandsontable # Excel-like Data Tables
  - r-shinyjqui   # Popups / Interactions
  - r-bsicons     # Icons
  - r-testthat    # Unit Testing
  - r-roxygen2    # Documentation
  - r-usethis     # Package management
  - r-devtools    # Development tools

## **3. UI/UX デザイン仕様 (Modern Interactions)**

**重要: パネル操作の「モダンさ」と「スプレッドシートとしての使いやすさ」を最優先する。**

* **Layout Strategy (bslib::page_fillable):**  
  * **Top Bar:** メニューバー (File, Edit, Data, Transform, Visualize) 
  * **Toolbar:** ショートカットアイコン (Undo, Save, Filter, Mutate, Summariseなど)
  * **Main Canvas (Spread Area):** `rhandsontable` によるスプレッドシート画面。複数データセットはタブ (`navset_tab`) で管理し、画面全体を無駄なく使う。
* **Table Interactions:**  
  * セルの直接編集
  * カラムや行のドラッグ＆ドロップ移動・リサイズ
  * コンテキストメニュー（右クリック）からのDplyr操作（Arrange, Filter, Mutateなど）起動

## **4. アプリケーション・ロジック (Logic & State)**

* **Reactive State:** `rv <- reactiveValues(datasets = list(), history = list(), action_log = list(), selected_cols = list())`
* **Dataset Management:** 個々のデータセットは独立したタブとして管理され、変換（Summariseなど）の結果は「新しいタブ（新規データセット）」として開く。
* **History Management:** 各タブごとに操作履歴（Undo用）をリスト形式で保持する。

---

## **5. 実行プロンプト集 (Execution Prompts for AI)**

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
   * データから新規に「Plot_XXX」というグラフ専用タブ（nav_panel）を作成して独立した環境を提供する。
   * **Side-by-side UI (UIレイアウト):** 新規作成されたグラフ専用タブの内部は、**「左側にLayer Builder等の操作パネル、右側にプロットの表示領域」**という画面分割レイアウト (`layout_sidebar` 等) を採用する。
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

### **➤ Phase 7: JOSS Polish (論文・品質保証)**

**指示:**

**Phase 7** の実装です。JOSS投稿に向けた最終仕上げを行います。

1. **テスト作成:** `testthat` をセットアップし、データ変換ロジックが正しく機能するかテストを作成。
2. **ドキュメント整備:** 実装したロジックに関する主要なコメント・ドキュメントを整理。
3. **CI/CD:** GitHub Actions のワークフローを作成し検証。
4. **論文ドラフト:** JOSSのガイドラインに従い、`paper.md` の下書きを作成。

---

## **6. 機能要件: 実装するTidyverse機能一覧 (Technical Scope)**

### **Category A: 行と列の基本操作**

* **Rows:** filter, arrange, distinct (重複行削除)
* **Columns:** select (列の一括選択・除外), rename (列名設定)
* **IO:** read_csv, read_tsv, read_excel

### **Category B: 変数作成と変換**

* **Core:** mutate (四則演算)
* **Helpers:** str_detect, str_replace (Stringr), fct_reorder (Forcats), case_when, lubridate (日付処理)

### **Category C: 構造変換と集計**

* **Reshaping:** pivot_longer, pivot_wider (結果は別タブ出力)
* **Aggregation:** group_by, summarise (結果は別タブ出力)
* **Joins:** left_join, inner_join

### **Category D: Data Visualization (ggplot2 System)**

* **Geoms & Aesthetics:** グローバル/レイヤーごとのx, y, colour, fill等フルマッピング、after_stat/after_scale遅延評価、1次元/2次元/不確実性/注釈を含む全基本Geom網羅。
* **Stats & Scales:** 各種統計変換(Stat)の明示的指定、Brewer/Viridis/Gradient等の各種カラースケール・位置スケールの制御、Guides(凡例)詳細設定。
* **Coords & Facets:** 直交・極座標(coord_radial)等の座標系操作、facet_wrap/facet_gridによる分割描画。
* **Themes:** 組み込みテーマ(theme_minimal等)の適用と、element_text等の非データインク詳細制御。
* **Output:** スプレッドシートUIからの直感的なLayer Builder操作およびプロット専用タブでの全画面表示。

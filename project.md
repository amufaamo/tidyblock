# **プロジェクト計画書: TidyBlock (Tidyverse GUI Implementation)**

**～ R Shiny x bslib: ノンプログラマーのためのノードベースデータ分析・教育プラットフォーム ～**

## **1\. プロジェクト概要 (Project Overview)**

* **Goal:** プログラミング未経験者が、直感的なGUI操作（ノードベース）を通じてTidyverseによるデータ整形（Wrangling）を行い、かつその背後にある「モダンなRコード（|\>）」を自然に習得できるアプリケーションを開発する。  
* **Target Journal:** **JOSS (Journal of Open Source Software)**  
* **Core Value:**  
  1. **Visually Integrated Workflow:** GUI操作とコード生成の完全同期。  
  2. **Modern UX:** bslib と shinyjqui を駆使した、デスクトップアプリのような滑らかな操作感。  
  3. **Reproducibility:** Conda環境とRパッケージ構造による完全な再現性。

## **2\. 開発環境 (Environment)**

* **Virtual Environment:** **Conda (Void / Clean Env)**  
* **Environment File (environment.yml):**  
* YAML

name: void

channels:

  \- conda-forge

  \- nodefaults

dependencies:

  \- r-base \>= 4.3.0

  \- r-shiny

  \- r-bslib       \# UI Framework (Zephyr theme)

  \- r-tidyverse   \# Core logic

  \- r-rlang       \# Metaprogramming

  \- r-dt          \# Data Tables

  \- r-shinyace    \# Code Editor

  \- r-shinyjqui   \# Drag & Drop interaction (Sortable & Resizable)

  \- r-bsicons     \# Icons

  \- r-testthat    \# Unit Testing

  \- r-roxygen2    \# Documentation

  \- r-usethis     \# Package management

  \- r-devtools    \# Development tools

*   
* 

## **3\. UI/UX デザイン仕様 (Modern Interactions)**

**重要: パネル操作の「モダンさ」と「自由度」を最優先する。**

* **Layout Strategy (bslib::page\_sidebar):**  
  * **Sidebar:** ツールボックス（Tidyverse関数パレット）。  
  * **Main Canvas (Pipeline Area):**  
    * **Flexible Grid:** カード（処理ブロック）は layout\_column\_wrap や flex-wrap を使用し、リサイズに応じて自動的に隙間を埋める（Masonry-like behavior）。**絶対配置（Absolute positioning）による重なりは禁止。**  
* **Card Interactions (The "TidyBlock" Feel):**  
  * **Expand (Full Screen):** すべてのカードに bslib::card(full\_screen \= TRUE) を設定し、ワンクリックで全画面化できるようにする。  
  * **Resize (Modern Drag):** shinyjqui::jqui\_resizable() を適用し、ユーザーがカードの端をドラッグしてサイズを自由に調整できるようにする。  
  * **Reorder (Sortable):** shinyjqui::jqui\_sortable() を適用し、処理順序をドラッグ＆ドロップで入れ替え可能にする。  
  * **Constraint:** リサイズ操作と並べ替え操作が干渉しないよう、並べ替えハンドルは「カードヘッダー」に限定する。

## **4\. アプリケーション・ロジック (Logic & State)**

* **Reactive State:** state \<- reactiveValues(raw\_data \= NULL, pipeline \= list())  
* **Code Generation:** rlang を用いて、各ステップ（Filter, Mutate等）の設定からTidyverseコード（Expression）を動的に生成・結合する。文字列連結（paste）は極力避ける。

---

## **5\. 実行プロンプト集 (Execution Prompts for AI)**

**開発者は以下のプロンプトを順番にAIにコピー＆ペーストして指示を出すこと。**

### **➤ Phase 1: Setup & Foundation (土台構築)**

**指示:**

プロジェクト計画書の **Phase 1** を実行してください。

1. **環境構築:** usethis::create\_package() 相当の標準的なRパッケージディレクトリ構造（R/, DESCRIPTION等）と、environment.yml を作成してください。  
2. **アーキテクチャ:** アプリのエントリーポイント app.R を作成し、UI/Serverロジックは R/app\_ui.R, R/app\_server.R に分離して記述してください。pkgload::load\_all() で起動できる構成にします。  
3. **基本機能:**  
   * bslib (Zephyr theme) を使った page\_sidebar レイアウトを作成してください。  
   * **Importモジュール (R/mod\_import.R)** を作成し、CSVアップロードと DT::datatable による表示を実装してください。  
   * まだリサイズ機能は不要ですが、各カードには full\_screen \= TRUE (Expandボタン) を必ず入れてください。

### **➤ Phase 2: Core Wrangling & UX (主要機能と操作性)**

**指示:**

**Phase 2** の実装を行います。ここがUXの肝です。

1. **Filter & Selectモジュール:** R/mod\_filter.R と R/mod\_select.R を作成し、パイプラインに追加できるようにしてください。  
2. **モダンUIの実装 (重要):**  
   * メインエリアのカード群に対し、**shinyjqui::jqui\_sortable() (並べ替え)** と **shinyjqui::jqui\_resizable() (リサイズ)** の両方を適用してください。  
   * **干渉回避:** 並べ替えは「カードのヘッダー部分 (.card-header)」でのみ反応するように options を設定してください。リサイズはカード全体で反応させます。  
   * **レイアウト:** リサイズしてもカード同士が重ならないよう、CSS (Flexbox/Grid) を適切に調整し、ドキュメントフローを維持してください。  
3. **Mutate (MVP):** 四則演算ができるシンプルな mutate モジュールを実装してください。  
4. **コード生成:** 各ブロックの操作に合わせて、dplyr のパイプラインコードがリアルタイムに生成・表示されるロジックを完成させてください。

### **➤ Phase 3: Advanced Features (高度機能)**

**指示:**

**Phase 3** の実装です。論文のユースケースに対応できる機能を拡充します。

1. **高度なモジュール:**  
   * Group\_by & Summarize モジュールを実装してください。  
   * Arrange (並べ替え) モジュールを実装してください。  
   * ggplot2 を使った簡易プロットモジュール（X軸・Y軸選択）を作成してください。  
2. **Mutateの強化:**  
   * mutate モジュール内に、stringr (文字列処理) や forcats (因子処理) のヘルパーUIを追加してください。  
3. **Joinの実装:**  
   * 2つのデータフレームを結合する Join モジュールのUIを検討・実装してください（入力ソース選択が必要）。

### **➤ Phase 4: JOSS Polish (論文・品質保証)**

**指示:**

**Phase 4** です。JOSS投稿に向けた最終仕上げを行います。

1. **テスト作成:** testthat をセットアップし、特に「GUIパラメータから正しいTidyverseコードが生成されるか」を検証するユニットテストを tests/testthat/ に作成してください。  
2. **ドキュメント:** roxygen2 を使って、全ての関数（モジュール）にドキュメントを記述し、man/ ファイルを生成してください。  
3. **CI/CD:** GitHub Actions のワークフローファイルを作成し、R CMD check が自動で走るようにしてください。  
4. **論文ドラフト:** JOSSのガイドラインに従い、paper.md の下書きを作成してください。

---

## **6\. 機能要件: 実装するTidyverse機能一覧 (Technical Scope)**

### **Category A: 行と列の基本操作**

* **Rows:** filter, slice, arrange, distinct  
* **Columns:** select, rename, relocate  
* **IO:** read\_csv, read\_tsv

### **Category B: 変数作成と変換**

* **Core:** mutate (四則演算)  
* **Helpers:** str\_detect, str\_replace (Stringr), fct\_reorder (Forcats), case\_when

### **Category C: 構造変換と集計**

* **Structure:** pivot\_longer, pivot\_wider  
* **Aggregation:** group\_by, summarize, count, ungroup  
* **Joins:** left\_join, inner\_join  
* **Visualization:** ggplot2 (Basic Geoms)

slidenumber: true
autoscale: true

# 型推論ハンズオン

### @omochimetaru
### swiftc合宿 2019/09/28

---

# 課題

- 虫食い状態の型推論器を完成させましょう。

- リポジトリ: `https://github.com/omochi/SwiftTypeInferenceHandsOn`

- ブランチ`quiz`。`master`は見ないで！

---

# 虫食い箇所

- コメントで`<QXX hint="..." />`となっているところにコードを書く。`XX`は番号。

- `<Q`で検索してください。

- 番号順に取り組むことを想定しています。

- 追記だけで済むようになってます。既存部分の削除は不要です。

---

# テストコード

- 完成するとテストが全部通るようになります。

- ただし、解いてもテスト通過が増えない問題もあります。

- 必要に応じて自分でテストを追加しよう。

---

# 型推論器の完成度

- 型は適当。
- 暗黙変換の推論に対応。
- 型強制(type coerce)を実装。
- 解比較, 解選択を未実装。

---

# 設計

---

## 方針

- コードのデザインをある程度本家swiftコンパイラに寄せてある。
- 実装時も読解と抽出をしながら作った。
- ファイル名、型名、関数名がある程度同じ。

---

## パッケージ

```
- SwiftcBasic: ユーティリティ
- SwiftcType: 型
- SwiftcAST: パーサーとAST
- SwiftcSema: 型推論、虫食いはここだけ。
- SwiftcTest: テスト用のユーティリティ
```

---

## Sema詳細

```
- Constraint: 制約
- Conversion: 変換
- ConstraintSystem: 制約を解くモジュール
- CSApply: 型推論結果によるASTの変換
- CSBinding: 型変数の割当仮説の生成
- CSGen: 制約の生成
- CSMatch: 型のマッチ
- CSSimplify: 制約の簡約
- CSSolve: 探索
- CSStep: 探索のステップ
- TypeChecker: ソース全体を型チェックする。
```

---

## TypeCheckerとConstraintSystem

- ConstraintSystem(CS)は1つの式を解くモジュール
- TypeCheckerが構文に応じてCSを起動する

---

### 例: 代入文

- 代入文の右辺は式なのでCSで解ける。
- 代入の概念や左辺は文の領域なのでCSの対象外。
- CSにデリゲートがあり、TypeCheckerが代入文の扱いを注入する。(`typeCheckVariableDecl`)

---

## 便利なメソッド

```
- ASTNode.dump()
- ConstraintSystem.dump()
- (いろいろな型).description
```

---

# 課題の取り組み方の例

- 虫食い部分でどんな処理をしているのか解析する。
- ブレークポイントを貼ってからテストを発火して、突入過程を調べる。
- そこで何をすべきか考える。
- 本家コンパイラの該当箇所を見て学ぶ。

---

## 本家コンパイラの解析

---

## ビルド

```
$ utils/update-checkout --scheme master
$ utils/build-script --xcode --debug --skip-build-benchmarks
```

---

## Xcode

- `build/Xcode-DebugAssert/swift-macosx-x86_64/Swift.xcodeproj`

- `swift`実行ファイルのschemeを作る

---

## デバッガを使う

- schemeの設定: `Debug Process As: root`, `Launch: Wait for executable to be launched`

- ビルドしたswiftにパスを通す

- XcodeをRunしてからターミナルで実行

---

## swiftcの実行

- `$ swiftc -dump-ast -Xfrontend -debug-constraints 01.swift`

---

# 応用課題

- 対応するswiftcのコードを読んでみましょう。

- 型推論器に機能を追加しよう。

- 成果を発表しよう。


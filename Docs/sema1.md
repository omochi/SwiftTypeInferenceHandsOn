slidenumber: true
autoscale: true

## Swiftの型推論
## アルゴリズム(1)

### @omochimetaru

### わいわいswiftc #14

---

# 型推論

- ソースコードの型を持つ部分に与える型をコンパイラ自動で決定する仕組み。

---

型を持つ部分はどこでしょう？

```swift
let a = 1 + 1
```

---

`-dump-parse`で型推論前のASTが見れる。

`$ swiftc -dump-parse 01.swift`

```lisp
(source_file "01.swift"
  (top_level_code_decl range=[01.swift:1:1 - line:1:13]
    (brace_stmt implicit range=[01.swift:1:1 - line:1:13]
      (pattern_binding_decl range=[01.swift:1:1 - line:1:13]
        (pattern_named 'a')
        (sequence_expr type='<null>'
          (integer_literal_expr type='<null>' value=1 
            builtin_initializer=**NULL** initializer=**NULL**)
          (unresolved_decl_ref_expr type='<null>' name=+ function_ref=unapplied)
          (integer_literal_expr type='<null>' value=1 
            builtin_initializer=**NULL** initializer=**NULL**)))
))
  (var_decl range=[01.swift:1:5 - line:1:5] "a" 
    type='<null type>' let readImpl=stored immutable))
```

---

`-dump-ast`で型推論後のASTが見れる。

`$ swiftc -dump-ast 01.swift`

```lisp
(source_file "01.swift"
  (top_level_code_decl range=[01.swift:1:1 - line:1:13]
    (brace_stmt implicit range=[01.swift:1:1 - line:1:13]
      (pattern_binding_decl range=[01.swift:1:1 - line:1:13]
        (pattern_named type='Int' 'a')
        (binary_expr type='Int' nothrow
          (dot_syntax_call_expr implicit type='(Int, Int) -> Int' nothrow
            (declref_expr type='(Int.Type) -> (Int, Int) -> Int' 
              decl=Swift.(file).Int extension.+ function_ref=unapplied)
            (type_expr implicit type='Int.Type' typerepr='Int'))
          (tuple_expr implicit type='(Int, Int)'
            (integer_literal_expr type='Int' value=1 
              builtin_initializer=Swift.(file).Int.init(_builtinIntegerLiteral:)
              initializer=**NULL**)
            (integer_literal_expr type='Int' value=1
              builtin_initializer=Swift.(file).Int.init(_builtinIntegerLiteral:)
              initializer=**NULL**))))
))
  (var_decl range=[01.swift:1:5 - line:1:5] "a" type='Int' 
    interface type='Int' access=internal let readImpl=stored immutable))
```

---

- 部分式全てに型が付く。
- リテラル式の型はリテラルの種類に対して複数ありうる。
- 呼び出される関数の型とオーバーロードを解決する。
- 呼び出し式それ自体も型を持つ。
- 変数も型を持つ。

---

## 型推論のアルゴリズム

---

## 難しさのポイント

- 逆方向の推論が存在する
- 型変換による境界表現が存在する

---

## 順方向と逆方向

- プログラムの評価順を順方向とすると、順方向だけの推論であれば簡単。

---

## 順方向の例

```c
// C言語
void f(void) {
    int a = 1 + 1;
}
```

- リテラルの型`int`が、演算子`+`呼び出しの型として伝搬して、チェックされている。

---

## 順方向の型推論？

- 一般に、こういう型チェックは型推論と呼ばれない。

---

## 逆方向の例

```swift
func takeFunc(_ f: (Int) -> Void) { ... }

takeFunc { (x) in }
```

- クロージャのパラメータ`x`の型が`takeFunc`の型から`Int`として推論される。評価は引数式のほうが先だが、呼び出す関数の型から逆算している。

---

## 逆方向の例

```swift
func getX<X>() -> X { ... }

let a: Int = getX()
```

- `getX`の返り値の型が、呼び出し後の代入先の変数の型`Int`として推論される。評価は右辺のほうが先だが、左辺の型から逆算している。

---

## 型変換による境界表現

- Swiftには暗黙の型変換があるので、ほとんどのケースで推論条件が「変換可能」という部分的な情報でしか無く、直接的に答えを与えてくれない。

---

## 境界表現の例

```swift
let a: Int? = ...
```

- 右辺の型は「`Int?`に変換可能」であり、`Int?`そのものとは限らない。`Int`でも良い。

---

## 境界表現の例

```swift
class Parent {}
class ChildA : Parent {}
class ChildB : Parent {}

func takeTwo<X: Parent>(_ a: X, _ b: X) { ... }

takeTwo(ChildA(), ChildB())
```

- `takeTwo.X`の型は「Parentのsubtype」であり、`Parent`そのものとは限らない。
- この例では、与えているのは`Parent`ではないが、`X`は`Parent`として解決する。

---

## 予告

- 以降では、簡単な場合から始めて、徐々に複雑な場合を説明する。

---

## 簡単な場合のアルゴリズム

---

## 簡単な場合のアルゴリズム

- 境界表現が無い場合、HM型推論[^1]というアルゴリズムで解ける。

[^1]: `https://en.wikipedia.org/wiki/Hindley–Milner_type_system`

---

## 問題の定式化

- 型推論(type inference)とは、型(type)に型変数(type variable)を加えた上で、全ての制約(constraint)を満たす型変数の置換表(substitution map)を求めることである。

- 型変数と制約は、ソースコードから生成される。

---

- 型変数ではない型を固定型(fixed type)と呼ぶことにする。

---

## 例1

```swift
func g(_ f: (Int) -> Void) { ... }

g { (x) in }
```

---

### AST

```
funcdecl g: (Int) -> Void

apply {
    callee = declref g
    argument = closure {
        param x
    }
}
```

---

### 型変数を置く

```
apply: T1 {
    callee = g: ((Int) -> Void) -> Void
    argument = closure: (T2) -> T3 {
        param x: T2
    }
}
```

---

### 解くべき置換表

```
T1 => ??
T2 => ??
T3 => ??
```

- 置換先が型変数の場合もある。
- ある型変数の置換を辿って最後に到達する型変数を、その型変数の代表型変数(representative)と呼ぶ。

---

### 置換表の例

```
T1 => Int
T2 => ??
T3 => T2
```

- `T1`は代表型変数。置換先は固定型`Int`。
- `T2`は代表型変数。置換先は未解決。
- `T3`の代表型変数は`T2`。直接の置換先は`T2`、完全な置換先は未解決。

---

### 制約の生成規則

```
apply >>
  ??
```

---

```
apply >>
  // 呼び出し式の型は、呼び出し先の返り値の型
  self.type <bind> callee.return
```

---

```
apply >>
  self.type <bind> callee.return
  // 呼び出し先の引数の型は、呼び出しの引数の型
  callee.parameter <bind> argument
```

---

### 制約を生成

```
apply >>
  T1 <bind> Void
  (Int) -> Void <bind> (T2) -> T3
```

---

### 制約の解決規則

- 全ての型変数は完全な置換先に置き換えてから取り扱う。よって、出てくる型変数は全て代表型変数を考える。

---

### 型変数と固定型の割当

```
typevar <bind> fixed >>
  assign(typevar, fixed)
```

- typevarの置換先をfixedにする。

😄

---

### 型変数と型変数の割当

```
typevar1 <bind> typevar2 >>
  merge(typevar1, typevar2)
```

- typevar2の置換先をtypevar1にする。
- 代表型変数のグループが統合される。
- 便宜上、若い番号に代表を寄せていくことにする。

😄

---

### 関数型同士の割当

```
(type1) -> type2 <bind> (type3) -> type4 >>
  type1 <bind> type3
  type2 <bind> type4
```

- このような、新たな細かい規則に分解する場合を簡約規則(simplify)と呼ぶ。

🤩

---

### 制約の解決

```
T1 <bind> Void >>
  T1 => Void
```

---

```
(Int) -> Void <bind> (T2) -> T3 >>
  Int <bind> T2
  Void <bind> T3

Int <bind> T2 >>
  T2 => Int

Void <bind> T3 >>
  T3 => Void
```

---

### 推論結果

```
apply: Void {
    callee = g: ((Int) -> Void) -> Void
    argument = closure: (Int) -> Void {
        param x: Int
    }
}
```

---

### エラーになる場合

```
fixed1 <bind> fixed2 >>
  assert fixed1 == fixed2 
```

---

## 例2

- リテラルは`Int`固定とする。

```swift
let a = { (x) in x }(3)
```

---

### AST + typevar

```
vardecl a: T1 {
  init = apply: T2 {
    callee = closure: (T3) -> T4 {
      param x: T3
      body: declref x: T5
    }
    argument = 3: Int
  }
}
```

---

### 代入の規則

```
vardecl >>
  self.type <bind> init
```

😄

---

### クロージャの規則

```
closure >>
  self.type.return <bind> body
```

- クロージャ本文が1文の時だけ。
- 複数文の時は別の問題として後で処理される。

😄

---

### declrefの規則

```
declref >>
  self.type <bind> target
```

- 名前参照は参照対象の型になる。

---

### 制約を生成

```
vardecl >>
  ??
```

---

```
vardecl >>
  T1 <bind> T2

apply >>
  ??
```

---

```
vardecl >>
  T1 <bind> T2

apply >>
  T2 <bind> T4
  T3 <bind> 3

closure >>
  ??
```

---

```
vardecl >>
  T1 <bind> T2

apply >>
  T2 <bind> T4
  T3 <bind> 3

closure >>
  T5 <bind> T4

declref >>
  ??
```

---

```
vardecl >>
  T1 <bind> T2

apply >>
  T2 <bind> T4
  T3 <bind> Int

closure >>
  T5 <bind> T4

declref >>
  T3 <bind> T5
```

---

### 制約の解決

```
T1 <bind> T2 >>
  T2 => T1

T2 <bind> T4 >>
  T4 => T2 => T1

T3 <bind> Int >>
  T3 => Int

T5 <bind> T4 >>
  T5 => T4 => T1

T3 <bind> T5 >>
  T5 => T4 => T1 => T3 => Int
```

---

### 推論結果

```
vardecl a: Int {
  init = apply: Int {
    callee = closure: (Int) -> Int {
      param x: Int
      body: declref x: Int
    }
    argument = 3: Int
  }
}
```

---

## 計算量

- ここまで見てきたように、ASTをスキャンすればそのまま流れで全てが解ける。
- HM型推論はコードサイズ`n`に対して`O(n)`。

---

## オーバーロードの導入

---

## オーバーロードの導入

```swift
func f(_ a: Int) { ... }

func f(_ a: String) { ... }

f(3)
```

---

- 関数のオーバーロードを導入すると、これまでのアルゴリズムを部分処理として、全体としては探索処理が導入される。

---

## 制約の追加

- これまでは `<bind>` だけだったが、他の種類を追加する。

---

- `(A) -> B <applicable function> C`
  `C`は`A`を引数に呼び出し、`B`を返す型。

- `A <bind overload> B`
  `A`のオーバーロードを解決して型`B`とする。

- `disjunction(c1, c2, ...)`
  制約`c1`, `c2`,...のどれかを満たす。

---

## 例3

```swift
func f(_ a: String) { ... }

func f(_ a: Int) { ... }

f(3)
```

---

### AST

```
funcdecl f: (String) -> Void
funcdecl f: (Int) -> Void

apply {
  callee = declref f
  argument = 3: Int
}
```

---

### オーバーロードdeclrefの規則

```
overloaded_declref >>
  disjunction(
    self.type <bind overload> target1,
    self.type <bind overload> target2,
    ...
  )
```

😄

---

### applyの規則

```
apply >>
  (arg) -> self.type <app fn> callee
```

- calleeが関数型をしているとは限らないので、いったん`<app fn>`制約として表現して後回しにする。

🤩

---

### 型変数の生成

```
funcdecl f: (String) -> Void
funcdecl f: (Int) -> Void

apply: T1 {
  callee = declref f: T2
  argument = 3: Int
}
```

---

### 制約の生成

```
apply >>
  (Int) -> T1 <app fn> T2

decldef >>
  disjunction(
    T2 <bind ol> (String) -> Void,
    T2 <bind ol> (Int) -> Void
  )
```

---

### 探索付きの解決

1. できるだけ制約を解決する
2. 型変数が消えてれば解発見
3. disjunction制約について
  3-1. 内包する制約を試行する
  3-2. `1.`からやり直してみる
  3-3. 全滅したらエラー

---

### disjunction試行

```
[attempt]
T2 <bind ol> (String) -> Void

(Int) -> T1 <app fn> T2
```

---

### bind overloadの解決

- `<bind>`と同じで良いです。将来的にはいろいろあります。

```
T2 <bind ol> (String) -> Void >>
  T2 => (String) -> Void
```

---

### applicable functionの解決

```
(A) -> B <app fn> C >>
  if C is typevar:
    *ambiguous
  if C is (D) -> E:
    A <bind> D
    B <bind> E
  else:
    *error
```

- `*ambiguous`は、「今は解けない/後で解く」の意味。

---

- `T2`の置換を得たので動く。

```
(Int) -> T1 <app fn> T2 => (String) -> Void >>
  Int <bind> String
  T1 <bind> Void

Int <bind> String >>
  *error
```

🤩

- ここでdisjunction試行の失敗が判明する。

---

### disjunction試行2

```
[attempt]
T2 <bind ol> (Int) -> Void

(Int) -> T1 <app fn> T2 >>
  T2 => (Int) -> Void

(Int) -> T1 <app fn> (Int) -> Void
  Int <bind> Int
  T1 <bind> Void >>
    T1 => Void
```

- 解けた

---

## disjunctionの選択

- 複数あるdisjunctionの中で、どれを選択するかの工夫がある。[^2]

[^2]: selectBestBindingDisjunction in lib/Sema/CSSolver.cpp

---

## 制約ワークリスト

- 先の手順において、`<app fn>`制約の再試行が生じた。

- この再試行を、都度全ての制約に対して行うと効率が悪い。

- そこで、置換表に変化が生じた瞬間、影響を受けうる制約を検索してフラグを立てる。

- コンパイラ内部では、このフラグが立っている事を`active`と呼ぶ。

---

## 暗黙の変換の導入

---

## 暗黙の変換

- Swiftにはいろいろな暗黙の変換がある。

- ここではOptionalの変換だけを取り扱う。 

---

## 例4

```swift
func f(_ a: Int?) -> Void

a(3)
```

---

## 制約の追加

- `A <conversion> B`
  `A`が`B`に変換できる

---

## 変換関係の解決

```
A <conv> B >>
  if A or B is typevar:
    *ambiguous
  else:
    check(A <c B)
```

- まあ解けないのですぐambiguousになる。
- `check`の詳細は後述。

---

## `<app fn>`解決の変更

```
(A) -> B <app fn> (C) -> D >>
  A <conv> C
  B <bind> D
```

- 引数に渡すときに暗黙変換を認める。

---

## closure body制約の変更

```
closure >>
  closure.body <conv> closure.return
```

- 本文の型から返り値の型に暗黙変換を認める。

---

### AST + typevar

```swift
funcdecl f: (Int?) -> Void

apply: T1 {
  callee = f: (Int?) -> Void
  argument = 3: Int
}
```

---

### 制約の生成

```
apply >>
  (Int) -> T1 <app fn> (Int?) -> Void
```

---

### 制約の解決

```
(Int) -> T1 <app fn> (Int?) -> Void >>
  Int <conv> Int?
  T1 <bind> Void

Int <conv> Int? >>
  check ok

T1 <bind> Void >>
  T1 => Void
```

- checkは後述

---

## 例5

```swift
func f(_ a: Int?) { ... }

f({ (x) in x }(3))
```

---

### AST + typevar

```
funcdecl f: (Int?) -> Void

apply: T1 {
  callee = f: (Int?) -> Void
  argument = apply: T2 {
    callee = closure: (T3) -> T4 {
      param x: T3
      body declref x: T5
    }
    argument = 3: Int
  }
}
```

😱

---

### 制約の生成

```
apply >>
  ??
```

---

```
apply >>
  (T2) -> T1 <app fn> (Int?) -> Void

apply >>
  ??
```

---

```
apply >>
  (T2) -> T1 <app fn> (Int?) -> Void

apply >>
  (Int) -> T2 <app fn> (T3) -> T4

declref >>
  ??
```

---

```
apply >>
  (T2) -> T1 <app fn> (Int?) -> Void

apply >>
  (Int) -> T2 <app fn> (T3) -> T4

declref >>
  T5 <bind> T3

closure >>
  ??
```

---

```
apply >>
  (T2) -> T1 <app fn> (Int?) -> Void

apply >>
  (Int) -> T2 <app fn> (T3) -> T4

declref >>
  T5 <bind> T3

closure >>
  T3 <conv> T4
```

---

## 制約の解決

```
(T2) -> T1 <app fn> (Int?) -> Void >>
  ??
```

---

```
(T2) -> T1 <app fn> (Int?) -> Void >>
  T2 <conv> Int?
  T1 <bind> Void

(Int) -> T2 <app fn> (T3) -> T4 >>
  ??
```

---

```
(T2) -> T1 <app fn> (Int?) -> Void >>
  T2 <conv> Int?
  T1 <bind> Void

(Int) -> T2 <app fn> (T3) -> T4 >>
  Int <conv> T3
  T2 <bind> T4

declref >>
  ??
```

---

```
(T2) -> T1 <app fn> (Int?) -> Void >>
  T2 <conv> Int?
  T1 <bind> Void

(Int) -> T2 <app fn> (T3) -> T4 >>
  Int <conv> T3
  T2 <bind> T4

declref >>
  T5 <conv> T3

closure >>
  ??
```

---

```
(T2) -> T1 <app fn> (Int?) -> Void >>
  T2 <conv> Int?
  T1 <bind> Void

(Int) -> T2 <app fn> (T3) -> T4 >>
  Int <conv> T3
  T2 <bind> T4

declref >>
  T5 <bind> T3

closure >>
  T3 <conv> T4
```

---

```
T1 => Void
T4 => T2
T5 => T3

T2 => ?
T3 => ?

closure: (T3) -> T4

T2 <conv> Int?
Int <conv> T3
T3 <conv> T4 => T2
```

---

## 変換の探索

- 未解決の代表型変数ごとに、固定型での型境界を列挙する。

- 対象の代表型変数を選んで、境界自体のbindを試行する。(代表変数の選択は試行ではない)

🤯

---

### 変換の探索候補

```
T2:
T2 <conv> Int? >>
  T2 <c Int?
T3 <conv> T4 => T2 [not fixed]

T3:
Int <conv> T3 >>
  T3 >c Int
T3 <conv> T4 => T2 [not fixed]
```

---

### 対象: T2; 試行 1/1

```
T2 <c Int? >>
  [attempt] T2 => Int?

T2 => Int? <conv> Int? >>
  check ok

T3 <conv> T4 => T2 => Int?
```

🤩

---

### 変換の探索候補

```
T3:
Int <conv> T3 >>
  T3 >c Int

T3 <conv> T4 => T2 => Int? >>
  T3 <c Int?
```

- `T3`と`T2`の関係制約が、`T2`の仮bindによって、固定型境界を生成した。

---

### 対象: T3; 試行 1/2

```
T3 >c Int >>
  [attempt] T3 => Int

Int <conv> T3 => Int >>
  check ok

T3 => Int <conv> T4 => T2 => Int? >>
  check ok
```

---

### 解

```
T1 => Void
T2 => Int?
T3 => Int
T4 => T2 => Int?
T5 => T3 => Int

closure: (T3) -> T4
```

```swift
func f(_ a: Int?) { ... }

f({ (x: Int) -> Int? in x }(3))
```

---

### 対象: T3; 試行 1/2

```
T3 <c Int?? >>
  [attempt] T3 => Int?

Int <conv> T3 => Int? >>
  check ok

T3 => Int <conv> T4 => T2 => Int? >>
  check ok
```

---

### 解

```
T1 => Void
T2 => Int?
T3 => Int?
T4 => T2 => Int?
T5 => T3 => Int

closure: (T3) -> T4
```

```swift
func f(_ a: Int?) { ... }

f({ (x: Int?) -> Int? in x }(3))
```

---

## 解の選択

- 複数の解が出た場合、より型変換が少なく、よりシグネチャが厳しいものが選択される。[^3]

- 型変換には複数の種類があり、種類ごとに比較優先度が異なる。[^4]

- 今回のケースではどの解も等価になる。valueToOptionalの数が同じため。

[^3]: compareSolutions in lib/Sema/CSRanking.cpp

[^4]: Score::operator< in lib/Sema/Constraint.h

---

## 対象代表型変数の選択

- 対象代表型変数にどれを選択するかの工夫がある。[^5] 
- 例えば、他の型変数に影響を与えないものは優先される。[^6]

[^5]: determineBestBindings in lib/Sema/CSBindings.cpp

[^6]: PotentialBindings::operator< in lib/Sema/Constraint.h

---

## disjunctionとの共存

- 型境界のbindを試行する代表型変数の選択と、disjunction制約の選択は、その変換の特性によって優先度が前後する。[^7]

[^7]: ComponentStep::take in lib/Sema/CSStep.cpp

---

## supertype境界のjoin

- 変換の型境界を列挙する再、supertype境界同士はjoinされて、共通のsupertypeの境界に丸められる。[^8]

[^8]: addPotentialBinding in lib/Sema/CSBindings.cpp

---

## 代入文の最適化

- 代入文は `rhs <conv> lhs`だが、左辺に型指定がない場合は、左辺の型に直接右辺の型を採用する。

---

## 変換の種類

- `<conv>`以外にも、サブタイプ変換、引数変換、オペレータ引数変換などがある。

---

## 変換の検査

- 変換の検査の(ここまで`check`と書いていた)処理は、より詳細な変換へのsimplifyが行われる。

---

## Optionalの変換

- `DeepEqual`:
  `A == B`, コスト無し。

- `ValueToOptional`: 
  `A <c C; .some(C) == B`, コスト有り。

- `OptionalToOptional`:
  `A == .some(C); C <c D; .some(D) == B`,
  コスト無し。

---

## 変換の探索アルゴリズム

- `<conv>`制約に変換の種類を添加できる。

- 型変換をチェックする時、ありえる変換の種類だけ、種類付きの制約を生成して、disjunctionにまとめる。

```
Cat? <conv> Animal?? >>
disjunction(
  Cat? <conv dpeq> Animal??,
  Cat? <conv VtoO> Animal??,
  Cat? <conv OtoO> Animal??
)
```

---

- 種類付きの変換のチェックでは、その種類に基づく新たな制約にsimplifyする。

```
Cat <conv> Animal? >>
Cat <conv VtoO> Animal? >>
Cat <conv> Animal >>
Cat <conv super> Animal
```

---

## Optionalの変換の再帰性

```
Cat <conv> Animal?? >>
Cat <conv VtoO> Animal?? >>
Cat <conv> Animal? >>
Cat <conv VtoO> Animal? >>
Cat <conv> Animal >>
Cat <conv super> Animal
```

---

## Optionalの変換の組み合わせ探索

```
[sol 1]
Cat? <conv> Animal?? >>
Cat? <conv VtoO> Animal?? >>
Cat? <conv> Animal? >>
Cat? <conv OtoO> Animal? >>
Cat <conv> Animal >>
Cat <conv super> Animal

[sol 2]
Cat? <conv> Animal?? >>
Cat? <conv OtoO> Animal?? >>
Cat <conv> Animal? >>
Cat <conv VtoO> Animal? >>
Cat <conv> Animal >>
Cat <conv super> Animal
```


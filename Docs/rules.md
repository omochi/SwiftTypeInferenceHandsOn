# 規則集

# ASTNode

## Call

```
call {
    callee
    argument
}
```

## Closure

```
closure {
    body[]
}
```

## DeclRef

```
declref {
    name
}
```

## OverloadedDeclRef

```
overloaded_declref {
    targets[]
}
```

## VariableDecl

```
vardecl {
    var_name
    init
}
```

# 制約の生成規則 / constraints generation rules

## Call

```
(argument) -> self <appfn> callee
```

## Closure

```
body <conv> result
```

## DeclRef

```
self <bind> target
```

## OverloadedDeclRef

```
disjunction(
    self <bind> targets[0],
    self <bind> targets[1],
    ...
)
```

## VariableDecl

```
init <conv> var
```

# 制約の簡約規則 / constraints simplify rules

## bind

```
primitive1 <bind> primitive2 >>
    if primitive1 == primitive2:
        *solved
    *failure
```

```
(type1) -> type2 <bind> (type3) -> type4 >>
    type1 <bind> type3
    type2 <bind> type4
```

```
fixed <bind> typevar >>
    assign(typevar, fixed)
```

```
typevar1 <bind> typevar2 >>
    merge(typevar1, typevar2)
```

## applicative function

```
(arg) -> ret <appfn> callee >>
    if callee is typevar:
        *ambiguous
    if callee is function:
        arg <conv> callee.param
        ret <bind> callee.result
    *failure
```

## conversion

```
primitive1 <conv> primitive2 >>
    if primitive1 == primitive2:
        *solved
    *failure
```

```
(type1) -> type2 <conv> (type3) -> type4 >>
    type3 <conv> type1 // contravariance
    type2 <conv> type4 // covariance
```

```
type1 <conv> type2
    where type2 is more optional than type1 >>
    type1 <conv VtoO> type2.wrapped
```

```
type1 <conv> type2
    where type1 and type2 are optional >>
    type1 <conv DEQ> type2
    type1.wrapped <conv OtoO> type2.wrapped
```

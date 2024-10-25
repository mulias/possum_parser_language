# Parsing Abstract Syntax Trees

The Possum standard library provides a handful of parsers that are specific to parsing abstract syntax trees (ASTs). Unlike most of the standard library, these parsers solve a specific problem, are meant to be used together, and have a more rigid function API. As a result this additional documentation is necessary to understand and use these parsers. While the concepts and functions presented here might seem a bit fiddly, if you're parsing a programming language syntax or anything with operators of mixed precedence/associativity then this is probably what you want.

## Operator Precedence

A tricky problem we need to tackle for parsing many (non-lisp) language syntaxes is mixed operator precedence, meaning operations that are not always performed in left to right order. A classic example is PEMDAS ordering in arithmetic, where parenthesized groups are calculated before exponents, then multiplication, division, addition, and finally subtraction. We're going to make handling this category of parsing problems easy by outlining a framework for understanding operator precedence, and then using that framework with precedence aware parser functions which can be configured for a wide range of use cases.

### Binding Power

One way to handle operators with mixed precedence is to give each operator a different binding power. Binding power is the amount of pull an operator has on the values on either side of it. Higher binding power means the operator holds onto its values tighter. In this example we've assigned `+` binding power 2, and `*` binding power 4. The beginning and end of the expression always have binding power 0.

```
expr:    4   +   7   *   3
power: 0   2   2   4   4   0
```

The multiplication sign is pulling on `7` with more power than the plus sign, and pulling on `3` with more power than the end of the expression. This means we can group those values together so that they get evaluated first.

```
expr:    4   +   (7 * 3)
power: 0   2   2         0
```

Now the plus sign is pulling on the `4` and the grouped multiplication expression with more power than the start and end of the expression.

```
expr:    (4 + (7 * 3))
power: 0               0
```

The same concept applies to prefix and postfix operators. These operators only bind on one side, but might interact with operators on the opposite side of the expression. For example, in the expression `-5!` we can parse the minus sign as a prefix operator for unary negation, and the exclamation mark as a postfix operator for factorial. In order to calculate the factorial before negating we can give `!` a higher binding power.

```
expr:    -   5   !
power: 0   7   8   0

expr:    -   (5!)
power: 0   7      0

expr:    (-(5!))
power: 0         0
```

### Associativity

Binding power can also model associativity. By making the binding power on either side of an infix operator asymmetric we can dictate if it is left- or right-associative. Confusingly, increasing the left binding power makes an operator right-associative, while increasing the right binding power makes it left-associative. The reason for this behavior is at least intuitive, since we can see in this example how increasing the left binding power makes the right-most operator hold more tightly to its values.

```
expr:    1   +   2   +   3
power: 0   3   2   3   2   0

expr:    1   +   (2 + 3)
power: 0   3   2         0

expr:    (1 + (2 + 3))
power: 0               0
```

## Parsers

### `ast_with_operator_precedence(value, prefix, infix, postfix)`

Parses an AST with customizable operators and operator precedence. Takes four parser arguments:

* `value`: Parser for AST leaf nodes. This parser handles all data in the AST. The result of `value` can be any type, but in most cases it makes sense to return an object tagged with the type of the node data. In the following example `value` parses numbers and variables, returning both as objects tagged with a `"type"` field.

    ```
    value = number_node | var_node
    number_node = number -> Num $ {"type": "number", "value": Num}
    var_node = alphas -> Var $ {"type": "var", "value": Var}
    ```

- `prefix`: Parser for operators that can be placed in front of any value. The result of `prefix` must be an array with two elements. The first element must be an object, the node for the AST, and the second element must be a number, the operator's binding power. If there are no prefix operators to parse, use the `@fail` parser to skip this step. In the following example `prefix` parses either a minus sign or the `not` keyword, and returns a tuple with a node object and binding power in both cases.

    ```
    prefix =
      ("-" $ [{"type": "negate_number"}, 6]) |
      (word -> "not" $ [{"type": "negate_boolean"}, 5])
    ```
    When a prefix is parsed the prefixed expression is also parsed based on the prefix operator's binding power, and the resulting subtree is added to the prefix node object with the key `"prefixed"`. For example with the `value` and `prefix` parsers defined above the expression `"-5"` would parse as:

    ```
    {
      "type": "negate_number",
      "prefixed": {"type": "number", "value": 5}
    }
    ```

* `infix`: Parser for operators that combine two values. The result of `infix` must be an array with three elements. The first element must be an object, the node for the AST. The second and third elements must be numbers, indicating the left and right binding power of the operator, respectively. In the following example `infix` parses the plus sign as left-associative addition, and equals sign as right-associative assignment.

    ```
    infix =
      ("+" $ [{"type": "add"}, 3, 4]) |
      ("=" $ [{"type": "assign"}, 2, 1])
    ```
    When an infix is parsed the expressions on either side are also parsed based on the infix operator's binding power, and the resulting subtrees are added to the infix node object with the keys `"left"` and `"right"`. For example with the `value` and `infix` parsers defined above the expression `"a = 5 + 1"` would parse as:

    ```
    {
      "type": "assign",
      "left": {"type": "var", "value": "a"},
      "right": {
        "type":  "add",
        "left": {"type": "number", "value": 5},
        "right": {"type": "number", "value": 1}
      }
    }
    ```

* `postfix`: Parser for operators that can be placed after any value. The result of `postfix` must be an array with two elements. The first element must be an object, the node for the AST, and the second element must be a number, the operator's binding power. If there are no postfix operators to parse, use the `@fail` parser to skip this step. This parser is very similar to `prefix`, but the resulting AST node uses the key `"postfixed"` for the subtree modified by the operator.

### `ast_node(Type, value)`

Helper parser for creating tagged nodes. Parses `value` and returns an object with a `"type"` and `"value"` field. For example 
```
ast_node("one_two_three", 123)
```
would return 
```
{"type": "one_two_three", "value": 123}
```
on success. It is very common to want AST nodes to all have a field that indicates the type of the node. If you don't want the type field to be called `"type"` or the value field to be called `"value"` then you can create a similar help with more appropriate names for your use case.

### `ast_op_precedence(op_node, BindingPower)`

Helper for creating prefix and postfix operator parsers. With this parser we can rewrite the `prefix` example above to ensure we match the necessary return format for precedence parsing.

```
prefix =
  ast_op_precedence("-" $ {"type": "negate_number"}, 6) |
  ast_op_precedence(word -> "not" $ {"type": "negate_boolean"}, 5)
```

### `ast_infix_op_precedence(op_node, LeftBindingPower, RightBindingPower)`

Helper for creating infix operator parsers. With this parser we can rewrite the `infix` example above to ensure we match the necessary return format for precedence parsing.

```
infix =
  ast_infix_op_precedence("+" $ {"type": "add"}, 3, 4) |
  ast_infix_op_precedence("=" $ {"type": "assign"}, 2, 1)
```

## Example

This example parses a single expression made up of variables, numbers, and operators. It supports PEMDAS precedence for arithmetic operators, as well as equality, ternary conditionals, variable assignment, prefixed negation, postfixed factorial, and postfixed array index access. It is not whitespace sensitive. Note that the binding power numbers use decimal values to indicate associativity. Using whole numbers or decimals is a matter of personal preference, both work.

```
w = maybe(whitespace)

var_node = ast_node("var", alphas)

number_node = ast_node("num", non_negative_number)

grouped_expr_node = "(" > w > expr < w < ")"

value = var_node | number_node | grouped_expr_node

conditional_infix =
  "?" & w & expr -> Middle & w & ":" $ {"type": "cond", "middle": Middle}

index_postfix = ast_node("index", "[" > w > expr < w < "]")

prefix = ast_op_precedence("-" $ {"type": "neg"}, 7)

infix =
  ast_infix_op_precedence("^" $ {"type": "exp"}, 6, 6.5) |
  ast_infix_op_precedence("*" $ {"type": "mul"}, 5, 5.5) |
  ast_infix_op_precedence("/" $ {"type": "div"}, 5, 5.5) |
  ast_infix_op_precedence("+" $ {"type": "add"}, 4, 4.5) |
  ast_infix_op_precedence("-" $ {"type": "sub"}, 4, 4.5) |
  ast_infix_op_precedence("==" $ {"type": "eql"}, 3, 3.5) |
  ast_infix_op_precedence(conditional_infix, 2.5, 2) |
  ast_infix_op_precedence("=" $ {"type": "assign"}, 1.5, 1)

postfix =
  ast_op_precedence("!" $ {"type": "fac"}, 8) |
  ast_op_precedence(index_postfix, 8)

expr = ast_with_operator_precedence(
  surround(value, w),
  surround(prefix, w),
  surround(infix, w),
  surround(postfix, w)
)

expr
```

Running the parser:

```
$ possum arithmetic.possum -i '--a[1 + 4 / b]! * 4 ^ 2'
{
  "type": "mul",
  "left": {
    "type": "neg",
    "prefixed": {
      "type": "neg",
      "prefixed": {
        "type": "fac",
        "postfixed": {
          "type": "index",
          "value": {
            "type": "add",
            "left": {"type": "num", "value": 1},
            "right": {
              "type": "div",
              "left": {"type": "num", "value": 4},
              "right": {"type": "var", "value": "b"}
            }
          },
          "postfixed": {"type": "var", "value": "a"}
        }
      }
    }
  },
  "right": {
    "type": "exp",
    "left": {"type": "num", "value": 4},
    "right": {"type": "num", "value": 2}
  }
}
```

  $ possum possum_ast.parser -i "'abc'"
  {
    "type": "program",
    "defs": [
      {
        "type": "main_parser",
        "body": {
          "type": "parser_steps",
          "steps": [ { "type": "string_lit", "value": "abc" } ]
        }
      }
    ]
  }

  $ possum possum_ast.parser -i "'ab\'c'"
  {
    "type": "program",
    "defs": [
      {
        "type": "main_parser",
        "body": {
          "type": "parser_steps",
          "steps": [ { "type": "string_lit", "value": "ab'c" } ]
        }
      }
    ]
  }

  $ possum possum_ast.parser -i "/abc/"
  {
    "type": "program",
    "defs": [
      {
        "type": "main_parser",
        "body": {
          "type": "parser_steps",
          "steps": [ { "type": "regex_step", "value": "abc" } ]
        }
      }
    ]
  }

  $ possum possum_ast.parser -i "1234"
  {
    "type": "program",
    "defs": [
      {
        "type": "main_parser",
        "body": {
          "type": "parser_steps",
          "steps": [ { "type": "number_lit", "value": 1234 } ]
        }
      }
    ]
  }

  $ possum possum_ast.parser --input="-37"
  {
    "type": "program",
    "defs": [
      {
        "type": "main_parser",
        "body": {
          "type": "parser_steps",
          "steps": [ { "type": "number_lit", "value": -37 } ]
        }
      }
    ]
  }

  $ possum possum_ast.parser -i "int"
  {
    "type": "program",
    "defs": [
      {
        "type": "main_parser",
        "body": {
          "type": "parser_steps",
          "steps": [
            {
              "type": "parser_apply",
              "id": { "type": "parser_id", "value": "int" },
              "args": []
            }
          ]
        }
      }
    ]
  }

  $ possum possum_ast.parser -i "array(int)"
  {
    "type": "program",
    "defs": [
      {
        "type": "main_parser",
        "body": {
          "type": "parser_steps",
          "steps": [
            {
              "type": "parser_apply",
              "id": { "type": "parser_id", "value": "array" },
              "args": [
                {
                  "type": "parser_steps",
                  "steps": [
                    {
                      "type": "parser_apply",
                      "id": { "type": "parser_id", "value": "int" },
                      "args": []
                    }
                  ]
                }
              ]
            }
          ]
        }
      }
    ]
  }

  $ possum possum_ast.parser -i "'one' | 'two'"
  {
    "type": "program",
    "defs": [
      {
        "type": "main_parser",
        "body": {
          "type": "parser_steps",
          "steps": [
            { "type": "string_lit", "value": "one" },
            { "infix": "Or" },
            { "type": "string_lit", "value": "two" }
          ]
        }
      }
    ]
  }

  $ possum possum_ast.parser -i "1 > (2 | 3) < 4"
  {
    "type": "program",
    "defs": [
      {
        "type": "main_parser",
        "body": {
          "type": "parser_steps",
          "steps": [
            { "type": "number_lit", "value": 1 },
            { "infix": "TakeRight" },
            {
              "type": "group",
              "value": {
                "type": "parser_steps",
                "steps": [
                  { "type": "number_lit", "value": 2 },
                  { "infix": "Or" },
                  { "type": "number_lit", "value": 3 }
                ]
              }
            },
            { "infix": "TakeLeft" },
            { "type": "number_lit", "value": 4 }
          ]
        }
      }
    ]
  }

  $ possum possum_ast.parser -i "ws = default(many(comment | whitespace), '') ;"
  {
    "type": "program",
    "defs": [
      {
        "type": "named_parser",
        "id": { "type": "parser_id", "value": "ws" },
        "params": [],
        "body": {
          "type": "parser_steps",
          "steps": [
            {
              "type": "parser_apply",
              "id": { "type": "parser_id", "value": "default" },
              "args": [
                {
                  "type": "parser_steps",
                  "steps": [
                    {
                      "type": "parser_apply",
                      "id": { "type": "parser_id", "value": "many" },
                      "args": [
                        {
                          "type": "parser_steps",
                          "steps": [
                            {
                              "type": "parser_apply",
                              "id": { "type": "parser_id", "value": "comment" },
                              "args": []
                            },
                            { "infix": "Or" },
                            {
                              "type": "parser_apply",
                              "id": {
                                "type": "parser_id",
                                "value": "whitespace"
                              },
                              "args": []
                            }
                          ]
                        }
                      ]
                    }
                  ]
                },
                {
                  "type": "parser_steps",
                  "steps": [ { "type": "string_lit", "value": "" } ]
                }
              ]
            }
          ]
        }
      }
    ]
  }

  $ possum possum_ast.parser possum_ast.parser
  {
    "type": "program",
    "defs": [
      {
        "type": "main_parser",
        "body": {
          "type": "parser_steps",
          "steps": [
            {
              "type": "parser_apply",
              "id": { "type": "parser_id", "value": "input" },
              "args": [
                {
                  "type": "parser_steps",
                  "steps": [
                    {
                      "type": "parser_apply",
                      "id": { "type": "parser_id", "value": "program" },
                      "args": []
                    }
                  ]
                }
              ]
            }
          ]
        }
      },
      {
        "type": "named_parser",
        "id": { "type": "parser_id", "value": "program" },
        "params": [],
        "body": {
          "type": "parser_steps",
          "steps": [
            {
              "type": "parser_apply",
              "id": { "type": "parser_id", "value": "ws" },
              "args": []
            },
            { "infix": "And" },
            { "type": "value_id", "value": "Defs" },
            { "infix": "Destructure" },
            {
              "type": "parser_apply",
              "id": { "type": "parser_id", "value": "array_sep" },
              "args": [
                {
                  "type": "parser_steps",
                  "steps": [
                    {
                      "type": "parser_apply",
                      "id": { "type": "parser_id", "value": "named_parser" },
                      "args": []
                    },
                    { "infix": "Or" },
                    {
                      "type": "parser_apply",
                      "id": { "type": "parser_id", "value": "main_parser" },
                      "args": []
                    }
                  ]
                },
                {
                  "type": "parser_steps",
                  "steps": [
                    {
                      "type": "parser_apply",
                      "id": { "type": "parser_id", "value": "maybe" },
                      "args": [
                        {
                          "type": "parser_steps",
                          "steps": [ { "type": "string_lit", "value": ";" } ]
                        }
                      ]
                    }
                  ]
                }
              ]
            },
            { "infix": "And" },
            {
              "type": "parser_apply",
              "id": { "type": "parser_id", "value": "ws" },
              "args": []
            },
            { "infix": "And" },
            {
              "type": "parser_apply",
              "id": { "type": "parser_id", "value": "maybe" },
              "args": [
                {
                  "type": "parser_steps",
                  "steps": [ { "type": "string_lit", "value": ";" } ]
                }
              ]
            },
            { "infix": "Return" },
            {
              "type": "value_object",
              "value": [
                {
                  "type": "value_object_element",
                  "key": { "type": "string_lit", "value": "type" },
                  "value": { "type": "string_lit", "value": "program" }
                },
                {
                  "type": "value_object_element",
                  "key": { "type": "string_lit", "value": "defs" },
                  "value": { "type": "value_id", "value": "Defs" }
                }
              ]
            }
          ]
        }
      },
      {
        "type": "named_parser",
        "id": { "type": "parser_id", "value": "ws" },
        "params": [],
        "body": {
          "type": "parser_steps",
          "steps": [
            {
              "type": "parser_apply",
              "id": { "type": "parser_id", "value": "default" },
              "args": [
                {
                  "type": "parser_steps",
                  "steps": [
                    {
                      "type": "parser_apply",
                      "id": { "type": "parser_id", "value": "many" },
                      "args": [
                        {
                          "type": "parser_steps",
                          "steps": [
                            {
                              "type": "parser_apply",
                              "id": { "type": "parser_id", "value": "comment" },
                              "args": []
                            },
                            { "infix": "Or" },
                            {
                              "type": "parser_apply",
                              "id": {
                                "type": "parser_id",
                                "value": "whitespace"
                              },
                              "args": []
                            }
                          ]
                        }
                      ]
                    }
                  ]
                },
                {
                  "type": "parser_steps",
                  "steps": [ { "type": "string_lit", "value": "" } ]
                }
              ]
            }
          ]
        }
      },
      {
        "type": "named_parser",
        "id": { "type": "parser_id", "value": "comment" },
        "params": [],
        "body": {
          "type": "parser_steps",
          "steps": [
            { "type": "string_lit", "value": "#" },
            { "infix": "TakeRight" },
            {
              "type": "parser_apply",
              "id": { "type": "parser_id", "value": "until" },
              "args": [
                {
                  "type": "parser_steps",
                  "steps": [
                    {
                      "type": "parser_apply",
                      "id": { "type": "parser_id", "value": "char" },
                      "args": []
                    }
                  ]
                },
                {
                  "type": "parser_steps",
                  "steps": [
                    {
                      "type": "parser_apply",
                      "id": { "type": "parser_id", "value": "newline" },
                      "args": []
                    },
                    { "infix": "Or" },
                    {
                      "type": "parser_apply",
                      "id": { "type": "parser_id", "value": "end" },
                      "args": []
                    }
                  ]
                }
              ]
            }
          ]
        }
      },
      {
        "type": "named_parser",
        "id": { "type": "parser_id", "value": "named_parser" },
        "params": [],
        "body": {
          "type": "parser_steps",
          "steps": [
            {
              "type": "parser_apply",
              "id": { "type": "parser_id", "value": "ws" },
              "args": []
            },
            { "infix": "And" },
            { "type": "value_id", "value": "Id" },
            { "infix": "Destructure" },
            {
              "type": "parser_apply",
              "id": { "type": "parser_id", "value": "parser_id" },
              "args": []
            },
            { "infix": "And" },
            { "type": "value_id", "value": "Params" },
            { "infix": "Destructure" },
            {
              "type": "parser_apply",
              "id": { "type": "parser_id", "value": "default" },
              "args": [
                {
                  "type": "parser_steps",
                  "steps": [
                    {
                      "type": "parser_apply",
                      "id": {
                        "type": "parser_id",
                        "value": "named_parser_params"
                      },
                      "args": []
                    }
                  ]
                },
                {
                  "type": "parser_steps",
                  "steps": [ { "type": "value_array", "value": [] } ]
                }
              ]
            },
            { "infix": "And" },
            {
              "type": "parser_apply",
              "id": { "type": "parser_id", "value": "ws" },
              "args": []
            },
            { "infix": "TakeRight" },
            { "type": "string_lit", "value": "=" },
            { "infix": "TakeRight" },
            {
              "type": "parser_apply",
              "id": { "type": "parser_id", "value": "ws" },
              "args": []
            },
            { "infix": "And" },
            { "type": "value_id", "value": "Body" },
            { "infix": "Destructure" },
            {
              "type": "parser_apply",
              "id": { "type": "parser_id", "value": "parser_steps" },
              "args": []
            },
            { "infix": "And" },
            {
              "type": "parser_apply",
              "id": { "type": "parser_id", "value": "ws" },
              "args": []
            },
            { "infix": "Return" },
            {
              "type": "value_object",
              "value": [
                {
                  "type": "value_object_element",
                  "key": { "type": "string_lit", "value": "type" },
                  "value": { "type": "string_lit", "value": "named_parser" }
                },
                {
                  "type": "value_object_element",
                  "key": { "type": "string_lit", "value": "id" },
                  "value": { "type": "value_id", "value": "Id" }
                },
                {
                  "type": "value_object_element",
                  "key": { "type": "string_lit", "value": "params" },
                  "value": { "type": "value_id", "value": "Params" }
                },
                {
                  "type": "value_object_element",
                  "key": { "type": "string_lit", "value": "body" },
                  "value": { "type": "value_id", "value": "Body" }
                }
              ]
            }
          ]
        }
      },
      {
        "type": "named_parser",
        "id": { "type": "parser_id", "value": "named_parser_params" },
        "params": [],
        "body": {
          "type": "parser_steps",
          "steps": [
            { "type": "string_lit", "value": "(" },
            { "infix": "TakeRight" },
            {
              "type": "parser_apply",
              "id": { "type": "parser_id", "value": "array_sep" },
              "args": [
                {
                  "type": "parser_steps",
                  "steps": [
                    {
                      "type": "parser_apply",
                      "id": { "type": "parser_id", "value": "ws" },
                      "args": []
                    },
                    { "infix": "TakeRight" },
                    {
                      "type": "parser_apply",
                      "id": { "type": "parser_id", "value": "id" },
                      "args": []
                    },
                    { "infix": "TakeLeft" },
                    {
                      "type": "parser_apply",
                      "id": { "type": "parser_id", "value": "ws" },
                      "args": []
                    }
                  ]
                },
                {
                  "type": "parser_steps",
                  "steps": [ { "type": "string_lit", "value": "," } ]
                }
              ]
            },
            { "infix": "TakeLeft" },
            { "type": "string_lit", "value": ")" }
          ]
        }
      },
      {
        "type": "named_parser",
        "id": { "type": "parser_id", "value": "main_parser" },
        "params": [],
        "body": {
          "type": "parser_steps",
          "steps": [
            {
              "type": "parser_apply",
              "id": { "type": "parser_id", "value": "ws" },
              "args": []
            },
            { "infix": "And" },
            { "type": "value_id", "value": "Body" },
            { "infix": "Destructure" },
            {
              "type": "parser_apply",
              "id": { "type": "parser_id", "value": "parser_steps" },
              "args": []
            },
            { "infix": "And" },
            {
              "type": "parser_apply",
              "id": { "type": "parser_id", "value": "ws" },
              "args": []
            },
            { "infix": "Return" },
            {
              "type": "value_object",
              "value": [
                {
                  "type": "value_object_element",
                  "key": { "type": "string_lit", "value": "type" },
                  "value": { "type": "string_lit", "value": "main_parser" }
                },
                {
                  "type": "value_object_element",
                  "key": { "type": "string_lit", "value": "body" },
                  "value": { "type": "value_id", "value": "Body" }
                }
              ]
            }
          ]
        }
      },
      {
        "type": "named_parser",
        "id": { "type": "parser_id", "value": "parser_steps" },
        "params": [],
        "body": {
          "type": "parser_steps",
          "steps": [
            {
              "type": "parser_apply",
              "id": { "type": "parser_id", "value": "ws" },
              "args": []
            },
            { "infix": "And" },
            { "type": "value_id", "value": "First" },
            { "infix": "Destructure" },
            {
              "type": "parser_apply",
              "id": { "type": "parser_id", "value": "parser_step" },
              "args": []
            },
            { "infix": "And" },
            { "type": "value_id", "value": "InfixSteps" },
            { "infix": "Destructure" },
            {
              "type": "parser_apply",
              "id": { "type": "parser_id", "value": "default" },
              "args": [
                {
                  "type": "parser_steps",
                  "steps": [
                    {
                      "type": "parser_apply",
                      "id": { "type": "parser_id", "value": "flattened" },
                      "args": [
                        {
                          "type": "parser_steps",
                          "steps": [
                            {
                              "type": "parser_apply",
                              "id": { "type": "parser_id", "value": "array" },
                              "args": [
                                {
                                  "type": "parser_steps",
                                  "steps": [
                                    {
                                      "type": "parser_apply",
                                      "id": {
                                        "type": "parser_id",
                                        "value": "infix_step"
                                      },
                                      "args": []
                                    }
                                  ]
                                }
                              ]
                            }
                          ]
                        }
                      ]
                    }
                  ]
                },
                {
                  "type": "parser_steps",
                  "steps": [ { "type": "value_array", "value": [] } ]
                }
              ]
            },
            { "infix": "Return" },
            {
              "type": "value_object",
              "value": [
                {
                  "type": "value_object_element",
                  "key": { "type": "string_lit", "value": "type" },
                  "value": { "type": "string_lit", "value": "parser_steps" }
                },
                {
                  "type": "value_object_element",
                  "key": { "type": "string_lit", "value": "steps" },
                  "value": {
                    "type": "value_array",
                    "value": [
                      {
                        "type": "value_array_element",
                        "value": { "type": "value_id", "value": "First" }
                      },
                      {
                        "type": "value_array_spread",
                        "value": { "type": "value_id", "value": "InfixSteps" }
                      }
                    ]
                  }
                }
              ]
            }
          ]
        }
      },
      {
        "type": "named_parser",
        "id": { "type": "parser_id", "value": "infix_step" },
        "params": [],
        "body": {
          "type": "parser_steps",
          "steps": [
            {
              "type": "parser_apply",
              "id": { "type": "parser_id", "value": "ws" },
              "args": []
            },
            { "infix": "And" },
            { "type": "value_id", "value": "Infix" },
            { "infix": "Destructure" },
            {
              "type": "parser_apply",
              "id": { "type": "parser_id", "value": "infix" },
              "args": []
            },
            { "infix": "And" },
            {
              "type": "parser_apply",
              "id": { "type": "parser_id", "value": "ws" },
              "args": []
            },
            { "infix": "And" },
            { "type": "value_id", "value": "Step" },
            { "infix": "Destructure" },
            {
              "type": "parser_apply",
              "id": { "type": "parser_id", "value": "parser_step" },
              "args": []
            },
            { "infix": "And" },
            {
              "type": "parser_apply",
              "id": { "type": "parser_id", "value": "ws" },
              "args": []
            },
            { "infix": "Return" },
            {
              "type": "value_array",
              "value": [
                {
                  "type": "value_array_element",
                  "value": { "type": "value_id", "value": "Infix" }
                },
                {
                  "type": "value_array_element",
                  "value": { "type": "value_id", "value": "Step" }
                }
              ]
            }
          ]
        }
      },
      {
        "type": "named_parser",
        "id": { "type": "parser_id", "value": "infix" },
        "params": [],
        "body": {
          "type": "parser_steps",
          "steps": [
            {
              "type": "parser_apply",
              "id": { "type": "parser_id", "value": "ws" },
              "args": []
            },
            { "infix": "TakeRight" },
            {
              "type": "group",
              "value": {
                "type": "parser_steps",
                "steps": [
                  { "type": "string_lit", "value": "|" },
                  { "infix": "Return" },
                  {
                    "type": "value_object",
                    "value": [
                      {
                        "type": "value_object_element",
                        "key": { "type": "string_lit", "value": "infix" },
                        "value": { "type": "string_lit", "value": "Or" }
                      }
                    ]
                  },
                  { "infix": "Or" },
                  { "type": "string_lit", "value": ">" },
                  { "infix": "Return" },
                  {
                    "type": "value_object",
                    "value": [
                      {
                        "type": "value_object_element",
                        "key": { "type": "string_lit", "value": "infix" },
                        "value": { "type": "string_lit", "value": "TakeRight" }
                      }
                    ]
                  },
                  { "infix": "Or" },
                  { "type": "string_lit", "value": "<-" },
                  { "infix": "Return" },
                  {
                    "type": "value_object",
                    "value": [
                      {
                        "type": "value_object_element",
                        "key": { "type": "string_lit", "value": "infix" },
                        "value": {
                          "type": "string_lit",
                          "value": "Destructure"
                        }
                      }
                    ]
                  },
                  { "infix": "Or" },
                  { "type": "string_lit", "value": "<" },
                  { "infix": "Return" },
                  {
                    "type": "value_object",
                    "value": [
                      {
                        "type": "value_object_element",
                        "key": { "type": "string_lit", "value": "infix" },
                        "value": { "type": "string_lit", "value": "TakeLeft" }
                      }
                    ]
                  },
                  { "infix": "Or" },
                  { "type": "string_lit", "value": "+" },
                  { "infix": "Return" },
                  {
                    "type": "value_object",
                    "value": [
                      {
                        "type": "value_object_element",
                        "key": { "type": "string_lit", "value": "infix" },
                        "value": { "type": "string_lit", "value": "Concat" }
                      }
                    ]
                  },
                  { "infix": "Or" },
                  { "type": "string_lit", "value": "&" },
                  { "infix": "Return" },
                  {
                    "type": "value_object",
                    "value": [
                      {
                        "type": "value_object_element",
                        "key": { "type": "string_lit", "value": "infix" },
                        "value": { "type": "string_lit", "value": "And" }
                      }
                    ]
                  },
                  { "infix": "Or" },
                  { "type": "string_lit", "value": "$" },
                  { "infix": "Return" },
                  {
                    "type": "value_object",
                    "value": [
                      {
                        "type": "value_object_element",
                        "key": { "type": "string_lit", "value": "infix" },
                        "value": { "type": "string_lit", "value": "Return" }
                      }
                    ]
                  }
                ]
              }
            }
          ]
        }
      },
      {
        "type": "named_parser",
        "id": { "type": "parser_id", "value": "parser_step" },
        "params": [],
        "body": {
          "type": "parser_steps",
          "steps": [
            {
              "type": "parser_apply",
              "id": { "type": "parser_id", "value": "group" },
              "args": []
            },
            { "infix": "Or" },
            {
              "type": "parser_apply",
              "id": { "type": "parser_id", "value": "regex" },
              "args": []
            },
            { "infix": "Or" },
            {
              "type": "parser_apply",
              "id": {
                "type": "parser_id",
                "value": "parser_apply_or_constant_literal"
              },
              "args": []
            },
            { "infix": "Or" },
            {
              "type": "parser_apply",
              "id": { "type": "parser_id", "value": "parser_literal" },
              "args": []
            },
            { "infix": "Or" },
            {
              "type": "parser_apply",
              "id": { "type": "parser_id", "value": "value_array" },
              "args": []
            },
            { "infix": "Or" },
            {
              "type": "parser_apply",
              "id": { "type": "parser_id", "value": "value_object" },
              "args": []
            },
            { "infix": "Or" },
            {
              "type": "parser_apply",
              "id": { "type": "parser_id", "value": "value_id" },
              "args": []
            },
            { "infix": "Or" },
            {
              "type": "parser_apply",
              "id": { "type": "parser_id", "value": "ignored_id" },
              "args": []
            }
          ]
        }
      },
      {
        "type": "named_parser",
        "id": { "type": "parser_id", "value": "group" },
        "params": [],
        "body": {
          "type": "parser_steps",
          "steps": [
            { "type": "string_lit", "value": "(" },
            { "infix": "And" },
            {
              "type": "parser_apply",
              "id": { "type": "parser_id", "value": "ws" },
              "args": []
            },
            { "infix": "And" },
            { "type": "value_id", "value": "Steps" },
            { "infix": "Destructure" },
            {
              "type": "parser_apply",
              "id": { "type": "parser_id", "value": "parser_steps" },
              "args": []
            },
            { "infix": "And" },
            {
              "type": "parser_apply",
              "id": { "type": "parser_id", "value": "ws" },
              "args": []
            },
            { "infix": "And" },
            { "type": "string_lit", "value": ")" },
            { "infix": "Return" },
            {
              "type": "value_object",
              "value": [
                {
                  "type": "value_object_element",
                  "key": { "type": "string_lit", "value": "type" },
                  "value": { "type": "string_lit", "value": "group" }
                },
                {
                  "type": "value_object_element",
                  "key": { "type": "string_lit", "value": "value" },
                  "value": { "type": "value_id", "value": "Steps" }
                }
              ]
            }
          ]
        }
      },
      {
        "type": "named_parser",
        "id": { "type": "parser_id", "value": "regex" },
        "params": [],
        "body": {
          "type": "parser_steps",
          "steps": [
            { "type": "value_id", "value": "Regex" },
            { "infix": "Destructure" },
            { "type": "string_lit", "value": "/" },
            { "infix": "TakeRight" },
            {
              "type": "parser_apply",
              "id": { "type": "parser_id", "value": "regex_body" },
              "args": []
            },
            { "infix": "TakeLeft" },
            { "type": "string_lit", "value": "/" },
            { "infix": "Return" },
            {
              "type": "value_object",
              "value": [
                {
                  "type": "value_object_element",
                  "key": { "type": "string_lit", "value": "type" },
                  "value": { "type": "string_lit", "value": "regex_step" }
                },
                {
                  "type": "value_object_element",
                  "key": { "type": "string_lit", "value": "value" },
                  "value": { "type": "value_id", "value": "Regex" }
                }
              ]
            }
          ]
        }
      },
      {
        "type": "named_parser",
        "id": { "type": "parser_id", "value": "regex_body" },
        "params": [],
        "body": {
          "type": "parser_steps",
          "steps": [
            {
              "type": "group",
              "value": {
                "type": "parser_steps",
                "steps": [
                  {
                    "type": "value_array",
                    "value": [
                      {
                        "type": "value_array_element",
                        "value": { "type": "string_lit", "value": "\\" }
                      },
                      {
                        "type": "value_array_element",
                        "value": { "type": "value_id", "value": "C" }
                      }
                    ]
                  },
                  { "infix": "Destructure" },
                  {
                    "type": "parser_apply",
                    "id": { "type": "parser_id", "value": "two_chars" },
                    "args": []
                  },
                  { "infix": "And" },
                  { "type": "value_id", "value": "Regex" },
                  { "infix": "Destructure" },
                  {
                    "type": "parser_apply",
                    "id": { "type": "parser_id", "value": "const" },
                    "args": [
                      {
                        "type": "parser_steps",
                        "steps": [ { "type": "string_lit", "value": "\\" } ]
                      }
                    ]
                  },
                  { "infix": "Concat" },
                  {
                    "type": "parser_apply",
                    "id": { "type": "parser_id", "value": "const" },
                    "args": [
                      {
                        "type": "parser_steps",
                        "steps": [ { "type": "value_id", "value": "C" } ]
                      }
                    ]
                  },
                  { "infix": "Concat" },
                  {
                    "type": "parser_apply",
                    "id": { "type": "parser_id", "value": "regex_body" },
                    "args": []
                  },
                  { "infix": "Return" },
                  { "type": "value_id", "value": "Regex" }
                ]
              }
            },
            { "infix": "Or" },
            {
              "type": "group",
              "value": {
                "type": "parser_steps",
                "steps": [
                  {
                    "type": "value_array",
                    "value": [
                      {
                        "type": "value_array_element",
                        "value": { "type": "string_lit", "value": "/" }
                      },
                      {
                        "type": "value_array_element",
                        "value": { "type": "ignored_id" }
                      }
                    ]
                  },
                  { "infix": "Destructure" },
                  {
                    "type": "parser_apply",
                    "id": { "type": "parser_id", "value": "peek" },
                    "args": [
                      {
                        "type": "parser_steps",
                        "steps": [
                          {
                            "type": "parser_apply",
                            "id": { "type": "parser_id", "value": "two_chars" },
                            "args": []
                          }
                        ]
                      }
                    ]
                  },
                  { "infix": "Return" },
                  { "type": "string_lit", "value": "" }
                ]
              }
            },
            { "infix": "Or" },
            {
              "type": "group",
              "value": {
                "type": "parser_steps",
                "steps": [
                  { "type": "value_id", "value": "C" },
                  { "infix": "Destructure" },
                  {
                    "type": "parser_apply",
                    "id": { "type": "parser_id", "value": "char" },
                    "args": []
                  },
                  { "infix": "And" },
                  { "type": "value_id", "value": "Regex" },
                  { "infix": "Destructure" },
                  {
                    "type": "parser_apply",
                    "id": { "type": "parser_id", "value": "const" },
                    "args": [
                      {
                        "type": "parser_steps",
                        "steps": [ { "type": "value_id", "value": "C" } ]
                      }
                    ]
                  },
                  { "infix": "Concat" },
                  {
                    "type": "parser_apply",
                    "id": { "type": "parser_id", "value": "regex_body" },
                    "args": []
                  },
                  { "infix": "Return" },
                  { "type": "value_id", "value": "Regex" }
                ]
              }
            }
          ]
        }
      },
      {
        "type": "named_parser",
        "id": {
          "type": "parser_id",
          "value": "parser_apply_or_constant_literal"
        },
        "params": [],
        "body": {
          "type": "parser_steps",
          "steps": [
            { "type": "value_id", "value": "Id" },
            { "infix": "Destructure" },
            {
              "type": "parser_apply",
              "id": { "type": "parser_id", "value": "parser_id" },
              "args": []
            },
            { "infix": "And" },
            { "type": "value_id", "value": "Args" },
            { "infix": "Destructure" },
            {
              "type": "parser_apply",
              "id": { "type": "parser_id", "value": "default" },
              "args": [
                {
                  "type": "parser_steps",
                  "steps": [
                    {
                      "type": "parser_apply",
                      "id": {
                        "type": "parser_id",
                        "value": "parser_apply_args"
                      },
                      "args": []
                    }
                  ]
                },
                {
                  "type": "parser_steps",
                  "steps": [ { "type": "value_array", "value": [] } ]
                }
              ]
            },
            { "infix": "And" },
            { "type": "value_id", "value": "Step" },
            { "infix": "Destructure" },
            {
              "type": "group",
              "value": {
                "type": "parser_steps",
                "steps": [
                  {
                    "type": "group",
                    "value": {
                      "type": "parser_steps",
                      "steps": [
                        {
                          "type": "value_array",
                          "value": [
                            {
                              "type": "value_array_element",
                              "value": {
                                "type": "string_lit",
                                "value": "true"
                              }
                            },
                            {
                              "type": "value_array_element",
                              "value": { "type": "value_array", "value": [] }
                            }
                          ]
                        },
                        { "infix": "Destructure" },
                        {
                          "type": "parser_apply",
                          "id": { "type": "parser_id", "value": "const" },
                          "args": [
                            {
                              "type": "parser_steps",
                              "steps": [
                                {
                                  "type": "value_array",
                                  "value": [
                                    {
                                      "type": "value_array_element",
                                      "value": {
                                        "type": "value_id",
                                        "value": "Id"
                                      }
                                    },
                                    {
                                      "type": "value_array_element",
                                      "value": {
                                        "type": "value_id",
                                        "value": "Args"
                                      }
                                    }
                                  ]
                                }
                              ]
                            }
                          ]
                        },
                        { "infix": "Return" },
                        {
                          "type": "value_object",
                          "value": [
                            {
                              "type": "value_object_element",
                              "key": { "type": "string_lit", "value": "type" },
                              "value": {
                                "type": "string_lit",
                                "value": "true_lit"
                              }
                            }
                          ]
                        }
                      ]
                    }
                  },
                  { "infix": "Or" },
                  {
                    "type": "group",
                    "value": {
                      "type": "parser_steps",
                      "steps": [
                        {
                          "type": "value_array",
                          "value": [
                            {
                              "type": "value_array_element",
                              "value": {
                                "type": "string_lit",
                                "value": "false"
                              }
                            },
                            {
                              "type": "value_array_element",
                              "value": { "type": "value_array", "value": [] }
                            }
                          ]
                        },
                        { "infix": "Destructure" },
                        {
                          "type": "parser_apply",
                          "id": { "type": "parser_id", "value": "const" },
                          "args": [
                            {
                              "type": "parser_steps",
                              "steps": [
                                {
                                  "type": "value_array",
                                  "value": [
                                    {
                                      "type": "value_array_element",
                                      "value": {
                                        "type": "value_id",
                                        "value": "Id"
                                      }
                                    },
                                    {
                                      "type": "value_array_element",
                                      "value": {
                                        "type": "value_id",
                                        "value": "Args"
                                      }
                                    }
                                  ]
                                }
                              ]
                            }
                          ]
                        },
                        { "infix": "Return" },
                        {
                          "type": "value_object",
                          "value": [
                            {
                              "type": "value_object_element",
                              "key": { "type": "string_lit", "value": "type" },
                              "value": {
                                "type": "string_lit",
                                "value": "false_lit"
                              }
                            }
                          ]
                        }
                      ]
                    }
                  },
                  { "infix": "Or" },
                  {
                    "type": "group",
                    "value": {
                      "type": "parser_steps",
                      "steps": [
                        {
                          "type": "value_array",
                          "value": [
                            {
                              "type": "value_array_element",
                              "value": {
                                "type": "string_lit",
                                "value": "null"
                              }
                            },
                            {
                              "type": "value_array_element",
                              "value": { "type": "value_array", "value": [] }
                            }
                          ]
                        },
                        { "infix": "Destructure" },
                        {
                          "type": "parser_apply",
                          "id": { "type": "parser_id", "value": "const" },
                          "args": [
                            {
                              "type": "parser_steps",
                              "steps": [
                                {
                                  "type": "value_array",
                                  "value": [
                                    {
                                      "type": "value_array_element",
                                      "value": {
                                        "type": "value_id",
                                        "value": "Id"
                                      }
                                    },
                                    {
                                      "type": "value_array_element",
                                      "value": {
                                        "type": "value_id",
                                        "value": "Args"
                                      }
                                    }
                                  ]
                                }
                              ]
                            }
                          ]
                        },
                        { "infix": "Return" },
                        {
                          "type": "value_object",
                          "value": [
                            {
                              "type": "value_object_element",
                              "key": { "type": "string_lit", "value": "type" },
                              "value": {
                                "type": "string_lit",
                                "value": "null_lit"
                              }
                            }
                          ]
                        }
                      ]
                    }
                  },
                  { "infix": "Or" },
                  {
                    "type": "group",
                    "value": {
                      "type": "parser_steps",
                      "steps": [
                        {
                          "type": "parser_apply",
                          "id": { "type": "parser_id", "value": "succeed" },
                          "args": []
                        },
                        { "infix": "Return" },
                        {
                          "type": "value_object",
                          "value": [
                            {
                              "type": "value_object_element",
                              "key": { "type": "string_lit", "value": "type" },
                              "value": {
                                "type": "string_lit",
                                "value": "parser_apply"
                              }
                            },
                            {
                              "type": "value_object_element",
                              "key": { "type": "string_lit", "value": "id" },
                              "value": { "type": "value_id", "value": "Id" }
                            },
                            {
                              "type": "value_object_element",
                              "key": { "type": "string_lit", "value": "args" },
                              "value": { "type": "value_id", "value": "Args" }
                            }
                          ]
                        }
                      ]
                    }
                  }
                ]
              }
            },
            { "infix": "Return" },
            { "type": "value_id", "value": "Step" }
          ]
        }
      },
      {
        "type": "named_parser",
        "id": { "type": "parser_id", "value": "parser_apply_args" },
        "params": [],
        "body": {
          "type": "parser_steps",
          "steps": [
            { "type": "string_lit", "value": "(" },
            { "infix": "TakeRight" },
            {
              "type": "parser_apply",
              "id": { "type": "parser_id", "value": "array_sep" },
              "args": [
                {
                  "type": "parser_steps",
                  "steps": [
                    {
                      "type": "parser_apply",
                      "id": { "type": "parser_id", "value": "ws" },
                      "args": []
                    },
                    { "infix": "TakeRight" },
                    {
                      "type": "parser_apply",
                      "id": { "type": "parser_id", "value": "parser_steps" },
                      "args": []
                    },
                    { "infix": "TakeLeft" },
                    {
                      "type": "parser_apply",
                      "id": { "type": "parser_id", "value": "ws" },
                      "args": []
                    }
                  ]
                },
                {
                  "type": "parser_steps",
                  "steps": [ { "type": "string_lit", "value": "," } ]
                }
              ]
            },
            { "infix": "TakeLeft" },
            { "type": "string_lit", "value": ")" }
          ]
        }
      },
      {
        "type": "named_parser",
        "id": { "type": "parser_id", "value": "value_literal" },
        "params": [],
        "body": {
          "type": "parser_steps",
          "steps": [
            {
              "type": "parser_apply",
              "id": { "type": "parser_id", "value": "string_lit" },
              "args": []
            },
            { "infix": "Or" },
            {
              "type": "parser_apply",
              "id": { "type": "parser_id", "value": "true_lit" },
              "args": []
            },
            { "infix": "Or" },
            {
              "type": "parser_apply",
              "id": { "type": "parser_id", "value": "false_lit" },
              "args": []
            },
            { "infix": "Or" },
            {
              "type": "parser_apply",
              "id": { "type": "parser_id", "value": "null_lit" },
              "args": []
            },
            { "infix": "Or" },
            {
              "type": "parser_apply",
              "id": { "type": "parser_id", "value": "number_lit" },
              "args": []
            }
          ]
        }
      },
      {
        "type": "named_parser",
        "id": { "type": "parser_id", "value": "true_lit" },
        "params": [],
        "body": {
          "type": "parser_steps",
          "steps": [
            { "type": "string_lit", "value": "true" },
            { "infix": "Return" },
            {
              "type": "value_object",
              "value": [
                {
                  "type": "value_object_element",
                  "key": { "type": "string_lit", "value": "type" },
                  "value": { "type": "string_lit", "value": "true_lit" }
                }
              ]
            }
          ]
        }
      },
      {
        "type": "named_parser",
        "id": { "type": "parser_id", "value": "false_lit" },
        "params": [],
        "body": {
          "type": "parser_steps",
          "steps": [
            { "type": "string_lit", "value": "false" },
            { "infix": "Return" },
            {
              "type": "value_object",
              "value": [
                {
                  "type": "value_object_element",
                  "key": { "type": "string_lit", "value": "type" },
                  "value": { "type": "string_lit", "value": "false_lit" }
                }
              ]
            }
          ]
        }
      },
      {
        "type": "named_parser",
        "id": { "type": "parser_id", "value": "null_lit" },
        "params": [],
        "body": {
          "type": "parser_steps",
          "steps": [
            { "type": "string_lit", "value": "null" },
            { "infix": "Return" },
            {
              "type": "value_object",
              "value": [
                {
                  "type": "value_object_element",
                  "key": { "type": "string_lit", "value": "type" },
                  "value": { "type": "string_lit", "value": "null_lit" }
                }
              ]
            }
          ]
        }
      },
      {
        "type": "named_parser",
        "id": { "type": "parser_id", "value": "parser_literal" },
        "params": [],
        "body": {
          "type": "parser_steps",
          "steps": [
            {
              "type": "parser_apply",
              "id": { "type": "parser_id", "value": "string_lit" },
              "args": []
            },
            { "infix": "Or" },
            {
              "type": "parser_apply",
              "id": { "type": "parser_id", "value": "number_lit" },
              "args": []
            }
          ]
        }
      },
      {
        "type": "named_parser",
        "id": { "type": "parser_id", "value": "string_lit" },
        "params": [],
        "body": {
          "type": "parser_steps",
          "steps": [
            { "type": "value_id", "value": "Str" },
            { "infix": "Destructure" },
            {
              "type": "group",
              "value": {
                "type": "parser_steps",
                "steps": [
                  { "type": "string_lit", "value": "\"" },
                  { "infix": "TakeRight" },
                  {
                    "type": "parser_apply",
                    "id": { "type": "parser_id", "value": "string_content" },
                    "args": [
                      {
                        "type": "parser_steps",
                        "steps": [ { "type": "string_lit", "value": "\"" } ]
                      }
                    ]
                  },
                  { "infix": "TakeLeft" },
                  { "type": "string_lit", "value": "\"" }
                ]
              }
            },
            { "infix": "Or" },
            {
              "type": "group",
              "value": {
                "type": "parser_steps",
                "steps": [
                  { "type": "string_lit", "value": "'" },
                  { "infix": "TakeRight" },
                  {
                    "type": "parser_apply",
                    "id": { "type": "parser_id", "value": "string_content" },
                    "args": [
                      {
                        "type": "parser_steps",
                        "steps": [ { "type": "string_lit", "value": "'" } ]
                      }
                    ]
                  },
                  { "infix": "TakeLeft" },
                  { "type": "string_lit", "value": "'" }
                ]
              }
            },
            { "infix": "Return" },
            {
              "type": "value_object",
              "value": [
                {
                  "type": "value_object_element",
                  "key": { "type": "string_lit", "value": "type" },
                  "value": { "type": "string_lit", "value": "string_lit" }
                },
                {
                  "type": "value_object_element",
                  "key": { "type": "string_lit", "value": "value" },
                  "value": { "type": "value_id", "value": "Str" }
                }
              ]
            }
          ]
        }
      },
      {
        "type": "named_parser",
        "id": { "type": "parser_id", "value": "string_content" },
        "params": [ { "type": "value_id", "value": "Quote" } ],
        "body": {
          "type": "parser_steps",
          "steps": [
            {
              "type": "group",
              "value": {
                "type": "parser_steps",
                "steps": [
                  {
                    "type": "value_array",
                    "value": [
                      {
                        "type": "value_array_element",
                        "value": { "type": "string_lit", "value": "\\" }
                      },
                      {
                        "type": "value_array_element",
                        "value": { "type": "value_id", "value": "C" }
                      }
                    ]
                  },
                  { "infix": "Destructure" },
                  {
                    "type": "parser_apply",
                    "id": { "type": "parser_id", "value": "two_chars" },
                    "args": []
                  },
                  { "infix": "And" },
                  { "type": "value_id", "value": "Str" },
                  { "infix": "Destructure" },
                  {
                    "type": "parser_apply",
                    "id": { "type": "parser_id", "value": "const" },
                    "args": [
                      {
                        "type": "parser_steps",
                        "steps": [ { "type": "value_id", "value": "C" } ]
                      }
                    ]
                  },
                  { "infix": "Concat" },
                  {
                    "type": "parser_apply",
                    "id": { "type": "parser_id", "value": "string_content" },
                    "args": [
                      {
                        "type": "parser_steps",
                        "steps": [ { "type": "value_id", "value": "Quote" } ]
                      }
                    ]
                  },
                  { "infix": "Return" },
                  { "type": "value_id", "value": "Str" }
                ]
              }
            },
            { "infix": "Or" },
            {
              "type": "group",
              "value": {
                "type": "parser_steps",
                "steps": [
                  {
                    "type": "value_array",
                    "value": [
                      {
                        "type": "value_array_element",
                        "value": { "type": "value_id", "value": "Quote" }
                      },
                      {
                        "type": "value_array_element",
                        "value": { "type": "ignored_id" }
                      }
                    ]
                  },
                  { "infix": "Destructure" },
                  {
                    "type": "parser_apply",
                    "id": { "type": "parser_id", "value": "peek" },
                    "args": [
                      {
                        "type": "parser_steps",
                        "steps": [
                          {
                            "type": "parser_apply",
                            "id": { "type": "parser_id", "value": "two_chars" },
                            "args": []
                          }
                        ]
                      }
                    ]
                  },
                  { "infix": "Return" },
                  { "type": "string_lit", "value": "" }
                ]
              }
            },
            { "infix": "Or" },
            {
              "type": "group",
              "value": {
                "type": "parser_steps",
                "steps": [
                  { "type": "value_id", "value": "C" },
                  { "infix": "Destructure" },
                  {
                    "type": "parser_apply",
                    "id": { "type": "parser_id", "value": "char" },
                    "args": []
                  },
                  { "infix": "And" },
                  { "type": "value_id", "value": "Str" },
                  { "infix": "Destructure" },
                  {
                    "type": "parser_apply",
                    "id": { "type": "parser_id", "value": "const" },
                    "args": [
                      {
                        "type": "parser_steps",
                        "steps": [ { "type": "value_id", "value": "C" } ]
                      }
                    ]
                  },
                  { "infix": "Concat" },
                  {
                    "type": "parser_apply",
                    "id": { "type": "parser_id", "value": "string_content" },
                    "args": [
                      {
                        "type": "parser_steps",
                        "steps": [ { "type": "value_id", "value": "Quote" } ]
                      }
                    ]
                  },
                  { "infix": "Return" },
                  { "type": "value_id", "value": "Str" }
                ]
              }
            }
          ]
        }
      },
      {
        "type": "named_parser",
        "id": { "type": "parser_id", "value": "number_lit" },
        "params": [],
        "body": {
          "type": "parser_steps",
          "steps": [
            { "type": "value_id", "value": "N" },
            { "infix": "Destructure" },
            {
              "type": "parser_apply",
              "id": { "type": "parser_id", "value": "number" },
              "args": []
            },
            { "infix": "Return" },
            {
              "type": "value_object",
              "value": [
                {
                  "type": "value_object_element",
                  "key": { "type": "string_lit", "value": "type" },
                  "value": { "type": "string_lit", "value": "number_lit" }
                },
                {
                  "type": "value_object_element",
                  "key": { "type": "string_lit", "value": "value" },
                  "value": { "type": "value_id", "value": "N" }
                }
              ]
            }
          ]
        }
      },
      {
        "type": "named_parser",
        "id": { "type": "parser_id", "value": "value" },
        "params": [],
        "body": {
          "type": "parser_steps",
          "steps": [
            {
              "type": "parser_apply",
              "id": { "type": "parser_id", "value": "value_literal" },
              "args": []
            },
            { "infix": "Or" },
            {
              "type": "parser_apply",
              "id": { "type": "parser_id", "value": "value_array" },
              "args": []
            },
            { "infix": "Or" },
            {
              "type": "parser_apply",
              "id": { "type": "parser_id", "value": "value_object" },
              "args": []
            },
            { "infix": "Or" },
            {
              "type": "parser_apply",
              "id": { "type": "parser_id", "value": "value_id" },
              "args": []
            },
            { "infix": "Or" },
            {
              "type": "parser_apply",
              "id": { "type": "parser_id", "value": "ignored_id" },
              "args": []
            }
          ]
        }
      },
      {
        "type": "named_parser",
        "id": { "type": "parser_id", "value": "value_array" },
        "params": [],
        "body": {
          "type": "parser_steps",
          "steps": [
            { "type": "string_lit", "value": "[" },
            { "infix": "And" },
            {
              "type": "parser_apply",
              "id": { "type": "parser_id", "value": "ws" },
              "args": []
            },
            { "infix": "And" },
            { "type": "value_id", "value": "A" },
            { "infix": "Destructure" },
            {
              "type": "parser_apply",
              "id": { "type": "parser_id", "value": "default" },
              "args": [
                {
                  "type": "parser_steps",
                  "steps": [
                    {
                      "type": "parser_apply",
                      "id": { "type": "parser_id", "value": "array_sep" },
                      "args": [
                        {
                          "type": "parser_steps",
                          "steps": [
                            {
                              "type": "parser_apply",
                              "id": { "type": "parser_id", "value": "ws" },
                              "args": []
                            },
                            { "infix": "TakeRight" },
                            {
                              "type": "parser_apply",
                              "id": {
                                "type": "parser_id",
                                "value": "value_array_member"
                              },
                              "args": []
                            },
                            { "infix": "TakeLeft" },
                            {
                              "type": "parser_apply",
                              "id": { "type": "parser_id", "value": "ws" },
                              "args": []
                            }
                          ]
                        },
                        {
                          "type": "parser_steps",
                          "steps": [ { "type": "string_lit", "value": "," } ]
                        }
                      ]
                    }
                  ]
                },
                {
                  "type": "parser_steps",
                  "steps": [ { "type": "value_array", "value": [] } ]
                }
              ]
            },
            { "infix": "And" },
            {
              "type": "parser_apply",
              "id": { "type": "parser_id", "value": "ws" },
              "args": []
            },
            { "infix": "And" },
            { "type": "string_lit", "value": "]" },
            { "infix": "Return" },
            {
              "type": "value_object",
              "value": [
                {
                  "type": "value_object_element",
                  "key": { "type": "string_lit", "value": "type" },
                  "value": { "type": "string_lit", "value": "value_array" }
                },
                {
                  "type": "value_object_element",
                  "key": { "type": "string_lit", "value": "value" },
                  "value": { "type": "value_id", "value": "A" }
                }
              ]
            }
          ]
        }
      },
      {
        "type": "named_parser",
        "id": { "type": "parser_id", "value": "value_array_member" },
        "params": [],
        "body": {
          "type": "parser_steps",
          "steps": [
            {
              "type": "parser_apply",
              "id": { "type": "parser_id", "value": "value_array_spread" },
              "args": []
            },
            { "infix": "Or" },
            {
              "type": "parser_apply",
              "id": { "type": "parser_id", "value": "value_array_element" },
              "args": []
            }
          ]
        }
      },
      {
        "type": "named_parser",
        "id": { "type": "parser_id", "value": "value_array_spread" },
        "params": [],
        "body": {
          "type": "parser_steps",
          "steps": [
            { "type": "string_lit", "value": "..." },
            { "infix": "And" },
            { "type": "value_id", "value": "J" },
            { "infix": "Destructure" },
            {
              "type": "parser_apply",
              "id": { "type": "parser_id", "value": "value" },
              "args": []
            },
            { "infix": "Return" },
            {
              "type": "value_object",
              "value": [
                {
                  "type": "value_object_element",
                  "key": { "type": "string_lit", "value": "type" },
                  "value": {
                    "type": "string_lit",
                    "value": "value_array_spread"
                  }
                },
                {
                  "type": "value_object_element",
                  "key": { "type": "string_lit", "value": "value" },
                  "value": { "type": "value_id", "value": "J" }
                }
              ]
            }
          ]
        }
      },
      {
        "type": "named_parser",
        "id": { "type": "parser_id", "value": "value_array_element" },
        "params": [],
        "body": {
          "type": "parser_steps",
          "steps": [
            { "type": "value_id", "value": "J" },
            { "infix": "Destructure" },
            {
              "type": "parser_apply",
              "id": { "type": "parser_id", "value": "value" },
              "args": []
            },
            { "infix": "Return" },
            {
              "type": "value_object",
              "value": [
                {
                  "type": "value_object_element",
                  "key": { "type": "string_lit", "value": "type" },
                  "value": {
                    "type": "string_lit",
                    "value": "value_array_element"
                  }
                },
                {
                  "type": "value_object_element",
                  "key": { "type": "string_lit", "value": "value" },
                  "value": { "type": "value_id", "value": "J" }
                }
              ]
            }
          ]
        }
      },
      {
        "type": "named_parser",
        "id": { "type": "parser_id", "value": "value_object" },
        "params": [],
        "body": {
          "type": "parser_steps",
          "steps": [
            { "type": "string_lit", "value": "{" },
            { "infix": "And" },
            {
              "type": "parser_apply",
              "id": { "type": "parser_id", "value": "ws" },
              "args": []
            },
            { "infix": "And" },
            { "type": "value_id", "value": "O" },
            { "infix": "Destructure" },
            {
              "type": "parser_apply",
              "id": { "type": "parser_id", "value": "default" },
              "args": [
                {
                  "type": "parser_steps",
                  "steps": [
                    {
                      "type": "parser_apply",
                      "id": { "type": "parser_id", "value": "array_sep" },
                      "args": [
                        {
                          "type": "parser_steps",
                          "steps": [
                            {
                              "type": "parser_apply",
                              "id": { "type": "parser_id", "value": "ws" },
                              "args": []
                            },
                            { "infix": "TakeRight" },
                            {
                              "type": "parser_apply",
                              "id": {
                                "type": "parser_id",
                                "value": "value_object_member"
                              },
                              "args": []
                            },
                            { "infix": "TakeLeft" },
                            {
                              "type": "parser_apply",
                              "id": { "type": "parser_id", "value": "ws" },
                              "args": []
                            }
                          ]
                        },
                        {
                          "type": "parser_steps",
                          "steps": [ { "type": "string_lit", "value": "," } ]
                        }
                      ]
                    }
                  ]
                },
                {
                  "type": "parser_steps",
                  "steps": [ { "type": "value_array", "value": [] } ]
                }
              ]
            },
            { "infix": "And" },
            {
              "type": "parser_apply",
              "id": { "type": "parser_id", "value": "ws" },
              "args": []
            },
            { "infix": "And" },
            { "type": "string_lit", "value": "}" },
            { "infix": "Return" },
            {
              "type": "value_object",
              "value": [
                {
                  "type": "value_object_element",
                  "key": { "type": "string_lit", "value": "type" },
                  "value": { "type": "string_lit", "value": "value_object" }
                },
                {
                  "type": "value_object_element",
                  "key": { "type": "string_lit", "value": "value" },
                  "value": { "type": "value_id", "value": "O" }
                }
              ]
            }
          ]
        }
      },
      {
        "type": "named_parser",
        "id": { "type": "parser_id", "value": "value_object_member" },
        "params": [],
        "body": {
          "type": "parser_steps",
          "steps": [
            {
              "type": "parser_apply",
              "id": { "type": "parser_id", "value": "value_object_spread" },
              "args": []
            },
            { "infix": "Or" },
            {
              "type": "parser_apply",
              "id": { "type": "parser_id", "value": "value_object_pair" },
              "args": []
            }
          ]
        }
      },
      {
        "type": "named_parser",
        "id": { "type": "parser_id", "value": "value_object_spread" },
        "params": [],
        "body": {
          "type": "parser_steps",
          "steps": [
            { "type": "string_lit", "value": "..." },
            { "infix": "And" },
            { "type": "value_id", "value": "J" },
            { "infix": "Destructure" },
            {
              "type": "parser_apply",
              "id": { "type": "parser_id", "value": "value" },
              "args": []
            },
            { "infix": "Return" },
            {
              "type": "value_object",
              "value": [
                {
                  "type": "value_object_element",
                  "key": { "type": "string_lit", "value": "type" },
                  "value": {
                    "type": "string_lit",
                    "value": "value_object_spread"
                  }
                },
                {
                  "type": "value_object_element",
                  "key": { "type": "string_lit", "value": "value" },
                  "value": { "type": "value_id", "value": "J" }
                }
              ]
            }
          ]
        }
      },
      {
        "type": "named_parser",
        "id": { "type": "parser_id", "value": "value_object_pair" },
        "params": [],
        "body": {
          "type": "parser_steps",
          "steps": [
            { "type": "value_id", "value": "Key" },
            { "infix": "Destructure" },
            {
              "type": "parser_apply",
              "id": { "type": "parser_id", "value": "string_lit" },
              "args": []
            },
            { "infix": "Or" },
            {
              "type": "parser_apply",
              "id": { "type": "parser_id", "value": "value_id" },
              "args": []
            },
            { "infix": "And" },
            {
              "type": "parser_apply",
              "id": { "type": "parser_id", "value": "ws" },
              "args": []
            },
            { "infix": "And" },
            { "type": "string_lit", "value": ":" },
            { "infix": "And" },
            {
              "type": "parser_apply",
              "id": { "type": "parser_id", "value": "ws" },
              "args": []
            },
            { "infix": "And" },
            { "type": "value_id", "value": "Value" },
            { "infix": "Destructure" },
            {
              "type": "parser_apply",
              "id": { "type": "parser_id", "value": "value" },
              "args": []
            },
            { "infix": "Return" },
            {
              "type": "value_object",
              "value": [
                {
                  "type": "value_object_element",
                  "key": { "type": "string_lit", "value": "type" },
                  "value": {
                    "type": "string_lit",
                    "value": "value_object_element"
                  }
                },
                {
                  "type": "value_object_element",
                  "key": { "type": "string_lit", "value": "key" },
                  "value": { "type": "value_id", "value": "Key" }
                },
                {
                  "type": "value_object_element",
                  "key": { "type": "string_lit", "value": "value" },
                  "value": { "type": "value_id", "value": "Value" }
                }
              ]
            }
          ]
        }
      },
      {
        "type": "named_parser",
        "id": { "type": "parser_id", "value": "parser_id" },
        "params": [],
        "body": {
          "type": "parser_steps",
          "steps": [
            { "type": "value_id", "value": "Id" },
            { "infix": "Destructure" },
            { "type": "regex_step", "value": "_*[a-z]+[a-zA-Z0-9_]*" },
            { "infix": "Return" },
            {
              "type": "value_object",
              "value": [
                {
                  "type": "value_object_element",
                  "key": { "type": "string_lit", "value": "type" },
                  "value": { "type": "string_lit", "value": "parser_id" }
                },
                {
                  "type": "value_object_element",
                  "key": { "type": "string_lit", "value": "value" },
                  "value": { "type": "value_id", "value": "Id" }
                }
              ]
            }
          ]
        }
      },
      {
        "type": "named_parser",
        "id": { "type": "parser_id", "value": "value_id" },
        "params": [],
        "body": {
          "type": "parser_steps",
          "steps": [
            { "type": "value_id", "value": "Id" },
            { "infix": "Destructure" },
            { "type": "regex_step", "value": "_*[A-Z]+[a-zA-Z0-9_]*" },
            { "infix": "Return" },
            {
              "type": "value_object",
              "value": [
                {
                  "type": "value_object_element",
                  "key": { "type": "string_lit", "value": "type" },
                  "value": { "type": "string_lit", "value": "value_id" }
                },
                {
                  "type": "value_object_element",
                  "key": { "type": "string_lit", "value": "value" },
                  "value": { "type": "value_id", "value": "Id" }
                }
              ]
            }
          ]
        }
      },
      {
        "type": "named_parser",
        "id": { "type": "parser_id", "value": "ignored_id" },
        "params": [],
        "body": {
          "type": "parser_steps",
          "steps": [
            { "type": "string_lit", "value": "_" },
            { "infix": "Return" },
            {
              "type": "value_object",
              "value": [
                {
                  "type": "value_object_element",
                  "key": { "type": "string_lit", "value": "type" },
                  "value": { "type": "string_lit", "value": "ignored_id" }
                }
              ]
            }
          ]
        }
      },
      {
        "type": "named_parser",
        "id": { "type": "parser_id", "value": "id" },
        "params": [],
        "body": {
          "type": "parser_steps",
          "steps": [
            {
              "type": "parser_apply",
              "id": { "type": "parser_id", "value": "parser_id" },
              "args": []
            },
            { "infix": "Or" },
            {
              "type": "parser_apply",
              "id": { "type": "parser_id", "value": "value_id" },
              "args": []
            },
            { "infix": "Or" },
            {
              "type": "parser_apply",
              "id": { "type": "parser_id", "value": "ignored_id" },
              "args": []
            }
          ]
        }
      },
      {
        "type": "named_parser",
        "id": { "type": "parser_id", "value": "two_chars" },
        "params": [],
        "body": {
          "type": "parser_steps",
          "steps": [
            { "type": "value_id", "value": "A" },
            { "infix": "Destructure" },
            {
              "type": "parser_apply",
              "id": { "type": "parser_id", "value": "default" },
              "args": [
                {
                  "type": "parser_steps",
                  "steps": [
                    {
                      "type": "parser_apply",
                      "id": { "type": "parser_id", "value": "char" },
                      "args": []
                    }
                  ]
                },
                {
                  "type": "parser_steps",
                  "steps": [
                    {
                      "type": "parser_apply",
                      "id": { "type": "parser_id", "value": "null" },
                      "args": []
                    }
                  ]
                }
              ]
            },
            { "infix": "And" },
            { "type": "value_id", "value": "B" },
            { "infix": "Destructure" },
            {
              "type": "parser_apply",
              "id": { "type": "parser_id", "value": "default" },
              "args": [
                {
                  "type": "parser_steps",
                  "steps": [
                    {
                      "type": "parser_apply",
                      "id": { "type": "parser_id", "value": "char" },
                      "args": []
                    }
                  ]
                },
                {
                  "type": "parser_steps",
                  "steps": [
                    {
                      "type": "parser_apply",
                      "id": { "type": "parser_id", "value": "null" },
                      "args": []
                    }
                  ]
                }
              ]
            },
            { "infix": "Return" },
            {
              "type": "value_array",
              "value": [
                {
                  "type": "value_array_element",
                  "value": { "type": "value_id", "value": "A" }
                },
                {
                  "type": "value_array_element",
                  "value": { "type": "value_id", "value": "B" }
                }
              ]
            }
          ]
        }
      },
      {
        "type": "named_parser",
        "id": { "type": "parser_id", "value": "flattened" },
        "params": [ { "type": "parser_id", "value": "array" } ],
        "body": {
          "type": "parser_steps",
          "steps": [
            { "type": "value_id", "value": "A" },
            { "infix": "Destructure" },
            {
              "type": "parser_apply",
              "id": { "type": "parser_id", "value": "array" },
              "args": []
            },
            { "infix": "And" },
            { "type": "value_id", "value": "Flat" },
            { "infix": "Destructure" },
            {
              "type": "parser_apply",
              "id": { "type": "parser_id", "value": "flatten_array" },
              "args": [
                {
                  "type": "parser_steps",
                  "steps": [ { "type": "value_id", "value": "A" } ]
                }
              ]
            },
            { "infix": "Return" },
            { "type": "value_id", "value": "Flat" }
          ]
        }
      },
      {
        "type": "named_parser",
        "id": { "type": "parser_id", "value": "flatten_array" },
        "params": [ { "type": "value_id", "value": "A" } ],
        "body": {
          "type": "parser_steps",
          "steps": [
            {
              "type": "group",
              "value": {
                "type": "parser_steps",
                "steps": [
                  {
                    "type": "value_array",
                    "value": [
                      {
                        "type": "value_array_element",
                        "value": { "type": "value_id", "value": "A1" }
                      },
                      {
                        "type": "value_array_spread",
                        "value": { "type": "value_id", "value": "Rest" }
                      }
                    ]
                  },
                  { "infix": "Destructure" },
                  {
                    "type": "parser_apply",
                    "id": { "type": "parser_id", "value": "const" },
                    "args": [
                      {
                        "type": "parser_steps",
                        "steps": [ { "type": "value_id", "value": "A" } ]
                      }
                    ]
                  },
                  { "infix": "And" },
                  { "type": "value_id", "value": "FlatRest" },
                  { "infix": "Destructure" },
                  {
                    "type": "parser_apply",
                    "id": { "type": "parser_id", "value": "flatten_array" },
                    "args": [
                      {
                        "type": "parser_steps",
                        "steps": [ { "type": "value_id", "value": "Rest" } ]
                      }
                    ]
                  },
                  { "infix": "Return" },
                  {
                    "type": "value_array",
                    "value": [
                      {
                        "type": "value_array_spread",
                        "value": { "type": "value_id", "value": "A1" }
                      },
                      {
                        "type": "value_array_spread",
                        "value": { "type": "value_id", "value": "FlatRest" }
                      }
                    ]
                  }
                ]
              }
            },
            { "infix": "Or" },
            {
              "type": "parser_apply",
              "id": { "type": "parser_id", "value": "const" },
              "args": [
                {
                  "type": "parser_steps",
                  "steps": [ { "type": "value_array", "value": [] } ]
                }
              ]
            }
          ]
        }
      }
    ]
  }

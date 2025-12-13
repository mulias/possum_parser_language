  $ possum $TESTDIR/possum.possum -i '123'
  {
    "type": "program",
    "value": [
      {
        "type": "main_parser",
        "value": {"type": "number", "value": 123}
      }
    ]
  }

  $ possum $TESTDIR/possum.possum -i '"a" + "b" + "c"'
  {
    "type": "program",
    "value": [
      {
        "type": "main_parser",
        "value": {
          "type": "merge",
          "left": {
            "type": "merge",
            "left": {"type": "string", "value": "a"},
            "right": {"type": "string", "value": "b"}
          },
          "right": {"type": "string", "value": "c"}
        }
      }
    ]
  }

  $ possum $TESTDIR/possum.possum -i '"a" + "b" & num -> N'
  {
    "type": "program",
    "value": [
      {
        "type": "main_parser",
        "value": {
          "type": "and",
          "left": {
            "type": "merge",
            "left": {"type": "string", "value": "a"},
            "right": {"type": "string", "value": "b"}
          },
          "right": {
            "type": "destructure",
            "left": {"type": "parser_variable", "name": "num", "is_meta": false, "is_underscored": false},
            "right": {"type": "value_variable", "name": "N", "is_meta": false, "is_underscored": false}
          }
        }
      }
    ]
  }

  $ possum $TESTDIR/possum.possum -i "'ab\'c'"
  {
    "type": "program",
    "value": [
      {
        "type": "main_parser",
        "value": {"type": "string", "value": "ab\\'c"}
      }
    ]
  }

  $ possum $TESTDIR/possum.possum -i '-37'
  {
    "type": "program",
    "value": [
      {
        "type": "main_parser",
        "value": {
          "type": "negate",
          "prefixed": {"type": "number", "value": 37}
        }
      }
    ]
  }

  $ possum $TESTDIR/possum.possum -i 'array(int)'
  {
    "type": "program",
    "value": [
      {
        "type": "main_parser",
        "value": {
          "args": [
            {"type": "parser_variable", "name": "int", "is_meta": false, "is_underscored": false}
          ],
          "type": "call_function",
          "postfixed": {"type": "parser_variable", "name": "array", "is_meta": false, "is_underscored": false}
        }
      }
    ]
  }

  $ possum $TESTDIR/possum.possum -i '"one" | "two"'
  {
    "type": "program",
    "value": [
      {
        "type": "main_parser",
        "value": {
          "type": "or",
          "left": {"type": "string", "value": "one"},
          "right": {"type": "string", "value": "two"}
        }
      }
    ]
  }

  $ possum $TESTDIR/possum.possum -i '"one" | "two" # comment'
  {
    "type": "program",
    "value": [
      {
        "type": "main_parser",
        "value": {
          "type": "or",
          "left": {"type": "string", "value": "one"},
          "right": {"type": "string", "value": "two"}
        }
      }
    ]
  }

  $ possum $TESTDIR/possum.possum $TESTDIR/possum.possum
  {
    "type": "program",
    "value": [
      {
        "type": "main_parser",
        "value": {
          "args": [
            {"type": "parser_variable", "name": "program", "is_meta": false, "is_underscored": false}
          ],
          "type": "call_function",
          "postfixed": {"type": "parser_variable", "name": "input", "is_meta": false, "is_underscored": false}
        }
      },
      {
        "type": "named_function",
        "ident": {"type": "parser_variable", "name": "program", "is_meta": false, "is_underscored": false},
        "params": [],
        "body": {
          "args": [
            {
              "args": [
                {
                  "args": [
                    {"type": "parser_variable", "name": "statement", "is_meta": false, "is_underscored": false}
                  ],
                  "type": "call_function",
                  "postfixed": {"type": "parser_variable", "name": "w_arround", "is_meta": false, "is_underscored": false}
                }
              ],
              "type": "call_function",
              "postfixed": {"type": "parser_variable", "name": "array", "is_meta": false, "is_underscored": false}
            },
            {
              "type": "value_label",
              "prefixed": {"type": "string", "value": "program"}
            }
          ],
          "type": "call_function",
          "postfixed": {"type": "parser_variable", "name": "ast.node", "is_meta": false, "is_underscored": false}
        }
      },
      {
        "type": "named_function",
        "ident": {"type": "parser_variable", "name": "statement", "is_meta": false, "is_underscored": false},
        "params": [],
        "body": {
          "type": "take_left",
          "left": {
            "type": "or",
            "left": {"type": "parser_variable", "name": "named_function", "is_meta": false, "is_underscored": false},
            "right": {"type": "parser_variable", "name": "main_parser", "is_meta": false, "is_underscored": false}
          },
          "right": {"type": "parser_variable", "name": "statement_sep", "is_meta": false, "is_underscored": false}
        }
      },
      {
        "type": "named_function",
        "ident": {"type": "parser_variable", "name": "statement_sep", "is_meta": false, "is_underscored": false},
        "params": [],
        "body": {
          "type": "or",
          "left": {
            "type": "or",
            "left": {"type": "parser_variable", "name": "nl", "is_meta": false, "is_underscored": false},
            "right": {
              "args": [
                {"type": "string", "value": ";"}
              ],
              "type": "call_function",
              "postfixed": {"type": "parser_variable", "name": "w_arround", "is_meta": false, "is_underscored": false}
            }
          },
          "right": {
            "args": [
              {"type": "parser_variable", "name": "end", "is_meta": false, "is_underscored": false}
            ],
            "type": "call_function",
            "postfixed": {"type": "parser_variable", "name": "w_arround", "is_meta": false, "is_underscored": false}
          }
        }
      },
      {
        "type": "named_function",
        "ident": {"type": "parser_variable", "name": "named_function", "is_meta": false, "is_underscored": false},
        "params": [],
        "body": {
          "type": "and",
          "left": {
            "type": "and",
            "left": {
              "type": "and",
              "left": {
                "type": "and",
                "left": {
                  "type": "destructure",
                  "left": {
                    "type": "or",
                    "left": {"type": "parser_variable", "name": "parser_variable_node", "is_meta": false, "is_underscored": false},
                    "right": {"type": "parser_variable", "name": "value_variable_node", "is_meta": false, "is_underscored": false}
                  },
                  "right": {"type": "value_variable", "name": "Ident", "is_meta": false, "is_underscored": false}
                },
                "right": {"type": "parser_variable", "name": "w", "is_meta": false, "is_underscored": false}
              },
              "right": {
                "type": "destructure",
                "left": {
                  "args": [
                    {"type": "parser_variable", "name": "function_args_or_params", "is_meta": false, "is_underscored": false},
                    {
                      "type": "array",
                      "value": []
                    }
                  ],
                  "type": "call_function",
                  "postfixed": {"type": "parser_variable", "name": "default", "is_meta": false, "is_underscored": false}
                },
                "right": {"type": "value_variable", "name": "Params", "is_meta": false, "is_underscored": false}
              }
            },
            "right": {"type": "parser_variable", "name": "w", "is_meta": false, "is_underscored": false}
          },
          "right": {
            "type": "return",
            "left": {
              "type": "destructure",
              "left": {
                "type": "take_right",
                "left": {"type": "string", "value": "="},
                "right": {"type": "parser_variable", "name": "expr", "is_meta": false, "is_underscored": false}
              },
              "right": {"type": "value_variable", "name": "Body", "is_meta": false, "is_underscored": false}
            },
            "right": {
              "type": "object",
              "value": [
                [
                  {"type": "string", "value": "type"},
                  {"type": "string", "value": "named_function"}
                ],
                [
                  {"type": "string", "value": "ident"},
                  {"type": "value_variable", "name": "Ident", "is_meta": false, "is_underscored": false}
                ],
                [
                  {"type": "string", "value": "params"},
                  {"type": "value_variable", "name": "Params", "is_meta": false, "is_underscored": false}
                ],
                [
                  {"type": "string", "value": "body"},
                  {"type": "value_variable", "name": "Body", "is_meta": false, "is_underscored": false}
                ]
              ]
            }
          }
        }
      },
      {
        "type": "named_function",
        "ident": {"type": "parser_variable", "name": "main_parser", "is_meta": false, "is_underscored": false},
        "params": [],
        "body": {
          "args": [
            {"type": "parser_variable", "name": "expr", "is_meta": false, "is_underscored": false},
            {
              "type": "value_label",
              "prefixed": {"type": "string", "value": "main_parser"}
            }
          ],
          "type": "call_function",
          "postfixed": {"type": "parser_variable", "name": "ast.node", "is_meta": false, "is_underscored": false}
        }
      },
      {
        "type": "named_function",
        "ident": {"type": "parser_variable", "name": "comment", "is_meta": false, "is_underscored": false},
        "params": [],
        "body": {
          "type": "take_right",
          "left": {"type": "string", "value": "#"},
          "right": {
            "args": [
              {
                "type": "or",
                "left": {"type": "parser_variable", "name": "nl", "is_meta": false, "is_underscored": false},
                "right": {"type": "parser_variable", "name": "end", "is_meta": false, "is_underscored": false}
              }
            ],
            "type": "call_function",
            "postfixed": {"type": "parser_variable", "name": "chars_until", "is_meta": false, "is_underscored": false}
          }
        }
      },
      {
        "type": "named_function",
        "ident": {"type": "parser_variable", "name": "w", "is_meta": false, "is_underscored": false},
        "params": [],
        "body": {
          "args": [
            {
              "type": "or",
              "left": {"type": "parser_variable", "name": "comment", "is_meta": false, "is_underscored": false},
              "right": {"type": "parser_variable", "name": "whitespace", "is_meta": false, "is_underscored": false}
            }
          ],
          "type": "call_function",
          "postfixed": {"type": "parser_variable", "name": "maybe_many", "is_meta": false, "is_underscored": false}
        }
      },
      {
        "type": "named_function",
        "ident": {"type": "parser_variable", "name": "w_arround", "is_meta": false, "is_underscored": false},
        "params": [
          {"type": "parser_variable", "name": "p", "is_meta": false, "is_underscored": false}
        ],
        "body": {
          "args": [
            {"type": "parser_variable", "name": "p", "is_meta": false, "is_underscored": false},
            {"type": "parser_variable", "name": "w", "is_meta": false, "is_underscored": false}
          ],
          "type": "call_function",
          "postfixed": {"type": "parser_variable", "name": "surround", "is_meta": false, "is_underscored": false}
        }
      },
      {
        "type": "named_function",
        "ident": {"type": "parser_variable", "name": "expr", "is_meta": false, "is_underscored": false},
        "params": [],
        "body": {
          "args": [
            {
              "type": "take_right",
              "left": {"type": "parser_variable", "name": "w", "is_meta": false, "is_underscored": false},
              "right": {"type": "parser_variable", "name": "operand", "is_meta": false, "is_underscored": false}
            },
            {
              "args": [
                {"type": "parser_variable", "name": "prefix", "is_meta": false, "is_underscored": false}
              ],
              "type": "call_function",
              "postfixed": {"type": "parser_variable", "name": "w_arround", "is_meta": false, "is_underscored": false}
            },
            {
              "args": [
                {"type": "parser_variable", "name": "infix", "is_meta": false, "is_underscored": false}
              ],
              "type": "call_function",
              "postfixed": {"type": "parser_variable", "name": "w_arround", "is_meta": false, "is_underscored": false}
            },
            {
              "type": "take_right",
              "left": {"type": "parser_variable", "name": "w", "is_meta": false, "is_underscored": false},
              "right": {"type": "parser_variable", "name": "postfix", "is_meta": false, "is_underscored": false}
            }
          ],
          "type": "call_function",
          "postfixed": {"type": "parser_variable", "name": "ast.with_operator_precedence", "is_meta": false, "is_underscored": false}
        }
      },
      {
        "type": "named_function",
        "ident": {"type": "parser_variable", "name": "operand", "is_meta": false, "is_underscored": false},
        "params": [],
        "body": {
          "type": "or",
          "left": {
            "type": "or",
            "left": {
              "type": "or",
              "left": {
                "type": "or",
                "left": {
                  "type": "or",
                  "left": {
                    "type": "or",
                    "left": {
                      "type": "or",
                      "left": {
                        "type": "or",
                        "left": {
                          "type": "or",
                          "left": {
                            "type": "or",
                            "left": {"type": "parser_variable", "name": "grouped_expr", "is_meta": false, "is_underscored": false},
                            "right": {"type": "parser_variable", "name": "boolean_node", "is_meta": false, "is_underscored": false}
                          },
                          "right": {"type": "parser_variable", "name": "null_node", "is_meta": false, "is_underscored": false}
                        },
                        "right": {"type": "parser_variable", "name": "string_node", "is_meta": false, "is_underscored": false}
                      },
                      "right": {"type": "parser_variable", "name": "template_string_node", "is_meta": false, "is_underscored": false}
                    },
                    "right": {"type": "parser_variable", "name": "number_node", "is_meta": false, "is_underscored": false}
                  },
                  "right": {"type": "parser_variable", "name": "parser_variable_node", "is_meta": false, "is_underscored": false}
                },
                "right": {"type": "parser_variable", "name": "value_variable_node", "is_meta": false, "is_underscored": false}
              },
              "right": {"type": "parser_variable", "name": "underscore_variable_node", "is_meta": false, "is_underscored": false}
            },
            "right": {"type": "parser_variable", "name": "array_node", "is_meta": false, "is_underscored": false}
          },
          "right": {"type": "parser_variable", "name": "object_node", "is_meta": false, "is_underscored": false}
        }
      },
      {
        "type": "named_function",
        "ident": {"type": "parser_variable", "name": "prefix", "is_meta": false, "is_underscored": false},
        "params": [],
        "body": {
          "type": "or",
          "left": {
            "type": "or",
            "left": {
              "type": "or",
              "left": {
                "args": [
                  {"type": "string", "value": "$"},
                  {
                    "type": "value_label",
                    "prefixed": {"type": "string", "value": "value_label"}
                  },
                  {
                    "type": "value_label",
                    "prefixed": {"type": "number", "value": 9}
                  }
                ],
                "type": "call_function",
                "postfixed": {"type": "parser_variable", "name": "ast.prefix_node", "is_meta": false, "is_underscored": false}
              },
              "right": {
                "args": [
                  {"type": "string", "value": "..."},
                  {
                    "type": "value_label",
                    "prefixed": {"type": "string", "value": "spread"}
                  },
                  {
                    "type": "value_label",
                    "prefixed": {"type": "number", "value": 8}
                  }
                ],
                "type": "call_function",
                "postfixed": {"type": "parser_variable", "name": "ast.prefix_node", "is_meta": false, "is_underscored": false}
              }
            },
            "right": {
              "args": [
                {"type": "string", "value": ".."},
                {
                  "type": "value_label",
                  "prefixed": {"type": "string", "value": "upper_bounded_range"}
                },
                {
                  "type": "value_label",
                  "prefixed": {"type": "number", "value": 7}
                }
              ],
              "type": "call_function",
              "postfixed": {"type": "parser_variable", "name": "ast.prefix_node", "is_meta": false, "is_underscored": false}
            }
          },
          "right": {
            "args": [
              {"type": "string", "value": "-"},
              {
                "type": "value_label",
                "prefixed": {"type": "string", "value": "negate"}
              },
              {
                "type": "value_label",
                "prefixed": {"type": "number", "value": 6}
              }
            ],
            "type": "call_function",
            "postfixed": {"type": "parser_variable", "name": "ast.prefix_node", "is_meta": false, "is_underscored": false}
          }
        }
      },
      {
        "type": "named_function",
        "ident": {"type": "parser_variable", "name": "infix", "is_meta": false, "is_underscored": false},
        "params": [],
        "body": {
          "type": "or",
          "left": {
            "type": "or",
            "left": {
              "type": "or",
              "left": {
                "type": "or",
                "left": {
                  "type": "or",
                  "left": {
                    "type": "or",
                    "left": {
                      "type": "or",
                      "left": {
                        "type": "or",
                        "left": {
                          "type": "or",
                          "left": {
                            "type": "or",
                            "left": {
                              "type": "or",
                              "left": {
                                "type": "or",
                                "left": {
                                  "args": [
                                    {"type": "string", "value": ".."},
                                    {
                                      "type": "value_label",
                                      "prefixed": {"type": "string", "value": "range"}
                                    },
                                    {
                                      "type": "value_label",
                                      "prefixed": {"type": "number", "value": 5}
                                    },
                                    {
                                      "type": "value_label",
                                      "prefixed": {"type": "number", "value": 5.5}
                                    }
                                  ],
                                  "type": "call_function",
                                  "postfixed": {"type": "parser_variable", "name": "ast.infix_node", "is_meta": false, "is_underscored": false}
                                },
                                "right": {
                                  "args": [
                                    {"type": "string", "value": "|"},
                                    {
                                      "type": "value_label",
                                      "prefixed": {"type": "string", "value": "or"}
                                    },
                                    {
                                      "type": "value_label",
                                      "prefixed": {"type": "number", "value": 4}
                                    },
                                    {
                                      "type": "value_label",
                                      "prefixed": {"type": "number", "value": 4.5}
                                    }
                                  ],
                                  "type": "call_function",
                                  "postfixed": {"type": "parser_variable", "name": "ast.infix_node", "is_meta": false, "is_underscored": false}
                                }
                              },
                              "right": {
                                "args": [
                                  {"type": "string", "value": ">"},
                                  {
                                    "type": "value_label",
                                    "prefixed": {"type": "string", "value": "take_right"}
                                  },
                                  {
                                    "type": "value_label",
                                    "prefixed": {"type": "number", "value": 4}
                                  },
                                  {
                                    "type": "value_label",
                                    "prefixed": {"type": "number", "value": 4.5}
                                  }
                                ],
                                "type": "call_function",
                                "postfixed": {"type": "parser_variable", "name": "ast.infix_node", "is_meta": false, "is_underscored": false}
                              }
                            },
                            "right": {
                              "args": [
                                {"type": "string", "value": "<"},
                                {
                                  "type": "value_label",
                                  "prefixed": {"type": "string", "value": "take_left"}
                                },
                                {
                                  "type": "value_label",
                                  "prefixed": {"type": "number", "value": 4}
                                },
                                {
                                  "type": "value_label",
                                  "prefixed": {"type": "number", "value": 4.5}
                                }
                              ],
                              "type": "call_function",
                              "postfixed": {"type": "parser_variable", "name": "ast.infix_node", "is_meta": false, "is_underscored": false}
                            }
                          },
                          "right": {
                            "args": [
                              {"type": "string", "value": "+"},
                              {
                                "type": "value_label",
                                "prefixed": {"type": "string", "value": "merge"}
                              },
                              {
                                "type": "value_label",
                                "prefixed": {"type": "number", "value": 4}
                              },
                              {
                                "type": "value_label",
                                "prefixed": {"type": "number", "value": 4.5}
                              }
                            ],
                            "type": "call_function",
                            "postfixed": {"type": "parser_variable", "name": "ast.infix_node", "is_meta": false, "is_underscored": false}
                          }
                        },
                        "right": {
                          "args": [
                            {"type": "string", "value": "!"},
                            {
                              "type": "value_label",
                              "prefixed": {"type": "string", "value": "backtrack"}
                            },
                            {
                              "type": "value_label",
                              "prefixed": {"type": "number", "value": 4}
                            },
                            {
                              "type": "value_label",
                              "prefixed": {"type": "number", "value": 4.5}
                            }
                          ],
                          "type": "call_function",
                          "postfixed": {"type": "parser_variable", "name": "ast.infix_node", "is_meta": false, "is_underscored": false}
                        }
                      },
                      "right": {
                        "args": [
                          {"type": "string", "value": "->"},
                          {
                            "type": "value_label",
                            "prefixed": {"type": "string", "value": "destructure"}
                          },
                          {
                            "type": "value_label",
                            "prefixed": {"type": "number", "value": 4}
                          },
                          {
                            "type": "value_label",
                            "prefixed": {"type": "number", "value": 4.5}
                          }
                        ],
                        "type": "call_function",
                        "postfixed": {"type": "parser_variable", "name": "ast.infix_node", "is_meta": false, "is_underscored": false}
                      }
                    },
                    "right": {
                      "args": [
                        {"type": "string", "value": "$"},
                        {
                          "type": "value_label",
                          "prefixed": {"type": "string", "value": "return"}
                        },
                        {
                          "type": "value_label",
                          "prefixed": {"type": "number", "value": 4}
                        },
                        {
                          "type": "value_label",
                          "prefixed": {"type": "number", "value": 4.5}
                        }
                      ],
                      "type": "call_function",
                      "postfixed": {"type": "parser_variable", "name": "ast.infix_node", "is_meta": false, "is_underscored": false}
                    }
                  },
                  "right": {
                    "args": [
                      {"type": "string", "value": "-"},
                      {
                        "type": "value_label",
                        "prefixed": {"type": "string", "value": "subtract"}
                      },
                      {
                        "type": "value_label",
                        "prefixed": {"type": "number", "value": 4}
                      },
                      {
                        "type": "value_label",
                        "prefixed": {"type": "number", "value": 4.5}
                      }
                    ],
                    "type": "call_function",
                    "postfixed": {"type": "parser_variable", "name": "ast.infix_node", "is_meta": false, "is_underscored": false}
                  }
                },
                "right": {
                  "args": [
                    {"type": "string", "value": "*"},
                    {
                      "type": "value_label",
                      "prefixed": {"type": "string", "value": "repeat"}
                    },
                    {
                      "type": "value_label",
                      "prefixed": {"type": "number", "value": 4}
                    },
                    {
                      "type": "value_label",
                      "prefixed": {"type": "number", "value": 4.5}
                    }
                  ],
                  "type": "call_function",
                  "postfixed": {"type": "parser_variable", "name": "ast.infix_node", "is_meta": false, "is_underscored": false}
                }
              },
              "right": {
                "args": [
                  {"type": "string", "value": "&"},
                  {
                    "type": "value_label",
                    "prefixed": {"type": "string", "value": "and"}
                  },
                  {
                    "type": "value_label",
                    "prefixed": {"type": "number", "value": 3}
                  },
                  {
                    "type": "value_label",
                    "prefixed": {"type": "number", "value": 3.5}
                  }
                ],
                "type": "call_function",
                "postfixed": {"type": "parser_variable", "name": "ast.infix_node", "is_meta": false, "is_underscored": false}
              }
            },
            "right": {
              "args": [
                {
                  "type": "value_label",
                  "prefixed": {"type": "string", "value": "conditional"}
                },
                {
                  "type": "value_label",
                  "prefixed": {"type": "number", "value": 2.5}
                },
                {
                  "type": "value_label",
                  "prefixed": {"type": "number", "value": 2}
                }
              ],
              "type": "call_function",
              "postfixed": {"type": "parser_variable", "name": "conditional_infix", "is_meta": false, "is_underscored": false}
            }
          },
          "right": {
            "args": [
              {"type": "string", "value": "="},
              {
                "type": "value_label",
                "prefixed": {"type": "string", "value": "assign"}
              },
              {
                "type": "value_label",
                "prefixed": {"type": "number", "value": 1.5}
              },
              {
                "type": "value_label",
                "prefixed": {"type": "number", "value": 1}
              }
            ],
            "type": "call_function",
            "postfixed": {"type": "parser_variable", "name": "ast.infix_node", "is_meta": false, "is_underscored": false}
          }
        }
      },
      {
        "type": "named_function",
        "ident": {"type": "parser_variable", "name": "postfix", "is_meta": false, "is_underscored": false},
        "params": [],
        "body": {
          "type": "or",
          "left": {
            "args": [
              {
                "type": "value_label",
                "prefixed": {"type": "string", "value": "call_function"}
              },
              {
                "type": "value_label",
                "prefixed": {"type": "number", "value": 11}
              }
            ],
            "type": "call_function",
            "postfixed": {"type": "parser_variable", "name": "call_function_postfix", "is_meta": false, "is_underscored": false}
          },
          "right": {
            "args": [
              {
                "type": "value_label",
                "prefixed": {"type": "string", "value": "lower_bounded_range"}
              },
              {
                "type": "value_label",
                "prefixed": {"type": "number", "value": 10}
              }
            ],
            "type": "call_function",
            "postfixed": {"type": "parser_variable", "name": "lower_bounded_range_postfix", "is_meta": false, "is_underscored": false}
          }
        }
      },
      {
        "type": "named_function",
        "ident": {"type": "parser_variable", "name": "grouped_expr", "is_meta": false, "is_underscored": false},
        "params": [],
        "body": {
          "type": "take_left",
          "left": {
            "type": "take_left",
            "left": {
              "type": "take_right",
              "left": {
                "type": "take_right",
                "left": {"type": "string", "value": "("},
                "right": {"type": "parser_variable", "name": "w", "is_meta": false, "is_underscored": false}
              },
              "right": {"type": "parser_variable", "name": "expr", "is_meta": false, "is_underscored": false}
            },
            "right": {"type": "parser_variable", "name": "w", "is_meta": false, "is_underscored": false}
          },
          "right": {"type": "string", "value": ")"}
        }
      },
      {
        "type": "named_function",
        "ident": {"type": "parser_variable", "name": "boolean_node", "is_meta": false, "is_underscored": false},
        "params": [],
        "body": {
          "args": [
            {
              "args": [
                {
                  "type": "destructure",
                  "left": {
                    "type": "merge",
                    "left": {"type": "string", "value": "t"},
                    "right": {"type": "parser_variable", "name": "word", "is_meta": false, "is_underscored": false}
                  },
                  "right": {"type": "string", "value": "true"}
                },
                {
                  "type": "destructure",
                  "left": {
                    "type": "merge",
                    "left": {"type": "string", "value": "f"},
                    "right": {"type": "parser_variable", "name": "word", "is_meta": false, "is_underscored": false}
                  },
                  "right": {"type": "string", "value": "false"}
                }
              ],
              "type": "call_function",
              "postfixed": {"type": "parser_variable", "name": "boolean", "is_meta": false, "is_underscored": false}
            },
            {
              "type": "value_label",
              "prefixed": {"type": "string", "value": "boolean"}
            }
          ],
          "type": "call_function",
          "postfixed": {"type": "parser_variable", "name": "ast.node", "is_meta": false, "is_underscored": false}
        }
      },
      {
        "type": "named_function",
        "ident": {"type": "parser_variable", "name": "null_node", "is_meta": false, "is_underscored": false},
        "params": [],
        "body": {
          "type": "return",
          "left": {
            "type": "destructure",
            "left": {
              "type": "merge",
              "left": {"type": "string", "value": "n"},
              "right": {"type": "parser_variable", "name": "word", "is_meta": false, "is_underscored": false}
            },
            "right": {"type": "string", "value": "null"}
          },
          "right": {
            "type": "object",
            "value": [
              [
                {"type": "string", "value": "type"},
                {"type": "string", "value": "null"}
              ]
            ]
          }
        }
      },
      {
        "type": "named_function",
        "ident": {"type": "parser_variable", "name": "string_node", "is_meta": false, "is_underscored": false},
        "params": [],
        "body": {
          "args": [
            {
              "type": "or",
              "left": {
                "type": "or",
                "left": {
                  "args": [
                    {
                      "args": [
                        {"type": "string", "value": "\""}
                      ],
                      "type": "call_function",
                      "postfixed": {"type": "parser_variable", "name": "quoted_string_body", "is_meta": false, "is_underscored": false}
                    },
                    {"type": "string", "value": "\""}
                  ],
                  "type": "call_function",
                  "postfixed": {"type": "parser_variable", "name": "surround", "is_meta": false, "is_underscored": false}
                },
                "right": {
                  "args": [
                    {
                      "args": [
                        {"type": "string", "value": "'"}
                      ],
                      "type": "call_function",
                      "postfixed": {"type": "parser_variable", "name": "quoted_string_body", "is_meta": false, "is_underscored": false}
                    },
                    {"type": "string", "value": "'"}
                  ],
                  "type": "call_function",
                  "postfixed": {"type": "parser_variable", "name": "surround", "is_meta": false, "is_underscored": false}
                }
              },
              "right": {
                "args": [
                  {"type": "parser_variable", "name": "backtick_string_body", "is_meta": false, "is_underscored": false},
                  {"type": "string", "value": "`"}
                ],
                "type": "call_function",
                "postfixed": {"type": "parser_variable", "name": "surround", "is_meta": false, "is_underscored": false}
              }
            },
            {
              "type": "value_label",
              "prefixed": {"type": "string", "value": "string"}
            }
          ],
          "type": "call_function",
          "postfixed": {"type": "parser_variable", "name": "ast.node", "is_meta": false, "is_underscored": false}
        }
      },
      {
        "type": "named_function",
        "ident": {"type": "parser_variable", "name": "quoted_string_body", "is_meta": false, "is_underscored": false},
        "params": [
          {"type": "parser_variable", "name": "end_quote", "is_meta": false, "is_underscored": false}
        ],
        "body": {
          "type": "or",
          "left": {
            "args": [
              {
                "type": "or",
                "left": {
                  "type": "or",
                  "left": {"type": "parser_variable", "name": "string_escape_char", "is_meta": false, "is_underscored": false},
                  "right": {"type": "parser_variable", "name": "string_escape_unicode", "is_meta": false, "is_underscored": false}
                },
                "right": {
                  "args": [
                    {"type": "parser_variable", "name": "char", "is_meta": false, "is_underscored": false},
                    {
                      "type": "or",
                      "left": {
                        "type": "or",
                        "left": {"type": "string", "value": "\\"},
                        "right": {"type": "string", "value": "%("}
                      },
                      "right": {"type": "parser_variable", "name": "end_quote", "is_meta": false, "is_underscored": false}
                    }
                  ],
                  "type": "call_function",
                  "postfixed": {"type": "parser_variable", "name": "unless", "is_meta": false, "is_underscored": false}
                }
              }
            ],
            "type": "call_function",
            "postfixed": {"type": "parser_variable", "name": "many", "is_meta": false, "is_underscored": false}
          },
          "right": {
            "args": [
              {
                "type": "value_label",
                "prefixed": {"type": "string", "value": ""}
              }
            ],
            "type": "call_function",
            "postfixed": {"type": "parser_variable", "name": "const", "is_meta": false, "is_underscored": false}
          }
        }
      },
      {
        "type": "named_function",
        "ident": {"type": "parser_variable", "name": "string_escape_char", "is_meta": false, "is_underscored": false},
        "params": [],
        "body": {
          "type": "or",
          "left": {
            "type": "or",
            "left": {
              "type": "or",
              "left": {
                "type": "or",
                "left": {
                  "type": "or",
                  "left": {
                    "type": "or",
                    "left": {
                      "type": "or",
                      "left": {
                        "type": "or",
                        "left": {
                          "type": "or",
                          "left": {"type": "string", "value": "\\0"},
                          "right": {"type": "string", "value": "\\b"}
                        },
                        "right": {"type": "string", "value": "\\t"}
                      },
                      "right": {"type": "string", "value": "\\n"}
                    },
                    "right": {"type": "string", "value": "\\v"}
                  },
                  "right": {"type": "string", "value": "\\f"}
                },
                "right": {"type": "string", "value": "\\r"}
              },
              "right": {"type": "string", "value": "\\'"}
            },
            "right": {"type": "string", "value": "\\\""}
          },
          "right": {"type": "string", "value": "\\\\"}
        }
      },
      {
        "type": "named_function",
        "ident": {"type": "parser_variable", "name": "string_escape_unicode", "is_meta": false, "is_underscored": false},
        "params": [],
        "body": {
          "type": "merge",
          "left": {"type": "string", "value": "\\u"},
          "right": {
            "type": "repeat",
            "left": {"type": "parser_variable", "name": "hex_numeral", "is_meta": false, "is_underscored": false},
            "right": {"type": "number", "value": 6}
          }
        }
      },
      {
        "type": "named_function",
        "ident": {"type": "parser_variable", "name": "backtick_string_body", "is_meta": false, "is_underscored": false},
        "params": [],
        "body": {
          "type": "or",
          "left": {
            "args": [
              {"type": "string", "value": "`"}
            ],
            "type": "call_function",
            "postfixed": {"type": "parser_variable", "name": "chars_until", "is_meta": false, "is_underscored": false}
          },
          "right": {
            "args": [
              {
                "type": "value_label",
                "prefixed": {"type": "string", "value": ""}
              }
            ],
            "type": "call_function",
            "postfixed": {"type": "parser_variable", "name": "const", "is_meta": false, "is_underscored": false}
          }
        }
      },
      {
        "type": "named_function",
        "ident": {"type": "parser_variable", "name": "template_string_node", "is_meta": false, "is_underscored": false},
        "params": [],
        "body": {
          "args": [
            {
              "type": "or",
              "left": {
                "args": [
                  {
                    "args": [
                      {"type": "string", "value": "\""},
                      {
                        "type": "array",
                        "value": []
                      },
                      {
                        "type": "value_label",
                        "prefixed": {"type": "string", "value": ""}
                      }
                    ],
                    "type": "call_function",
                    "postfixed": {"type": "parser_variable", "name": "template_string_body", "is_meta": false, "is_underscored": false}
                  },
                  {"type": "string", "value": "\""}
                ],
                "type": "call_function",
                "postfixed": {"type": "parser_variable", "name": "surround", "is_meta": false, "is_underscored": false}
              },
              "right": {
                "args": [
                  {
                    "args": [
                      {"type": "string", "value": "'"},
                      {
                        "type": "array",
                        "value": []
                      },
                      {
                        "type": "value_label",
                        "prefixed": {"type": "string", "value": ""}
                      }
                    ],
                    "type": "call_function",
                    "postfixed": {"type": "parser_variable", "name": "template_string_body", "is_meta": false, "is_underscored": false}
                  },
                  {"type": "string", "value": "'"}
                ],
                "type": "call_function",
                "postfixed": {"type": "parser_variable", "name": "surround", "is_meta": false, "is_underscored": false}
              }
            },
            {
              "type": "value_label",
              "prefixed": {"type": "string", "value": "template_string"}
            }
          ],
          "type": "call_function",
          "postfixed": {"type": "parser_variable", "name": "ast.node", "is_meta": false, "is_underscored": false}
        }
      },
      {
        "type": "named_function",
        "ident": {"type": "parser_variable", "name": "template_string_body", "is_meta": false, "is_underscored": false},
        "params": [
          {"type": "parser_variable", "name": "end_quote", "is_meta": false, "is_underscored": false},
          {"type": "value_variable", "name": "TemplateParts", "is_meta": false, "is_underscored": false},
          {"type": "value_variable", "name": "Str", "is_meta": false, "is_underscored": false}
        ],
        "body": {
          "middle": {
            "args": [
              {
                "args": [
                  {"type": "value_variable", "name": "TemplateParts", "is_meta": false, "is_underscored": false},
                  {"type": "value_variable", "name": "Str", "is_meta": false, "is_underscored": false}
                ],
                "type": "call_function",
                "postfixed": {"type": "value_variable", "name": "AppendNonEmptyString", "is_meta": false, "is_underscored": false}
              }
            ],
            "type": "call_function",
            "postfixed": {"type": "parser_variable", "name": "const", "is_meta": false, "is_underscored": false}
          },
          "type": "conditional",
          "left": {
            "args": [
              {"type": "parser_variable", "name": "end_quote", "is_meta": false, "is_underscored": false}
            ],
            "type": "call_function",
            "postfixed": {"type": "parser_variable", "name": "peek", "is_meta": false, "is_underscored": false}
          },
          "right": {
            "middle": {
              "args": [
                {"type": "parser_variable", "name": "end_quote", "is_meta": false, "is_underscored": false},
                {"type": "value_variable", "name": "TemplateParts", "is_meta": false, "is_underscored": false},
                {"type": "value_variable", "name": "Str", "is_meta": false, "is_underscored": false}
              ],
              "type": "call_function",
              "postfixed": {"type": "parser_variable", "name": "template_string_body", "is_meta": false, "is_underscored": false}
            },
            "type": "conditional",
            "left": {
              "type": "take_left",
              "left": {
                "type": "take_right",
                "left": {"type": "string", "value": "%("},
                "right": {"type": "parser_variable", "name": "w", "is_meta": false, "is_underscored": false}
              },
              "right": {"type": "string", "value": ")"}
            },
            "right": {
              "middle": {
                "type": "and",
                "left": {
                  "type": "and",
                  "left": {
                    "type": "destructure",
                    "left": {
                      "args": [
                        {"type": "parser_variable", "name": "expr", "is_meta": false, "is_underscored": false}
                      ],
                      "type": "call_function",
                      "postfixed": {"type": "parser_variable", "name": "w_arround", "is_meta": false, "is_underscored": false}
                    },
                    "right": {"type": "value_variable", "name": "Expr", "is_meta": false, "is_underscored": false}
                  },
                  "right": {"type": "string", "value": ")"}
                },
                "right": {
                  "args": [
                    {"type": "parser_variable", "name": "end_quote", "is_meta": false, "is_underscored": false},
                    {
                      "type": "array",
                      "value": [
                        {
                          "type": "spread",
                          "prefixed": {
                            "args": [
                              {"type": "value_variable", "name": "TemplateParts", "is_meta": false, "is_underscored": false},
                              {"type": "value_variable", "name": "Str", "is_meta": false, "is_underscored": false}
                            ],
                            "type": "call_function",
                            "postfixed": {"type": "value_variable", "name": "AppendNonEmptyString", "is_meta": false, "is_underscored": false}
                          }
                        },
                        {"type": "value_variable", "name": "Expr", "is_meta": false, "is_underscored": false}
                      ]
                    },
                    {
                      "type": "value_label",
                      "prefixed": {"type": "string", "value": ""}
                    }
                  ],
                  "type": "call_function",
                  "postfixed": {"type": "parser_variable", "name": "template_string_body", "is_meta": false, "is_underscored": false}
                }
              },
              "type": "conditional",
              "left": {"type": "string", "value": "%("},
              "right": {
                "type": "and",
                "left": {
                  "type": "destructure",
                  "left": {
                    "type": "or",
                    "left": {
                      "type": "or",
                      "left": {"type": "parser_variable", "name": "string_escape_char", "is_meta": false, "is_underscored": false},
                      "right": {"type": "parser_variable", "name": "string_escape_unicode", "is_meta": false, "is_underscored": false}
                    },
                    "right": {
                      "args": [
                        {"type": "parser_variable", "name": "char", "is_meta": false, "is_underscored": false},
                        {"type": "string", "value": "\\"}
                      ],
                      "type": "call_function",
                      "postfixed": {"type": "parser_variable", "name": "unless", "is_meta": false, "is_underscored": false}
                    }
                  },
                  "right": {"type": "value_variable", "name": "Next", "is_meta": false, "is_underscored": false}
                },
                "right": {
                  "args": [
                    {"type": "parser_variable", "name": "end_quote", "is_meta": false, "is_underscored": false},
                    {"type": "value_variable", "name": "TemplateParts", "is_meta": false, "is_underscored": false},
                    {
                      "type": "merge",
                      "left": {"type": "value_variable", "name": "Str", "is_meta": false, "is_underscored": false},
                      "right": {"type": "value_variable", "name": "Next", "is_meta": false, "is_underscored": false}
                    }
                  ],
                  "type": "call_function",
                  "postfixed": {"type": "parser_variable", "name": "template_string_body", "is_meta": false, "is_underscored": false}
                }
              }
            }
          }
        }
      },
      {
        "type": "named_function",
        "ident": {"type": "value_variable", "name": "AppendNonEmptyString", "is_meta": false, "is_underscored": false},
        "params": [
          {"type": "value_variable", "name": "TemplateParts", "is_meta": false, "is_underscored": false},
          {"type": "value_variable", "name": "Str", "is_meta": false, "is_underscored": false}
        ],
        "body": {
          "middle": {"type": "value_variable", "name": "TemplateParts", "is_meta": false, "is_underscored": false},
          "type": "conditional",
          "left": {
            "type": "destructure",
            "left": {"type": "value_variable", "name": "Str", "is_meta": false, "is_underscored": false},
            "right": {"type": "string", "value": ""}
          },
          "right": {
            "type": "array",
            "value": [
              {
                "type": "spread",
                "prefixed": {"type": "value_variable", "name": "TemplateParts", "is_meta": false, "is_underscored": false}
              },
              {
                "type": "object",
                "value": [
                  [
                    {"type": "string", "value": "type"},
                    {"type": "string", "value": "string"}
                  ],
                  [
                    {"type": "string", "value": "value"},
                    {"type": "value_variable", "name": "Str", "is_meta": false, "is_underscored": false}
                  ]
                ]
              }
            ]
          }
        }
      },
      {
        "type": "named_function",
        "ident": {"type": "parser_variable", "name": "number_node", "is_meta": false, "is_underscored": false},
        "params": [],
        "body": {
          "args": [
            {"type": "parser_variable", "name": "number", "is_meta": false, "is_underscored": false},
            {
              "type": "value_label",
              "prefixed": {"type": "string", "value": "number"}
            }
          ],
          "type": "call_function",
          "postfixed": {"type": "parser_variable", "name": "ast.node", "is_meta": false, "is_underscored": false}
        }
      },
      {
        "type": "named_function",
        "ident": {"type": "parser_variable", "name": "variable_node", "is_meta": false, "is_underscored": false},
        "params": [
          {"type": "value_variable", "name": "Type", "is_meta": false, "is_underscored": false},
          {"type": "parser_variable", "name": "name_format", "is_meta": false, "is_underscored": false}
        ],
        "body": {
          "type": "and",
          "left": {
            "type": "destructure",
            "left": {
              "args": [
                {
                  "args": [
                    {
                      "args": [
                        {"type": "string", "value": "@"},
                        {"type": "parser_variable", "name": "succeed", "is_meta": false, "is_underscored": false}
                      ],
                      "type": "call_function",
                      "postfixed": {"type": "parser_variable", "name": "boolean", "is_meta": false, "is_underscored": false}
                    },
                    {
                      "args": [
                        {
                          "args": [
                            {"type": "string", "value": "_"}
                          ],
                          "type": "call_function",
                          "postfixed": {"type": "parser_variable", "name": "many", "is_meta": false, "is_underscored": false}
                        },
                        {"type": "parser_variable", "name": "succeed", "is_meta": false, "is_underscored": false}
                      ],
                      "type": "call_function",
                      "postfixed": {"type": "parser_variable", "name": "boolean", "is_meta": false, "is_underscored": false}
                    }
                  ],
                  "type": "call_function",
                  "postfixed": {"type": "parser_variable", "name": "tuple2", "is_meta": false, "is_underscored": false}
                }
              ],
              "type": "call_function",
              "postfixed": {"type": "parser_variable", "name": "peek", "is_meta": false, "is_underscored": false}
            },
            "right": {
              "type": "array",
              "value": [
                {"type": "value_variable", "name": "IsMeta", "is_meta": false, "is_underscored": false},
                {"type": "value_variable", "name": "IsUnderscored", "is_meta": false, "is_underscored": false}
              ]
            }
          },
          "right": {
            "type": "return",
            "left": {
              "type": "destructure",
              "left": {
                "type": "merge",
                "left": {
                  "type": "merge",
                  "left": {
                    "args": [
                      {"type": "string", "value": "@"}
                    ],
                    "type": "call_function",
                    "postfixed": {"type": "parser_variable", "name": "maybe", "is_meta": false, "is_underscored": false}
                  },
                  "right": {
                    "args": [
                      {"type": "string", "value": "_"}
                    ],
                    "type": "call_function",
                    "postfixed": {"type": "parser_variable", "name": "maybe_many", "is_meta": false, "is_underscored": false}
                  }
                },
                "right": {"type": "parser_variable", "name": "name_format", "is_meta": false, "is_underscored": false}
              },
              "right": {"type": "value_variable", "name": "Name", "is_meta": false, "is_underscored": false}
            },
            "right": {
              "type": "object",
              "value": [
                [
                  {"type": "string", "value": "type"},
                  {"type": "value_variable", "name": "Type", "is_meta": false, "is_underscored": false}
                ],
                [
                  {"type": "string", "value": "name"},
                  {"type": "value_variable", "name": "Name", "is_meta": false, "is_underscored": false}
                ],
                [
                  {"type": "string", "value": "is_meta"},
                  {"type": "value_variable", "name": "IsMeta", "is_meta": false, "is_underscored": false}
                ],
                [
                  {"type": "string", "value": "is_underscored"},
                  {"type": "value_variable", "name": "IsUnderscored", "is_meta": false, "is_underscored": false}
                ]
              ]
            }
          }
        }
      },
      {
        "type": "named_function",
        "ident": {"type": "parser_variable", "name": "parser_variable_node", "is_meta": false, "is_underscored": false},
        "params": [],
        "body": {
          "args": [
            {
              "type": "value_label",
              "prefixed": {"type": "string", "value": "parser_variable"}
            },
            {
              "type": "merge",
              "left": {"type": "parser_variable", "name": "lower", "is_meta": false, "is_underscored": false},
              "right": {
                "args": [
                  {
                    "type": "or",
                    "left": {
                      "type": "or",
                      "left": {"type": "parser_variable", "name": "alnum", "is_meta": false, "is_underscored": false},
                      "right": {"type": "string", "value": "_"}
                    },
                    "right": {"type": "string", "value": "."}
                  }
                ],
                "type": "call_function",
                "postfixed": {"type": "parser_variable", "name": "maybe_many", "is_meta": false, "is_underscored": false}
              }
            }
          ],
          "type": "call_function",
          "postfixed": {"type": "parser_variable", "name": "variable_node", "is_meta": false, "is_underscored": false}
        }
      },
      {
        "type": "named_function",
        "ident": {"type": "parser_variable", "name": "value_variable_node", "is_meta": false, "is_underscored": false},
        "params": [],
        "body": {
          "args": [
            {
              "type": "value_label",
              "prefixed": {"type": "string", "value": "value_variable"}
            },
            {
              "type": "merge",
              "left": {"type": "parser_variable", "name": "upper", "is_meta": false, "is_underscored": false},
              "right": {
                "args": [
                  {
                    "type": "or",
                    "left": {
                      "type": "or",
                      "left": {"type": "parser_variable", "name": "alpha", "is_meta": false, "is_underscored": false},
                      "right": {"type": "string", "value": "_"}
                    },
                    "right": {"type": "string", "value": "."}
                  }
                ],
                "type": "call_function",
                "postfixed": {"type": "parser_variable", "name": "maybe_many", "is_meta": false, "is_underscored": false}
              }
            }
          ],
          "type": "call_function",
          "postfixed": {"type": "parser_variable", "name": "variable_node", "is_meta": false, "is_underscored": false}
        }
      },
      {
        "type": "named_function",
        "ident": {"type": "parser_variable", "name": "underscore_variable_node", "is_meta": false, "is_underscored": false},
        "params": [],
        "body": {
          "args": [
            {
              "args": [
                {"type": "string", "value": "_"}
              ],
              "type": "call_function",
              "postfixed": {"type": "parser_variable", "name": "many", "is_meta": false, "is_underscored": false}
            },
            {
              "type": "value_label",
              "prefixed": {"type": "string", "value": "underscore_variable"}
            }
          ],
          "type": "call_function",
          "postfixed": {"type": "parser_variable", "name": "ast.node", "is_meta": false, "is_underscored": false}
        }
      },
      {
        "type": "named_function",
        "ident": {"type": "parser_variable", "name": "array_node", "is_meta": false, "is_underscored": false},
        "params": [],
        "body": {
          "args": [
            {
              "type": "take_left",
              "left": {
                "type": "take_left",
                "left": {
                  "type": "take_right",
                  "left": {
                    "type": "take_right",
                    "left": {"type": "string", "value": "["},
                    "right": {"type": "parser_variable", "name": "w", "is_meta": false, "is_underscored": false}
                  },
                  "right": {
                    "args": [
                      {"type": "parser_variable", "name": "expr", "is_meta": false, "is_underscored": false},
                      {"type": "string", "value": ","}
                    ],
                    "type": "call_function",
                    "postfixed": {"type": "parser_variable", "name": "maybe_array_sep", "is_meta": false, "is_underscored": false}
                  }
                },
                "right": {"type": "parser_variable", "name": "trailing_comma", "is_meta": false, "is_underscored": false}
              },
              "right": {"type": "string", "value": "]"}
            },
            {
              "type": "value_label",
              "prefixed": {"type": "string", "value": "array"}
            }
          ],
          "type": "call_function",
          "postfixed": {"type": "parser_variable", "name": "ast.node", "is_meta": false, "is_underscored": false}
        }
      },
      {
        "type": "named_function",
        "ident": {"type": "parser_variable", "name": "object_node", "is_meta": false, "is_underscored": false},
        "params": [],
        "body": {
          "args": [
            {
              "type": "take_left",
              "left": {
                "type": "take_left",
                "left": {
                  "type": "take_right",
                  "left": {
                    "type": "take_right",
                    "left": {"type": "string", "value": "{"},
                    "right": {"type": "parser_variable", "name": "w", "is_meta": false, "is_underscored": false}
                  },
                  "right": {
                    "args": [
                      {"type": "parser_variable", "name": "object_pair", "is_meta": false, "is_underscored": false},
                      {"type": "string", "value": ","}
                    ],
                    "type": "call_function",
                    "postfixed": {"type": "parser_variable", "name": "maybe_array_sep", "is_meta": false, "is_underscored": false}
                  }
                },
                "right": {"type": "parser_variable", "name": "trailing_comma", "is_meta": false, "is_underscored": false}
              },
              "right": {"type": "string", "value": "}"}
            },
            {
              "type": "value_label",
              "prefixed": {"type": "string", "value": "object"}
            }
          ],
          "type": "call_function",
          "postfixed": {"type": "parser_variable", "name": "ast.node", "is_meta": false, "is_underscored": false}
        }
      },
      {
        "type": "named_function",
        "ident": {"type": "parser_variable", "name": "object_pair", "is_meta": false, "is_underscored": false},
        "params": [],
        "body": {
          "args": [
            {
              "args": [
                {"type": "parser_variable", "name": "expr", "is_meta": false, "is_underscored": false}
              ],
              "type": "call_function",
              "postfixed": {"type": "parser_variable", "name": "w_arround", "is_meta": false, "is_underscored": false}
            },
            {"type": "string", "value": ":"},
            {
              "args": [
                {"type": "parser_variable", "name": "expr", "is_meta": false, "is_underscored": false}
              ],
              "type": "call_function",
              "postfixed": {"type": "parser_variable", "name": "w_arround", "is_meta": false, "is_underscored": false}
            }
          ],
          "type": "call_function",
          "postfixed": {"type": "parser_variable", "name": "tuple2_sep", "is_meta": false, "is_underscored": false}
        }
      },
      {
        "type": "named_function",
        "ident": {"type": "parser_variable", "name": "function_args_or_params", "is_meta": false, "is_underscored": false},
        "params": [],
        "body": {
          "type": "take_left",
          "left": {
            "type": "take_left",
            "left": {
              "type": "take_right",
              "left": {
                "type": "take_right",
                "left": {"type": "string", "value": "("},
                "right": {"type": "parser_variable", "name": "w", "is_meta": false, "is_underscored": false}
              },
              "right": {
                "args": [
                  {
                    "args": [
                      {"type": "parser_variable", "name": "expr", "is_meta": false, "is_underscored": false}
                    ],
                    "type": "call_function",
                    "postfixed": {"type": "parser_variable", "name": "w_arround", "is_meta": false, "is_underscored": false}
                  },
                  {"type": "string", "value": ","}
                ],
                "type": "call_function",
                "postfixed": {"type": "parser_variable", "name": "maybe_array_sep", "is_meta": false, "is_underscored": false}
              }
            },
            "right": {"type": "parser_variable", "name": "trailing_comma", "is_meta": false, "is_underscored": false}
          },
          "right": {"type": "string", "value": ")"}
        }
      },
      {
        "type": "named_function",
        "ident": {"type": "parser_variable", "name": "trailing_comma", "is_meta": false, "is_underscored": false},
        "params": [],
        "body": {
          "args": [
            {
              "args": [
                {"type": "string", "value": ","}
              ],
              "type": "call_function",
              "postfixed": {"type": "parser_variable", "name": "w_arround", "is_meta": false, "is_underscored": false}
            }
          ],
          "type": "call_function",
          "postfixed": {"type": "parser_variable", "name": "maybe", "is_meta": false, "is_underscored": false}
        }
      },
      {
        "type": "named_function",
        "ident": {"type": "parser_variable", "name": "conditional_infix", "is_meta": false, "is_underscored": false},
        "params": [
          {"type": "value_variable", "name": "Type", "is_meta": false, "is_underscored": false},
          {"type": "value_variable", "name": "LeftBindingPower", "is_meta": false, "is_underscored": false},
          {"type": "value_variable", "name": "RightBindingPower", "is_meta": false, "is_underscored": false}
        ],
        "body": {
          "type": "and",
          "left": {
            "type": "and",
            "left": {
              "type": "and",
              "left": {
                "type": "and",
                "left": {"type": "string", "value": "?"},
                "right": {"type": "parser_variable", "name": "w", "is_meta": false, "is_underscored": false}
              },
              "right": {
                "type": "destructure",
                "left": {"type": "parser_variable", "name": "expr", "is_meta": false, "is_underscored": false},
                "right": {"type": "value_variable", "name": "Middle", "is_meta": false, "is_underscored": false}
              }
            },
            "right": {"type": "parser_variable", "name": "w", "is_meta": false, "is_underscored": false}
          },
          "right": {
            "type": "return",
            "left": {"type": "string", "value": ":"},
            "right": {
              "type": "object",
              "value": [
                [
                  {"type": "string", "value": "type"},
                  {"type": "value_variable", "name": "Type", "is_meta": false, "is_underscored": false}
                ],
                [
                  {"type": "string", "value": "middle"},
                  {"type": "value_variable", "name": "Middle", "is_meta": false, "is_underscored": false}
                ],
                [
                  {"type": "string", "value": "power"},
                  {
                    "type": "array",
                    "value": [
                      {"type": "value_variable", "name": "LeftBindingPower", "is_meta": false, "is_underscored": false},
                      {"type": "value_variable", "name": "RightBindingPower", "is_meta": false, "is_underscored": false}
                    ]
                  }
                ]
              ]
            }
          }
        }
      },
      {
        "type": "named_function",
        "ident": {"type": "parser_variable", "name": "lower_bounded_range_postfix", "is_meta": false, "is_underscored": false},
        "params": [
          {"type": "value_variable", "name": "Type", "is_meta": false, "is_underscored": false},
          {"type": "value_variable", "name": "BindingPower", "is_meta": false, "is_underscored": false}
        ],
        "body": {
          "type": "and",
          "left": {"type": "string", "value": ".."},
          "right": {
            "type": "return",
            "left": {
              "args": [
                {
                  "type": "take_right",
                  "left": {"type": "parser_variable", "name": "w", "is_meta": false, "is_underscored": false},
                  "right": {
                    "type": "or",
                    "left": {
                      "type": "or",
                      "left": {"type": "parser_variable", "name": "postfix", "is_meta": false, "is_underscored": false},
                      "right": {"type": "parser_variable", "name": "infix", "is_meta": false, "is_underscored": false}
                    },
                    "right": {"type": "parser_variable", "name": "end", "is_meta": false, "is_underscored": false}
                  }
                }
              ],
              "type": "call_function",
              "postfixed": {"type": "parser_variable", "name": "peek", "is_meta": false, "is_underscored": false}
            },
            "right": {
              "type": "object",
              "value": [
                [
                  {"type": "string", "value": "type"},
                  {"type": "value_variable", "name": "Type", "is_meta": false, "is_underscored": false}
                ],
                [
                  {"type": "string", "value": "power"},
                  {"type": "value_variable", "name": "BindingPower", "is_meta": false, "is_underscored": false}
                ]
              ]
            }
          }
        }
      },
      {
        "type": "named_function",
        "ident": {"type": "parser_variable", "name": "call_function_postfix", "is_meta": false, "is_underscored": false},
        "params": [
          {"type": "value_variable", "name": "Type", "is_meta": false, "is_underscored": false},
          {"type": "value_variable", "name": "BindingPower", "is_meta": false, "is_underscored": false}
        ],
        "body": {
          "type": "return",
          "left": {
            "type": "destructure",
            "left": {"type": "parser_variable", "name": "function_args_or_params", "is_meta": false, "is_underscored": false},
            "right": {"type": "value_variable", "name": "Args", "is_meta": false, "is_underscored": false}
          },
          "right": {
            "type": "object",
            "value": [
              [
                {"type": "string", "value": "type"},
                {"type": "value_variable", "name": "Type", "is_meta": false, "is_underscored": false}
              ],
              [
                {"type": "string", "value": "args"},
                {"type": "value_variable", "name": "Args", "is_meta": false, "is_underscored": false}
              ],
              [
                {"type": "string", "value": "power"},
                {"type": "value_variable", "name": "BindingPower", "is_meta": false, "is_underscored": false}
              ]
            ]
          }
        }
      }
    ]
  }

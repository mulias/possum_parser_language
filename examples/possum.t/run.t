  $ possum $TESTDIR/possum.possum -i '123'
  {
    "type": "program",
    "value": [
      {"type": "number", "value": 123}
    ]
  }

  $ possum $TESTDIR/possum.possum -i '"a" + "b" + "c"'
  {
    "type": "program",
    "value": [
      {
        "type": "merge",
        "left": {
          "type": "merge",
          "left": {"type": "string", "value": "a"},
          "right": {"type": "string", "value": "b"}
        },
        "right": {"type": "string", "value": "c"}
      }
    ]
  }

  $ possum $TESTDIR/possum.possum -i '"a" + "b" & num -> N'
  {
    "type": "program",
    "value": [
      {
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
    ]
  }

  $ possum $TESTDIR/possum.possum -i "'ab\'c'"
  {
    "type": "program",
    "value": [
      {"type": "string", "value": "ab\\'c"}
    ]
  }

  $ possum $TESTDIR/possum.possum -i '-37'
  {
    "type": "program",
    "value": [
      {
        "type": "negate",
        "prefixed": {"type": "number", "value": 37}
      }
    ]
  }

  $ possum $TESTDIR/possum.possum -i 'array(int)'
  {
    "type": "program",
    "value": [
      {
        "type": "call_or_define_function",
        "value": [
          {"type": "parser_variable", "name": "int", "is_meta": false, "is_underscored": false}
        ],
        "postfixed": {"type": "parser_variable", "name": "array", "is_meta": false, "is_underscored": false}
      }
    ]
  }

  $ possum $TESTDIR/possum.possum -i '"one" | "two"'
  {
    "type": "program",
    "value": [
      {
        "type": "or",
        "left": {"type": "string", "value": "one"},
        "right": {"type": "string", "value": "two"}
      }
    ]
  }

  $ possum $TESTDIR/possum.possum $TESTDIR/possum.possum
  {
    "type": "program",
    "value": [
      {
        "type": "call_or_define_function",
        "value": [
          {"type": "parser_variable", "name": "program", "is_meta": false, "is_underscored": false}
        ],
        "postfixed": {"type": "parser_variable", "name": "input", "is_meta": false, "is_underscored": false}
      },
      {
        "type": "assign",
        "left": {"type": "parser_variable", "name": "program", "is_meta": false, "is_underscored": false},
        "right": {
          "type": "call_or_define_function",
          "value": [
            {"type": "string", "value": "program"},
            {
              "type": "take_left",
              "left": {
                "type": "call_or_define_function",
                "value": [
                  {"type": "parser_variable", "name": "expr", "is_meta": false, "is_underscored": false},
                  {"type": "parser_variable", "name": "expr_sep", "is_meta": false, "is_underscored": false}
                ],
                "postfixed": {"type": "parser_variable", "name": "array_sep", "is_meta": false, "is_underscored": false}
              },
              "right": {
                "type": "call_or_define_function",
                "value": [
                  {"type": "parser_variable", "name": "expr_sep", "is_meta": false, "is_underscored": false}
                ],
                "postfixed": {"type": "parser_variable", "name": "maybe", "is_meta": false, "is_underscored": false}
              }
            }
          ],
          "postfixed": {"type": "parser_variable", "name": "ast_node", "is_meta": false, "is_underscored": false}
        }
      },
      {
        "type": "assign",
        "left": {"type": "parser_variable", "name": "expr_sep", "is_meta": false, "is_underscored": false},
        "right": {
          "type": "or",
          "left": {
            "type": "call_or_define_function",
            "value": [
              {"type": "string", "value": ";"}
            ],
            "postfixed": {"type": "parser_variable", "name": "ws_arround", "is_meta": false, "is_underscored": false}
          },
          "right": {"type": "parser_variable", "name": "nl", "is_meta": false, "is_underscored": false}
        }
      },
      {
        "type": "assign",
        "left": {"type": "parser_variable", "name": "w", "is_meta": false, "is_underscored": false},
        "right": {
          "type": "call_or_define_function",
          "value": [
            {
              "type": "or",
              "left": {"type": "parser_variable", "name": "comment", "is_meta": false, "is_underscored": false},
              "right": {"type": "parser_variable", "name": "whitespace", "is_meta": false, "is_underscored": false}
            }
          ],
          "postfixed": {"type": "parser_variable", "name": "maybe_many", "is_meta": false, "is_underscored": false}
        }
      },
      {
        "type": "assign",
        "left": {"type": "parser_variable", "name": "comment", "is_meta": false, "is_underscored": false},
        "right": {
          "type": "take_right",
          "left": {"type": "string", "value": "#"},
          "right": {
            "type": "call_or_define_function",
            "value": [
              {"type": "parser_variable", "name": "char", "is_meta": false, "is_underscored": false},
              {
                "type": "or",
                "left": {"type": "parser_variable", "name": "nl", "is_meta": false, "is_underscored": false},
                "right": {"type": "parser_variable", "name": "end", "is_meta": false, "is_underscored": false}
              }
            ],
            "postfixed": {"type": "parser_variable", "name": "many_until", "is_meta": false, "is_underscored": false}
          }
        }
      },
      {
        "type": "assign",
        "left": {
          "type": "call_or_define_function",
          "value": [
            {"type": "parser_variable", "name": "p", "is_meta": false, "is_underscored": false}
          ],
          "postfixed": {"type": "parser_variable", "name": "ws_arround", "is_meta": false, "is_underscored": false}
        },
        "right": {
          "type": "call_or_define_function",
          "value": [
            {"type": "parser_variable", "name": "p", "is_meta": false, "is_underscored": false},
            {"type": "parser_variable", "name": "w", "is_meta": false, "is_underscored": false}
          ],
          "postfixed": {"type": "parser_variable", "name": "surround", "is_meta": false, "is_underscored": false}
        }
      },
      {
        "type": "assign",
        "left": {"type": "parser_variable", "name": "expr", "is_meta": false, "is_underscored": false},
        "right": {
          "type": "call_or_define_function",
          "value": [
            {
              "type": "take_right",
              "left": {"type": "parser_variable", "name": "w", "is_meta": false, "is_underscored": false},
              "right": {"type": "parser_variable", "name": "value", "is_meta": false, "is_underscored": false}
            },
            {
              "type": "call_or_define_function",
              "value": [
                {"type": "parser_variable", "name": "prefix", "is_meta": false, "is_underscored": false}
              ],
              "postfixed": {"type": "parser_variable", "name": "ws_arround", "is_meta": false, "is_underscored": false}
            },
            {
              "type": "call_or_define_function",
              "value": [
                {"type": "parser_variable", "name": "infix", "is_meta": false, "is_underscored": false}
              ],
              "postfixed": {"type": "parser_variable", "name": "ws_arround", "is_meta": false, "is_underscored": false}
            },
            {
              "type": "take_right",
              "left": {"type": "parser_variable", "name": "w", "is_meta": false, "is_underscored": false},
              "right": {"type": "parser_variable", "name": "postfix", "is_meta": false, "is_underscored": false}
            }
          ],
          "postfixed": {"type": "parser_variable", "name": "ast_with_operator_precedence", "is_meta": false, "is_underscored": false}
        }
      },
      {
        "type": "assign",
        "left": {"type": "parser_variable", "name": "value", "is_meta": false, "is_underscored": false},
        "right": {
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
                            "left": {"type": "parser_variable", "name": "grouped_value", "is_meta": false, "is_underscored": false},
                            "right": {"type": "parser_variable", "name": "boolean_value", "is_meta": false, "is_underscored": false}
                          },
                          "right": {"type": "parser_variable", "name": "null_value", "is_meta": false, "is_underscored": false}
                        },
                        "right": {"type": "parser_variable", "name": "string_value", "is_meta": false, "is_underscored": false}
                      },
                      "right": {"type": "parser_variable", "name": "template_string_value", "is_meta": false, "is_underscored": false}
                    },
                    "right": {"type": "parser_variable", "name": "number_value", "is_meta": false, "is_underscored": false}
                  },
                  "right": {"type": "parser_variable", "name": "parser_variable_value", "is_meta": false, "is_underscored": false}
                },
                "right": {"type": "parser_variable", "name": "value_variable_value", "is_meta": false, "is_underscored": false}
              },
              "right": {"type": "parser_variable", "name": "underscore_variable_value", "is_meta": false, "is_underscored": false}
            },
            "right": {"type": "parser_variable", "name": "array_value", "is_meta": false, "is_underscored": false}
          },
          "right": {"type": "parser_variable", "name": "object_value", "is_meta": false, "is_underscored": false}
        }
      },
      {
        "type": "assign",
        "left": {"type": "parser_variable", "name": "grouped_value", "is_meta": false, "is_underscored": false},
        "right": {
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
        "type": "assign",
        "left": {"type": "parser_variable", "name": "boolean_value", "is_meta": false, "is_underscored": false},
        "right": {
          "type": "call_or_define_function",
          "value": [
            {"type": "string", "value": "boolean"},
            {
              "type": "call_or_define_function",
              "value": [
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
              "postfixed": {"type": "parser_variable", "name": "boolean", "is_meta": false, "is_underscored": false}
            }
          ],
          "postfixed": {"type": "parser_variable", "name": "ast_node", "is_meta": false, "is_underscored": false}
        }
      },
      {
        "type": "assign",
        "left": {"type": "parser_variable", "name": "null_value", "is_meta": false, "is_underscored": false},
        "right": {
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
        "type": "assign",
        "left": {"type": "parser_variable", "name": "string_value", "is_meta": false, "is_underscored": false},
        "right": {
          "type": "call_or_define_function",
          "value": [
            {"type": "string", "value": "string"},
            {
              "type": "or",
              "left": {
                "type": "or",
                "left": {
                  "type": "take_right",
                  "left": {"type": "string", "value": "\""},
                  "right": {
                    "type": "call_or_define_function",
                    "value": [
                      {"type": "string", "value": "\""},
                      {"type": "string", "value": ""}
                    ],
                    "postfixed": {"type": "parser_variable", "name": "quoted_string_body", "is_meta": false, "is_underscored": false}
                  }
                },
                "right": {
                  "type": "take_right",
                  "left": {"type": "string", "value": "'"},
                  "right": {
                    "type": "call_or_define_function",
                    "value": [
                      {"type": "string", "value": "'"},
                      {"type": "string", "value": ""}
                    ],
                    "postfixed": {"type": "parser_variable", "name": "quoted_string_body", "is_meta": false, "is_underscored": false}
                  }
                }
              },
              "right": {
                "type": "take_right",
                "left": {"type": "string", "value": "`"},
                "right": {
                  "type": "call_or_define_function",
                  "value": [
                    {"type": "string", "value": ""}
                  ],
                  "postfixed": {"type": "parser_variable", "name": "backtick_string_body", "is_meta": false, "is_underscored": false}
                }
              }
            }
          ],
          "postfixed": {"type": "parser_variable", "name": "ast_node", "is_meta": false, "is_underscored": false}
        }
      },
      {
        "type": "assign",
        "left": {
          "type": "call_or_define_function",
          "value": [
            {"type": "parser_variable", "name": "end_quote", "is_meta": false, "is_underscored": false},
            {"type": "value_variable", "name": "Str", "is_meta": false, "is_underscored": false}
          ],
          "postfixed": {"type": "parser_variable", "name": "quoted_string_body", "is_meta": false, "is_underscored": false}
        },
        "right": {
          "type": "conditional",
          "middle": {
            "type": "call_or_define_function",
            "value": [
              {"type": "value_variable", "name": "Str", "is_meta": false, "is_underscored": false}
            ],
            "postfixed": {"type": "parser_variable", "name": "const", "is_meta": false, "is_underscored": false}
          },
          "left": {"type": "parser_variable", "name": "end_quote", "is_meta": false, "is_underscored": false},
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
                  "type": "call_or_define_function",
                  "value": [
                    {"type": "parser_variable", "name": "char", "is_meta": false, "is_underscored": false},
                    {
                      "type": "or",
                      "left": {"type": "string", "value": "\\"},
                      "right": {"type": "string", "value": "%("}
                    }
                  ],
                  "postfixed": {"type": "parser_variable", "name": "unless", "is_meta": false, "is_underscored": false}
                }
              },
              "right": {"type": "value_variable", "name": "Next", "is_meta": false, "is_underscored": false}
            },
            "right": {
              "type": "call_or_define_function",
              "value": [
                {"type": "parser_variable", "name": "end_quote", "is_meta": false, "is_underscored": false},
                {
                  "type": "merge",
                  "left": {"type": "value_variable", "name": "Str", "is_meta": false, "is_underscored": false},
                  "right": {"type": "value_variable", "name": "Next", "is_meta": false, "is_underscored": false}
                }
              ],
              "postfixed": {"type": "parser_variable", "name": "quoted_string_body", "is_meta": false, "is_underscored": false}
            }
          }
        }
      },
      {
        "type": "assign",
        "left": {"type": "parser_variable", "name": "string_escape_char", "is_meta": false, "is_underscored": false},
        "right": {
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
        "type": "assign",
        "left": {"type": "parser_variable", "name": "string_escape_unicode", "is_meta": false, "is_underscored": false},
        "right": {
          "type": "merge",
          "left": {"type": "string", "value": "\\u"},
          "right": {
            "type": "call_or_define_function",
            "value": [
              {"type": "parser_variable", "name": "hex", "is_meta": false, "is_underscored": false},
              {"type": "number", "value": 6}
            ],
            "postfixed": {"type": "parser_variable", "name": "repeat", "is_meta": false, "is_underscored": false}
          }
        }
      },
      {
        "type": "assign",
        "left": {"type": "parser_variable", "name": "hex", "is_meta": false, "is_underscored": false},
        "right": {
          "type": "or",
          "left": {
            "type": "or",
            "left": {"type": "parser_variable", "name": "numeral", "is_meta": false, "is_underscored": false},
            "right": {
              "type": "range",
              "left": {"type": "string", "value": "a"},
              "right": {"type": "string", "value": "f"}
            }
          },
          "right": {
            "type": "range",
            "left": {"type": "string", "value": "A"},
            "right": {"type": "string", "value": "F"}
          }
        }
      },
      {
        "type": "assign",
        "left": {"type": "parser_variable", "name": "template_string_value", "is_meta": false, "is_underscored": false},
        "right": {
          "type": "call_or_define_function",
          "value": [
            {"type": "string", "value": "template_string"},
            {
              "type": "or",
              "left": {
                "type": "take_right",
                "left": {"type": "string", "value": "\""},
                "right": {
                  "type": "call_or_define_function",
                  "value": [
                    {"type": "string", "value": "\""},
                    {
                      "type": "array",
                      "value": []
                    },
                    {"type": "string", "value": ""}
                  ],
                  "postfixed": {"type": "parser_variable", "name": "template_string_body", "is_meta": false, "is_underscored": false}
                }
              },
              "right": {
                "type": "take_right",
                "left": {"type": "string", "value": "'"},
                "right": {
                  "type": "call_or_define_function",
                  "value": [
                    {"type": "string", "value": "'"},
                    {
                      "type": "array",
                      "value": []
                    },
                    {"type": "string", "value": ""}
                  ],
                  "postfixed": {"type": "parser_variable", "name": "template_string_body", "is_meta": false, "is_underscored": false}
                }
              }
            }
          ],
          "postfixed": {"type": "parser_variable", "name": "ast_node", "is_meta": false, "is_underscored": false}
        }
      },
      {
        "type": "assign",
        "left": {
          "type": "call_or_define_function",
          "value": [
            {"type": "parser_variable", "name": "end_quote", "is_meta": false, "is_underscored": false},
            {"type": "value_variable", "name": "TemplateParts", "is_meta": false, "is_underscored": false},
            {"type": "value_variable", "name": "Str", "is_meta": false, "is_underscored": false}
          ],
          "postfixed": {"type": "parser_variable", "name": "template_string_body", "is_meta": false, "is_underscored": false}
        },
        "right": {
          "type": "conditional",
          "middle": {
            "type": "call_or_define_function",
            "value": [
              {
                "type": "call_or_define_function",
                "value": [
                  {"type": "value_variable", "name": "TemplateParts", "is_meta": false, "is_underscored": false},
                  {"type": "value_variable", "name": "Str", "is_meta": false, "is_underscored": false}
                ],
                "postfixed": {"type": "value_variable", "name": "AppendNonEmptyString", "is_meta": false, "is_underscored": false}
              }
            ],
            "postfixed": {"type": "parser_variable", "name": "const", "is_meta": false, "is_underscored": false}
          },
          "left": {"type": "parser_variable", "name": "end_quote", "is_meta": false, "is_underscored": false},
          "right": {
            "type": "conditional",
            "middle": {
              "type": "and",
              "left": {
                "type": "destructure",
                "left": {
                  "type": "take_left",
                  "left": {"type": "parser_variable", "name": "expr", "is_meta": false, "is_underscored": false},
                  "right": {"type": "string", "value": ")"}
                },
                "right": {"type": "value_variable", "name": "Expr", "is_meta": false, "is_underscored": false}
              },
              "right": {
                "type": "call_or_define_function",
                "value": [
                  {"type": "parser_variable", "name": "end_quote", "is_meta": false, "is_underscored": false},
                  {
                    "type": "array",
                    "value": [
                      {
                        "type": "spread",
                        "prefixed": {
                          "type": "call_or_define_function",
                          "value": [
                            {"type": "value_variable", "name": "TemplateParts", "is_meta": false, "is_underscored": false},
                            {"type": "value_variable", "name": "Str", "is_meta": false, "is_underscored": false}
                          ],
                          "postfixed": {"type": "value_variable", "name": "AppendNonEmptyString", "is_meta": false, "is_underscored": false}
                        }
                      },
                      {"type": "value_variable", "name": "Expr", "is_meta": false, "is_underscored": false}
                    ]
                  },
                  {"type": "string", "value": ""}
                ],
                "postfixed": {"type": "parser_variable", "name": "template_string_body", "is_meta": false, "is_underscored": false}
              }
            },
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
                    "type": "call_or_define_function",
                    "value": [
                      {"type": "parser_variable", "name": "char", "is_meta": false, "is_underscored": false},
                      {"type": "string", "value": "\\"}
                    ],
                    "postfixed": {"type": "parser_variable", "name": "unless", "is_meta": false, "is_underscored": false}
                  }
                },
                "right": {"type": "value_variable", "name": "Next", "is_meta": false, "is_underscored": false}
              },
              "right": {
                "type": "call_or_define_function",
                "value": [
                  {"type": "parser_variable", "name": "end_quote", "is_meta": false, "is_underscored": false},
                  {"type": "value_variable", "name": "TemplateParts", "is_meta": false, "is_underscored": false},
                  {
                    "type": "merge",
                    "left": {"type": "value_variable", "name": "Str", "is_meta": false, "is_underscored": false},
                    "right": {"type": "value_variable", "name": "Next", "is_meta": false, "is_underscored": false}
                  }
                ],
                "postfixed": {"type": "parser_variable", "name": "template_string_body", "is_meta": false, "is_underscored": false}
              }
            }
          }
        }
      },
      {
        "type": "assign",
        "left": {
          "type": "call_or_define_function",
          "value": [
            {"type": "value_variable", "name": "TemplateParts", "is_meta": false, "is_underscored": false},
            {"type": "value_variable", "name": "Str", "is_meta": false, "is_underscored": false}
          ],
          "postfixed": {"type": "value_variable", "name": "AppendNonEmptyString", "is_meta": false, "is_underscored": false}
        },
        "right": {
          "type": "conditional",
          "middle": {"type": "value_variable", "name": "TemplateParts", "is_meta": false, "is_underscored": false},
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
        "type": "assign",
        "left": {
          "type": "call_or_define_function",
          "value": [
            {"type": "value_variable", "name": "Str", "is_meta": false, "is_underscored": false}
          ],
          "postfixed": {"type": "parser_variable", "name": "backtick_string_body", "is_meta": false, "is_underscored": false}
        },
        "right": {
          "type": "conditional",
          "middle": {
            "type": "call_or_define_function",
            "value": [
              {"type": "value_variable", "name": "Str", "is_meta": false, "is_underscored": false}
            ],
            "postfixed": {"type": "parser_variable", "name": "const", "is_meta": false, "is_underscored": false}
          },
          "left": {"type": "string", "value": "`"},
          "right": {
            "type": "and",
            "left": {
              "type": "destructure",
              "left": {"type": "parser_variable", "name": "char", "is_meta": false, "is_underscored": false},
              "right": {"type": "value_variable", "name": "Next", "is_meta": false, "is_underscored": false}
            },
            "right": {
              "type": "call_or_define_function",
              "value": [
                {
                  "type": "merge",
                  "left": {"type": "value_variable", "name": "Str", "is_meta": false, "is_underscored": false},
                  "right": {"type": "value_variable", "name": "Next", "is_meta": false, "is_underscored": false}
                }
              ],
              "postfixed": {"type": "parser_variable", "name": "backtick_string_body", "is_meta": false, "is_underscored": false}
            }
          }
        }
      },
      {
        "type": "assign",
        "left": {"type": "parser_variable", "name": "number_value", "is_meta": false, "is_underscored": false},
        "right": {
          "type": "call_or_define_function",
          "value": [
            {"type": "string", "value": "number"},
            {"type": "parser_variable", "name": "number", "is_meta": false, "is_underscored": false}
          ],
          "postfixed": {"type": "parser_variable", "name": "ast_node", "is_meta": false, "is_underscored": false}
        }
      },
      {
        "type": "assign",
        "left": {"type": "parser_variable", "name": "parser_variable_value", "is_meta": false, "is_underscored": false},
        "right": {
          "type": "and",
          "left": {
            "type": "destructure",
            "left": {
              "type": "call_or_define_function",
              "value": [
                {
                  "type": "call_or_define_function",
                  "value": [
                    {
                      "type": "call_or_define_function",
                      "value": [
                        {"type": "string", "value": "@"},
                        {"type": "parser_variable", "name": "succeed", "is_meta": false, "is_underscored": false}
                      ],
                      "postfixed": {"type": "parser_variable", "name": "boolean", "is_meta": false, "is_underscored": false}
                    },
                    {
                      "type": "call_or_define_function",
                      "value": [
                        {
                          "type": "call_or_define_function",
                          "value": [
                            {"type": "string", "value": "_"}
                          ],
                          "postfixed": {"type": "parser_variable", "name": "many", "is_meta": false, "is_underscored": false}
                        },
                        {"type": "parser_variable", "name": "succeed", "is_meta": false, "is_underscored": false}
                      ],
                      "postfixed": {"type": "parser_variable", "name": "boolean", "is_meta": false, "is_underscored": false}
                    }
                  ],
                  "postfixed": {"type": "parser_variable", "name": "tuple2", "is_meta": false, "is_underscored": false}
                }
              ],
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
                    "type": "merge",
                    "left": {
                      "type": "call_or_define_function",
                      "value": [
                        {"type": "string", "value": "@"}
                      ],
                      "postfixed": {"type": "parser_variable", "name": "maybe", "is_meta": false, "is_underscored": false}
                    },
                    "right": {
                      "type": "call_or_define_function",
                      "value": [
                        {"type": "string", "value": "_"}
                      ],
                      "postfixed": {"type": "parser_variable", "name": "maybe_many", "is_meta": false, "is_underscored": false}
                    }
                  },
                  "right": {"type": "parser_variable", "name": "lower", "is_meta": false, "is_underscored": false}
                },
                "right": {
                  "type": "call_or_define_function",
                  "value": [
                    {"type": "parser_variable", "name": "word", "is_meta": false, "is_underscored": false}
                  ],
                  "postfixed": {"type": "parser_variable", "name": "maybe", "is_meta": false, "is_underscored": false}
                }
              },
              "right": {"type": "value_variable", "name": "Name", "is_meta": false, "is_underscored": false}
            },
            "right": {
              "type": "object",
              "value": [
                [
                  {"type": "string", "value": "type"},
                  {"type": "string", "value": "parser_variable"}
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
        "type": "assign",
        "left": {"type": "parser_variable", "name": "value_variable_value", "is_meta": false, "is_underscored": false},
        "right": {
          "type": "and",
          "left": {
            "type": "destructure",
            "left": {
              "type": "call_or_define_function",
              "value": [
                {
                  "type": "call_or_define_function",
                  "value": [
                    {
                      "type": "call_or_define_function",
                      "value": [
                        {"type": "string", "value": "@"},
                        {"type": "parser_variable", "name": "succeed", "is_meta": false, "is_underscored": false}
                      ],
                      "postfixed": {"type": "parser_variable", "name": "boolean", "is_meta": false, "is_underscored": false}
                    },
                    {
                      "type": "call_or_define_function",
                      "value": [
                        {
                          "type": "call_or_define_function",
                          "value": [
                            {"type": "string", "value": "_"}
                          ],
                          "postfixed": {"type": "parser_variable", "name": "many", "is_meta": false, "is_underscored": false}
                        },
                        {"type": "parser_variable", "name": "succeed", "is_meta": false, "is_underscored": false}
                      ],
                      "postfixed": {"type": "parser_variable", "name": "boolean", "is_meta": false, "is_underscored": false}
                    }
                  ],
                  "postfixed": {"type": "parser_variable", "name": "tuple2", "is_meta": false, "is_underscored": false}
                }
              ],
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
                    "type": "merge",
                    "left": {
                      "type": "call_or_define_function",
                      "value": [
                        {"type": "string", "value": "@"}
                      ],
                      "postfixed": {"type": "parser_variable", "name": "maybe", "is_meta": false, "is_underscored": false}
                    },
                    "right": {
                      "type": "call_or_define_function",
                      "value": [
                        {"type": "string", "value": "_"}
                      ],
                      "postfixed": {"type": "parser_variable", "name": "maybe_many", "is_meta": false, "is_underscored": false}
                    }
                  },
                  "right": {"type": "parser_variable", "name": "upper", "is_meta": false, "is_underscored": false}
                },
                "right": {
                  "type": "call_or_define_function",
                  "value": [
                    {"type": "parser_variable", "name": "word", "is_meta": false, "is_underscored": false}
                  ],
                  "postfixed": {"type": "parser_variable", "name": "maybe", "is_meta": false, "is_underscored": false}
                }
              },
              "right": {"type": "value_variable", "name": "Name", "is_meta": false, "is_underscored": false}
            },
            "right": {
              "type": "object",
              "value": [
                [
                  {"type": "string", "value": "type"},
                  {"type": "string", "value": "value_variable"}
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
        "type": "assign",
        "left": {"type": "parser_variable", "name": "underscore_variable_value", "is_meta": false, "is_underscored": false},
        "right": {
          "type": "call_or_define_function",
          "value": [
            {"type": "string", "value": "underscore_variable"},
            {
              "type": "call_or_define_function",
              "value": [
                {"type": "string", "value": "_"}
              ],
              "postfixed": {"type": "parser_variable", "name": "many", "is_meta": false, "is_underscored": false}
            }
          ],
          "postfixed": {"type": "parser_variable", "name": "ast_node", "is_meta": false, "is_underscored": false}
        }
      },
      {
        "type": "assign",
        "left": {"type": "parser_variable", "name": "array_value", "is_meta": false, "is_underscored": false},
        "right": {
          "type": "call_or_define_function",
          "value": [
            {"type": "string", "value": "array"},
            {
              "type": "call_or_define_function",
              "value": [
                {"type": "parser_variable", "name": "expr", "is_meta": false, "is_underscored": false}
              ],
              "postfixed": {"type": "parser_variable", "name": "json_array", "is_meta": false, "is_underscored": false}
            }
          ],
          "postfixed": {"type": "parser_variable", "name": "ast_node", "is_meta": false, "is_underscored": false}
        }
      },
      {
        "type": "assign",
        "left": {"type": "parser_variable", "name": "object_value", "is_meta": false, "is_underscored": false},
        "right": {
          "type": "call_or_define_function",
          "value": [
            {"type": "string", "value": "object"},
            {
              "type": "take_left",
              "left": {
                "type": "take_right",
                "left": {"type": "string", "value": "{"},
                "right": {
                  "type": "call_or_define_function",
                  "value": [
                    {"type": "parser_variable", "name": "object_pair", "is_meta": false, "is_underscored": false},
                    {"type": "string", "value": ","}
                  ],
                  "postfixed": {"type": "parser_variable", "name": "maybe_array_sep", "is_meta": false, "is_underscored": false}
                }
              },
              "right": {"type": "string", "value": "}"}
            }
          ],
          "postfixed": {"type": "parser_variable", "name": "ast_node", "is_meta": false, "is_underscored": false}
        }
      },
      {
        "type": "assign",
        "left": {"type": "parser_variable", "name": "object_pair", "is_meta": false, "is_underscored": false},
        "right": {
          "type": "call_or_define_function",
          "value": [
            {
              "type": "call_or_define_function",
              "value": [
                {"type": "parser_variable", "name": "expr", "is_meta": false, "is_underscored": false}
              ],
              "postfixed": {"type": "parser_variable", "name": "ws_arround", "is_meta": false, "is_underscored": false}
            },
            {"type": "string", "value": ":"},
            {
              "type": "call_or_define_function",
              "value": [
                {"type": "parser_variable", "name": "expr", "is_meta": false, "is_underscored": false}
              ],
              "postfixed": {"type": "parser_variable", "name": "ws_arround", "is_meta": false, "is_underscored": false}
            }
          ],
          "postfixed": {"type": "parser_variable", "name": "tuple2_sep", "is_meta": false, "is_underscored": false}
        }
      },
      {
        "type": "assign",
        "left": {"type": "parser_variable", "name": "conditional_infix", "is_meta": false, "is_underscored": false},
        "right": {
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
                  {"type": "string", "value": "conditional"}
                ],
                [
                  {"type": "string", "value": "middle"},
                  {"type": "value_variable", "name": "Middle", "is_meta": false, "is_underscored": false}
                ]
              ]
            }
          }
        }
      },
      {
        "type": "assign",
        "left": {"type": "parser_variable", "name": "lower_bounded_range_postfix", "is_meta": false, "is_underscored": false},
        "right": {
          "type": "and",
          "left": {"type": "string", "value": ".."},
          "right": {
            "type": "return",
            "left": {
              "type": "call_or_define_function",
              "value": [
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
              "postfixed": {"type": "parser_variable", "name": "peek", "is_meta": false, "is_underscored": false}
            },
            "right": {
              "type": "object",
              "value": [
                [
                  {"type": "string", "value": "type"},
                  {"type": "string", "value": "lower_bounded_range"}
                ]
              ]
            }
          }
        }
      },
      {
        "type": "assign",
        "left": {"type": "parser_variable", "name": "call_or_define_function_postfix", "is_meta": false, "is_underscored": false},
        "right": {
          "type": "call_or_define_function",
          "value": [
            {"type": "string", "value": "call_or_define_function"},
            {
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
                    "type": "call_or_define_function",
                    "value": [
                      {
                        "type": "call_or_define_function",
                        "value": [
                          {"type": "parser_variable", "name": "expr", "is_meta": false, "is_underscored": false}
                        ],
                        "postfixed": {"type": "parser_variable", "name": "ws_arround", "is_meta": false, "is_underscored": false}
                      },
                      {"type": "string", "value": ","}
                    ],
                    "postfixed": {"type": "parser_variable", "name": "array_sep", "is_meta": false, "is_underscored": false}
                  }
                },
                "right": {"type": "parser_variable", "name": "w", "is_meta": false, "is_underscored": false}
              },
              "right": {"type": "string", "value": ")"}
            }
          ],
          "postfixed": {"type": "parser_variable", "name": "ast_node", "is_meta": false, "is_underscored": false}
        }
      },
      {
        "type": "assign",
        "left": {"type": "parser_variable", "name": "prefix", "is_meta": false, "is_underscored": false},
        "right": {
          "type": "or",
          "left": {
            "type": "or",
            "left": {
              "type": "call_or_define_function",
              "value": [
                {
                  "type": "return",
                  "left": {"type": "string", "value": "..."},
                  "right": {
                    "type": "object",
                    "value": [
                      [
                        {"type": "string", "value": "type"},
                        {"type": "string", "value": "spread"}
                      ]
                    ]
                  }
                },
                {"type": "number", "value": 8}
              ],
              "postfixed": {"type": "parser_variable", "name": "ast_op_precedence", "is_meta": false, "is_underscored": false}
            },
            "right": {
              "type": "call_or_define_function",
              "value": [
                {
                  "type": "return",
                  "left": {"type": "string", "value": ".."},
                  "right": {
                    "type": "object",
                    "value": [
                      [
                        {"type": "string", "value": "type"},
                        {"type": "string", "value": "upper_bounded_range"}
                      ]
                    ]
                  }
                },
                {"type": "number", "value": 7}
              ],
              "postfixed": {"type": "parser_variable", "name": "ast_op_precedence", "is_meta": false, "is_underscored": false}
            }
          },
          "right": {
            "type": "call_or_define_function",
            "value": [
              {
                "type": "return",
                "left": {"type": "string", "value": "-"},
                "right": {
                  "type": "object",
                  "value": [
                    [
                      {"type": "string", "value": "type"},
                      {"type": "string", "value": "negate"}
                    ]
                  ]
                }
              },
              {"type": "number", "value": 6}
            ],
            "postfixed": {"type": "parser_variable", "name": "ast_op_precedence", "is_meta": false, "is_underscored": false}
          }
        }
      },
      {
        "type": "assign",
        "left": {"type": "parser_variable", "name": "infix", "is_meta": false, "is_underscored": false},
        "right": {
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
                                "type": "call_or_define_function",
                                "value": [
                                  {
                                    "type": "return",
                                    "left": {"type": "string", "value": ".."},
                                    "right": {
                                      "type": "object",
                                      "value": [
                                        [
                                          {"type": "string", "value": "type"},
                                          {"type": "string", "value": "range"}
                                        ]
                                      ]
                                    }
                                  },
                                  {"type": "number", "value": 5},
                                  {"type": "number", "value": 5.5}
                                ],
                                "postfixed": {"type": "parser_variable", "name": "ast_infix_op_precedence", "is_meta": false, "is_underscored": false}
                              },
                              "right": {
                                "type": "call_or_define_function",
                                "value": [
                                  {
                                    "type": "return",
                                    "left": {"type": "string", "value": "|"},
                                    "right": {
                                      "type": "object",
                                      "value": [
                                        [
                                          {"type": "string", "value": "type"},
                                          {"type": "string", "value": "or"}
                                        ]
                                      ]
                                    }
                                  },
                                  {"type": "number", "value": 4},
                                  {"type": "number", "value": 4.5}
                                ],
                                "postfixed": {"type": "parser_variable", "name": "ast_infix_op_precedence", "is_meta": false, "is_underscored": false}
                              }
                            },
                            "right": {
                              "type": "call_or_define_function",
                              "value": [
                                {
                                  "type": "return",
                                  "left": {"type": "string", "value": ">"},
                                  "right": {
                                    "type": "object",
                                    "value": [
                                      [
                                        {"type": "string", "value": "type"},
                                        {"type": "string", "value": "take_right"}
                                      ]
                                    ]
                                  }
                                },
                                {"type": "number", "value": 4},
                                {"type": "number", "value": 4.5}
                              ],
                              "postfixed": {"type": "parser_variable", "name": "ast_infix_op_precedence", "is_meta": false, "is_underscored": false}
                            }
                          },
                          "right": {
                            "type": "call_or_define_function",
                            "value": [
                              {
                                "type": "return",
                                "left": {"type": "string", "value": "<"},
                                "right": {
                                  "type": "object",
                                  "value": [
                                    [
                                      {"type": "string", "value": "type"},
                                      {"type": "string", "value": "take_left"}
                                    ]
                                  ]
                                }
                              },
                              {"type": "number", "value": 4},
                              {"type": "number", "value": 4.5}
                            ],
                            "postfixed": {"type": "parser_variable", "name": "ast_infix_op_precedence", "is_meta": false, "is_underscored": false}
                          }
                        },
                        "right": {
                          "type": "call_or_define_function",
                          "value": [
                            {
                              "type": "return",
                              "left": {"type": "string", "value": "+"},
                              "right": {
                                "type": "object",
                                "value": [
                                  [
                                    {"type": "string", "value": "type"},
                                    {"type": "string", "value": "merge"}
                                  ]
                                ]
                              }
                            },
                            {"type": "number", "value": 4},
                            {"type": "number", "value": 4.5}
                          ],
                          "postfixed": {"type": "parser_variable", "name": "ast_infix_op_precedence", "is_meta": false, "is_underscored": false}
                        }
                      },
                      "right": {
                        "type": "call_or_define_function",
                        "value": [
                          {
                            "type": "return",
                            "left": {"type": "string", "value": "!"},
                            "right": {
                              "type": "object",
                              "value": [
                                [
                                  {"type": "string", "value": "type"},
                                  {"type": "string", "value": "backtrack"}
                                ]
                              ]
                            }
                          },
                          {"type": "number", "value": 4},
                          {"type": "number", "value": 4.5}
                        ],
                        "postfixed": {"type": "parser_variable", "name": "ast_infix_op_precedence", "is_meta": false, "is_underscored": false}
                      }
                    },
                    "right": {
                      "type": "call_or_define_function",
                      "value": [
                        {
                          "type": "return",
                          "left": {"type": "string", "value": "->"},
                          "right": {
                            "type": "object",
                            "value": [
                              [
                                {"type": "string", "value": "type"},
                                {"type": "string", "value": "destructure"}
                              ]
                            ]
                          }
                        },
                        {"type": "number", "value": 4},
                        {"type": "number", "value": 4.5}
                      ],
                      "postfixed": {"type": "parser_variable", "name": "ast_infix_op_precedence", "is_meta": false, "is_underscored": false}
                    }
                  },
                  "right": {
                    "type": "call_or_define_function",
                    "value": [
                      {
                        "type": "return",
                        "left": {"type": "string", "value": "$"},
                        "right": {
                          "type": "object",
                          "value": [
                            [
                              {"type": "string", "value": "type"},
                              {"type": "string", "value": "return"}
                            ]
                          ]
                        }
                      },
                      {"type": "number", "value": 4},
                      {"type": "number", "value": 4.5}
                    ],
                    "postfixed": {"type": "parser_variable", "name": "ast_infix_op_precedence", "is_meta": false, "is_underscored": false}
                  }
                },
                "right": {
                  "type": "call_or_define_function",
                  "value": [
                    {
                      "type": "return",
                      "left": {"type": "string", "value": "-"},
                      "right": {
                        "type": "object",
                        "value": [
                          [
                            {"type": "string", "value": "type"},
                            {"type": "string", "value": "number_subtract"}
                          ]
                        ]
                      }
                    },
                    {"type": "number", "value": 4},
                    {"type": "number", "value": 4.5}
                  ],
                  "postfixed": {"type": "parser_variable", "name": "ast_infix_op_precedence", "is_meta": false, "is_underscored": false}
                }
              },
              "right": {
                "type": "call_or_define_function",
                "value": [
                  {
                    "type": "return",
                    "left": {"type": "string", "value": "&"},
                    "right": {
                      "type": "object",
                      "value": [
                        [
                          {"type": "string", "value": "type"},
                          {"type": "string", "value": "and"}
                        ]
                      ]
                    }
                  },
                  {"type": "number", "value": 3},
                  {"type": "number", "value": 3.5}
                ],
                "postfixed": {"type": "parser_variable", "name": "ast_infix_op_precedence", "is_meta": false, "is_underscored": false}
              }
            },
            "right": {
              "type": "call_or_define_function",
              "value": [
                {"type": "parser_variable", "name": "conditional_infix", "is_meta": false, "is_underscored": false},
                {"type": "number", "value": 2.5},
                {"type": "number", "value": 2}
              ],
              "postfixed": {"type": "parser_variable", "name": "ast_infix_op_precedence", "is_meta": false, "is_underscored": false}
            }
          },
          "right": {
            "type": "call_or_define_function",
            "value": [
              {
                "type": "return",
                "left": {"type": "string", "value": "="},
                "right": {
                  "type": "object",
                  "value": [
                    [
                      {"type": "string", "value": "type"},
                      {"type": "string", "value": "assign"}
                    ]
                  ]
                }
              },
              {"type": "number", "value": 1.5},
              {"type": "number", "value": 1}
            ],
            "postfixed": {"type": "parser_variable", "name": "ast_infix_op_precedence", "is_meta": false, "is_underscored": false}
          }
        }
      },
      {
        "type": "assign",
        "left": {"type": "parser_variable", "name": "postfix", "is_meta": false, "is_underscored": false},
        "right": {
          "type": "or",
          "left": {
            "type": "call_or_define_function",
            "value": [
              {"type": "parser_variable", "name": "call_or_define_function_postfix", "is_meta": false, "is_underscored": false},
              {"type": "number", "value": 10}
            ],
            "postfixed": {"type": "parser_variable", "name": "ast_op_precedence", "is_meta": false, "is_underscored": false}
          },
          "right": {
            "type": "call_or_define_function",
            "value": [
              {"type": "parser_variable", "name": "lower_bounded_range_postfix", "is_meta": false, "is_underscored": false},
              {"type": "number", "value": 9}
            ],
            "postfixed": {"type": "parser_variable", "name": "ast_op_precedence", "is_meta": false, "is_underscored": false}
          }
        }
      }
    ]
  }
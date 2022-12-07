  $ possum input.linear_parser input_sample.txt
  [
    { "cmd": "cd", "dir": "/" },
    {
      "cmd": "ls",
      "output": [
        { "type": "dir", "name": "a" },
        { "type": "file", "size": 14848514, "name": "b.txt" },
        { "type": "file", "size": 8504156, "name": "c.dat" },
        { "type": "dir", "name": "d" }
      ]
    },
    { "cmd": "cd", "dir": "a" },
    {
      "cmd": "ls",
      "output": [
        { "type": "dir", "name": "e" },
        { "type": "file", "size": 29116, "name": "f" },
        { "type": "file", "size": 2557, "name": "g" },
        { "type": "file", "size": 62596, "name": "h.lst" }
      ]
    },
    { "cmd": "cd", "dir": "e" },
    { "cmd": "ls", "output": [ { "type": "file", "size": 584, "name": "i" } ] },
    { "cmd": "cd", "dir": ".." },
    { "cmd": "cd", "dir": ".." },
    { "cmd": "cd", "dir": "d" },
    {
      "cmd": "ls",
      "output": [
        { "type": "file", "size": 4060174, "name": "j" },
        { "type": "file", "size": 8033020, "name": "d.log" },
        { "type": "file", "size": 5626152, "name": "d.ext" },
        { "type": "file", "size": 7214296, "name": "k" }
      ]
    }
  ]

  $ possum input.tree_parser input.txt
  {
    "name": "/",
    "files": [
      { "name": "cmwllbzl.jlm", "size": 165965 },
      { "name": "ggb.qgd", "size": 68612 },
      { "name": "qgcn.rbj", "size": 211084 },
      { "name": "sdpjprfb.lsh", "size": 179881 },
      { "name": "tdhgd.lwf", "size": 318082 }
    ],
    "subdirs": [
      {
        "name": "gwnwqcgq",
        "files": [
          { "name": "cqsblt.jwb", "size": 310195 },
          { "name": "tbswl.btw", "size": 169518 }
        ],
        "subdirs": [
          {
            "name": "btddw",
            "files": [
              { "name": "hjs.dcw", "size": 315327 },
              { "name": "pmqmgjsw.rqn", "size": 99361 }
            ],
            "subdirs": [
              {
                "name": "pjmc",
                "files": [
                  { "name": "cfbfmprt", "size": 227980 },
                  { "name": "mmcrfwdr.sps", "size": 310835 },
                  { "name": "rhgmnqz", "size": 170798 },
                  { "name": "vphwlqqw.dlt", "size": 178337 }
                ],
                "subdirs": [
                  {
                    "name": "hml",
                    "files": [
                      { "name": "ggb", "size": 194693 },
                      { "name": "ldbhqdbd", "size": 175159 },
                      { "name": "qgbrczz.dhh", "size": 90811 },
                      { "name": "qvfdwcpn.cmv", "size": 118942 },
                      { "name": "rhgmnqz", "size": 227596 }
                    ],
                    "subdirs": [
                      {
                        "name": "fjtwgcw",
                        "files": [
                          { "name": "gfr", "size": 16046 },
                          { "name": "jwpzm.vhn", "size": 277037 },
                          { "name": "trpvvs.zgh", "size": 291671 }
                        ],
                        "subdirs": []
                      },
                      {
                        "name": "mzthvdms",
                        "files": [
                          { "name": "cqsblt.jwb", "size": 244911 },
                          { "name": "gplsqzr.nwn", "size": 37587 },
                          { "name": "tqrz.wfd", "size": 313958 }
                        ],
                        "subdirs": []
                      },
                      {
                        "name": "tnvsdr",
                        "files": [
                          { "name": "qgbrczz.dhh", "size": 185961 },
                          { "name": "wjgvlj.qcq", "size": 85515 }
                        ],
                        "subdirs": []
                      },
                      {
                        "name": "vplhff",
                        "files": [],
                        "subdirs": [
                          {
                            "name": "trjdm",
                            "files": [
                              { "name": "nhv.vgt", "size": 244126 },
                              { "name": "vlnwhgsc.tzm", "size": 795 }
                            ],
                            "subdirs": []
                          }
                        ]
                      }
                    ]
                  },
                  {
                    "name": "sdpjprfb",
                    "files": [],
                    "subdirs": [
                      {
                        "name": "htvgnrrl",
                        "files": [ { "name": "cfbfmprt", "size": 240529 } ],
                        "subdirs": []
                      }
                    ]
                  },
                  {
                    "name": "wnmh",
                    "files": [
                      { "name": "qgbrczz.dhh", "size": 322372 },
                      { "name": "tpfzqcs", "size": 184351 }
                    ],
                    "subdirs": [
                      {
                        "name": "gccwr",
                        "files": [ { "name": "tswtgpd.jsp", "size": 290656 } ],
                        "subdirs": []
                      },
                      {
                        "name": "rlhn",
                        "files": [ { "name": "gfr", "size": 208348 } ],
                        "subdirs": []
                      }
                    ]
                  },
                  {
                    "name": "zqcnhs",
                    "files": [
                      { "name": "pjmc.jwv", "size": 11336 },
                      { "name": "qgbrczz.dhh", "size": 5056 }
                    ],
                    "subdirs": [
                      {
                        "name": "dtfrbzgn",
                        "files": [
                          { "name": "gbvcnv", "size": 132783 },
                          { "name": "pjmc", "size": 298563 },
                          { "name": "sdpjprfb", "size": 81684 }
                        ],
                        "subdirs": [
                          {
                            "name": "ghbwbc",
                            "files": [],
                            "subdirs": [
                              {
                                "name": "zgvwrms",
                                "files": [
                                  { "name": "tlm.rlb", "size": 296919 }
                                ],
                                "subdirs": []
                              }
                            ]
                          }
                        ]
                      },
                      {
                        "name": "phhdmp",
                        "files": [],
                        "subdirs": [
                          {
                            "name": "ggb",
                            "files": [
                              { "name": "jrmgt.mqw", "size": 316842 },
                              { "name": "qrb.hpd", "size": 196423 }
                            ],
                            "subdirs": []
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
            "name": "ggb",
            "files": [
              { "name": "cqsblt.jwb", "size": 108630 },
              { "name": "fzvcgf", "size": 216771 },
              { "name": "gfr", "size": 135624 }
            ],
            "subdirs": [
              {
                "name": "fdmst",
                "files": [ { "name": "ldgpzcbr", "size": 20042 } ],
                "subdirs": [
                  {
                    "name": "gcq",
                    "files": [ { "name": "lvg.jpb", "size": 132662 } ],
                    "subdirs": []
                  },
                  {
                    "name": "nnp",
                    "files": [
                      { "name": "css.qfj", "size": 229401 },
                      { "name": "pjmc.hgp", "size": 17421 }
                    ],
                    "subdirs": []
                  },
                  {
                    "name": "pjmc",
                    "files": [ { "name": "pjmc.qph", "size": 317512 } ],
                    "subdirs": []
                  },
                  {
                    "name": "qng",
                    "files": [
                      { "name": "cvlnwltp", "size": 241771 },
                      { "name": "qgbrczz.dhh", "size": 91504 }
                    ],
                    "subdirs": []
                  },
                  {
                    "name": "sdpjprfb",
                    "files": [ { "name": "sdpjprfb.ljt", "size": 82422 } ],
                    "subdirs": []
                  }
                ]
              },
              {
                "name": "pdwln",
                "files": [],
                "subdirs": [
                  {
                    "name": "sdpjprfb",
                    "files": [ { "name": "ltfcmg.chw", "size": 285618 } ],
                    "subdirs": []
                  }
                ]
              },
              {
                "name": "sdpjprfb",
                "files": [ { "name": "cqsblt.jwb", "size": 58655 } ],
                "subdirs": []
              }
            ]
          },
          {
            "name": "hhdfbj",
            "files": [ { "name": "pslftrf.nqf", "size": 2937 } ],
            "subdirs": []
          },
          {
            "name": "hrj",
            "files": [
              { "name": "bcpl.shg", "size": 25769 },
              { "name": "hdwqmgwf", "size": 3722 },
              { "name": "qrvtsrs", "size": 300324 },
              { "name": "rhgmnqz", "size": 100487 },
              { "name": "tswtgpd.jsp", "size": 248216 }
            ],
            "subdirs": [
              {
                "name": "dfdtszr",
                "files": [],
                "subdirs": [
                  {
                    "name": "hfmnrlvj",
                    "files": [ { "name": "cqsblt.jwb", "size": 237362 } ],
                    "subdirs": []
                  },
                  {
                    "name": "plzr",
                    "files": [ { "name": "bjw.nlg", "size": 295398 } ],
                    "subdirs": []
                  },
                  {
                    "name": "zpspcph",
                    "files": [ { "name": "pjmc", "size": 87660 } ],
                    "subdirs": []
                  }
                ]
              },
              {
                "name": "ggb",
                "files": [],
                "subdirs": [
                  {
                    "name": "jtpb",
                    "files": [ { "name": "bfdl.jmv", "size": 249820 } ],
                    "subdirs": [
                      {
                        "name": "dggzszwn",
                        "files": [ { "name": "lrhwrh.mqm", "size": 233228 } ],
                        "subdirs": []
                      },
                      {
                        "name": "ggb",
                        "files": [ { "name": "tsbggqvp.fjl", "size": 88734 } ],
                        "subdirs": [
                          {
                            "name": "tcrjcmq",
                            "files": [
                              { "name": "wfdtbgf.hft", "size": 36677 }
                            ],
                            "subdirs": []
                          }
                        ]
                      },
                      {
                        "name": "whms",
                        "files": [],
                        "subdirs": [
                          {
                            "name": "ggb",
                            "files": [],
                            "subdirs": [
                              {
                                "name": "sdpjprfb",
                                "files": [
                                  { "name": "jhbdqn", "size": 177878 }
                                ],
                                "subdirs": []
                              }
                            ]
                          },
                          {
                            "name": "pjmc",
                            "files": [
                              { "name": "swmcmqq.clm", "size": 35345 }
                            ],
                            "subdirs": []
                          },
                          {
                            "name": "vtgcdprq",
                            "files": [ { "name": "gfr", "size": 293766 } ],
                            "subdirs": []
                          }
                        ]
                      }
                    ]
                  },
                  {
                    "name": "rsptqbh",
                    "files": [
                      { "name": "fszzvprc.phh", "size": 239634 },
                      { "name": "tswtgpd.jsp", "size": 240240 }
                    ],
                    "subdirs": [
                      {
                        "name": "csvpjd",
                        "files": [ { "name": "rndllvcd", "size": 218253 } ],
                        "subdirs": []
                      },
                      {
                        "name": "zjvc",
                        "files": [ { "name": "cqsblt.jwb", "size": 98002 } ],
                        "subdirs": []
                      }
                    ]
                  }
                ]
              },
              {
                "name": "nssjjtp",
                "files": [ { "name": "tswtgpd.jsp", "size": 63947 } ],
                "subdirs": []
              },
              {
                "name": "sdpjprfb",
                "files": [ { "name": "flbhswlb.ccd", "size": 30257 } ],
                "subdirs": [
                  {
                    "name": "cgczvvbg",
                    "files": [
                      { "name": "ggb.jrv", "size": 22048 },
                      { "name": "qgbrczz.dhh", "size": 142476 },
                      { "name": "wjfll.zdw", "size": 164431 }
                    ],
                    "subdirs": [
                      {
                        "name": "bntjhfd",
                        "files": [ { "name": "hpt.jll", "size": 217858 } ],
                        "subdirs": []
                      },
                      {
                        "name": "rchlvjb",
                        "files": [
                          { "name": "qrdrwtfw.dbd", "size": 208149 },
                          { "name": "vhs", "size": 100353 }
                        ],
                        "subdirs": []
                      },
                      {
                        "name": "vfrrnf",
                        "files": [ { "name": "jdz", "size": 3071 } ],
                        "subdirs": []
                      }
                    ]
                  },
                  {
                    "name": "qdqdv",
                    "files": [ { "name": "nvtr.ndw", "size": 26265 } ],
                    "subdirs": []
                  },
                  {
                    "name": "vqhps",
                    "files": [
                      { "name": "gfr", "size": 288263 },
                      { "name": "gfvsbqc", "size": 317973 },
                      { "name": "lqpwzz", "size": 284249 },
                      { "name": "vssw", "size": 185897 }
                    ],
                    "subdirs": [
                      {
                        "name": "njstt",
                        "files": [
                          { "name": "jgq.mvw", "size": 313561 },
                          { "name": "qgbrczz.dhh", "size": 110742 }
                        ],
                        "subdirs": []
                      },
                      {
                        "name": "rbhd",
                        "files": [
                          { "name": "cqsblt.jwb", "size": 11259 },
                          { "name": "ltfcmg.chw", "size": 286309 },
                          { "name": "srfgltg.nrz", "size": 281719 },
                          { "name": "tswtgpd.jsp", "size": 83632 },
                          { "name": "vrv.sll", "size": 141859 }
                        ],
                        "subdirs": [
                          {
                            "name": "gchzg",
                            "files": [],
                            "subdirs": [
                              {
                                "name": "phnz",
                                "files": [
                                  { "name": "mdrgcdl.vfp", "size": 212607 }
                                ],
                                "subdirs": []
                              }
                            ]
                          },
                          {
                            "name": "qmsntzj",
                            "files": [ { "name": "gfr", "size": 87958 } ],
                            "subdirs": []
                          },
                          {
                            "name": "sdpjprfb",
                            "files": [ { "name": "ggb.wnf", "size": 110482 } ],
                            "subdirs": []
                          },
                          {
                            "name": "vsg",
                            "files": [ { "name": "sdpjprfb", "size": 232499 } ],
                            "subdirs": []
                          },
                          {
                            "name": "wbqshdm",
                            "files": [],
                            "subdirs": [
                              {
                                "name": "pjmc",
                                "files": [ { "name": "pjmc", "size": 273630 } ],
                                "subdirs": []
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
                "name": "tmdtrqsl",
                "files": [ { "name": "sqfj.hrg", "size": 139366 } ],
                "subdirs": []
              }
            ]
          },
          {
            "name": "mdhln",
            "files": [],
            "subdirs": [
              {
                "name": "bftszdgn",
                "files": [
                  { "name": "cplch.dsb", "size": 206539 },
                  { "name": "cqsblt.jwb", "size": 201607 },
                  { "name": "gdz.plv", "size": 207839 },
                  { "name": "ltfcmg.chw", "size": 72021 },
                  { "name": "wvf.zvc", "size": 106046 }
                ],
                "subdirs": [
                  {
                    "name": "ggb",
                    "files": [
                      { "name": "cqsblt.jwb", "size": 242347 },
                      { "name": "ltfcmg.chw", "size": 272603 },
                      { "name": "nrrz.dfj", "size": 273519 },
                      { "name": "pjmc", "size": 5628 }
                    ],
                    "subdirs": []
                  },
                  {
                    "name": "nddh",
                    "files": [ { "name": "ltfcmg.chw", "size": 243243 } ],
                    "subdirs": []
                  }
                ]
              },
              {
                "name": "crhbc",
                "files": [
                  { "name": "ltfcmg.chw", "size": 120001 },
                  { "name": "qgbrczz.dhh", "size": 120308 }
                ],
                "subdirs": [
                  {
                    "name": "ccw",
                    "files": [],
                    "subdirs": [
                      {
                        "name": "fgghhg",
                        "files": [
                          { "name": "czpsmdm", "size": 238488 },
                          { "name": "ggb", "size": 150925 },
                          { "name": "qgbrczz.dhh", "size": 134050 }
                        ],
                        "subdirs": []
                      },
                      {
                        "name": "pjmc",
                        "files": [ { "name": "sdpjprfb.bmh", "size": 138343 } ],
                        "subdirs": []
                      }
                    ]
                  },
                  {
                    "name": "ggb",
                    "files": [ { "name": "rffmjwpm", "size": 157435 } ],
                    "subdirs": [
                      {
                        "name": "sdpjprfb",
                        "files": [],
                        "subdirs": [
                          {
                            "name": "jwjpwbdj",
                            "files": [
                              { "name": "tswtgpd.jsp", "size": 88782 }
                            ],
                            "subdirs": []
                          }
                        ]
                      },
                      {
                        "name": "tbd",
                        "files": [ { "name": "vclsjppl.jws", "size": 203640 } ],
                        "subdirs": []
                      },
                      {
                        "name": "zgmffgdz",
                        "files": [ { "name": "ggb", "size": 203870 } ],
                        "subdirs": [
                          {
                            "name": "jhcrw",
                            "files": [ { "name": "gfr", "size": 70775 } ],
                            "subdirs": []
                          }
                        ]
                      }
                    ]
                  },
                  {
                    "name": "pcqcswz",
                    "files": [ { "name": "zlwc.rnh", "size": 260246 } ],
                    "subdirs": []
                  },
                  {
                    "name": "sscfn",
                    "files": [
                      { "name": "bjtwwgf", "size": 75162 },
                      { "name": "ggb", "size": 265717 },
                      { "name": "gsbj.nzd", "size": 230679 },
                      { "name": "ltfcmg.chw", "size": 17708 }
                    ],
                    "subdirs": [
                      {
                        "name": "cfthmzh",
                        "files": [
                          { "name": "chgws.qfd", "size": 296793 },
                          { "name": "pjmc", "size": 187701 },
                          { "name": "qgbrczz.dhh", "size": 29681 }
                        ],
                        "subdirs": []
                      },
                      {
                        "name": "pdgwcshp",
                        "files": [],
                        "subdirs": [
                          {
                            "name": "cfbfmprt",
                            "files": [],
                            "subdirs": [
                              {
                                "name": "rwflz",
                                "files": [
                                  { "name": "gtt.qcl", "size": 33792 }
                                ],
                                "subdirs": [
                                  {
                                    "name": "jrblfq",
                                    "files": [
                                      { "name": "cqsblt.jwb", "size": 224257 }
                                    ],
                                    "subdirs": []
                                  },
                                  {
                                    "name": "rldtppt",
                                    "files": [],
                                    "subdirs": [
                                      {
                                        "name": "nzgg",
                                        "files": [
                                          {
                                            "name": "fhbw.vhm",
                                            "size": 139560
                                          }
                                        ],
                                        "subdirs": []
                                      }
                                    ]
                                  }
                                ]
                              }
                            ]
                          },
                          {
                            "name": "lqbh",
                            "files": [],
                            "subdirs": [
                              {
                                "name": "mhdbp",
                                "files": [
                                  { "name": "wtc.cfd", "size": 28344 }
                                ],
                                "subdirs": [
                                  {
                                    "name": "ggb",
                                    "files": [
                                      {
                                        "name": "rvdpjmgt.szq",
                                        "size": 220117
                                      }
                                    ],
                                    "subdirs": [
                                      {
                                        "name": "hwdtp",
                                        "files": [
                                          {
                                            "name": "cqsblt.jwb",
                                            "size": 288606
                                          }
                                        ],
                                        "subdirs": []
                                      }
                                    ]
                                  }
                                ]
                              },
                              {
                                "name": "nqsz",
                                "files": [
                                  { "name": "dpjfbs.rvc", "size": 197106 },
                                  { "name": "pjl", "size": 55173 }
                                ],
                                "subdirs": []
                              }
                            ]
                          },
                          {
                            "name": "rrtpqd",
                            "files": [ { "name": "pjmc", "size": 178 } ],
                            "subdirs": []
                          }
                        ]
                      },
                      {
                        "name": "ztrpvlbh",
                        "files": [
                          { "name": "bhb.pmw", "size": 201371 },
                          { "name": "ddqjnzvw.rdd", "size": 188328 },
                          { "name": "tswtgpd.jsp", "size": 206451 }
                        ],
                        "subdirs": []
                      }
                    ]
                  },
                  {
                    "name": "vpsj",
                    "files": [
                      { "name": "cqsblt.jwb", "size": 5614 },
                      { "name": "ctmdnwgt.pgj", "size": 300968 }
                    ],
                    "subdirs": []
                  }
                ]
              },
              {
                "name": "ggb",
                "files": [
                  { "name": "hzgq.tsb", "size": 14512 },
                  { "name": "pjmc.tlj", "size": 302375 },
                  { "name": "zdsbj", "size": 282216 }
                ],
                "subdirs": [
                  {
                    "name": "ggb",
                    "files": [
                      { "name": "brpqch.plw", "size": 180980 },
                      { "name": "ltfcmg.chw", "size": 42195 },
                      { "name": "qgbrczz.dhh", "size": 322227 }
                    ],
                    "subdirs": []
                  },
                  {
                    "name": "thhgz",
                    "files": [
                      { "name": "cfbfmprt.cmp", "size": 74145 },
                      { "name": "gfr", "size": 253851 },
                      { "name": "gsb", "size": 272552 },
                      { "name": "tswtgpd.jsp", "size": 276958 }
                    ],
                    "subdirs": [
                      {
                        "name": "pgfqw",
                        "files": [
                          { "name": "ggb.zjg", "size": 193634 },
                          { "name": "qrml.bvv", "size": 185688 }
                        ],
                        "subdirs": []
                      }
                    ]
                  },
                  {
                    "name": "zrzmb",
                    "files": [
                      { "name": "gfr", "size": 84603 },
                      { "name": "sbscbqg.jfg", "size": 253620 }
                    ],
                    "subdirs": [
                      {
                        "name": "chjmbq",
                        "files": [],
                        "subdirs": [
                          {
                            "name": "svmvlm",
                            "files": [
                              { "name": "nhjwcjj.dgz", "size": 251057 }
                            ],
                            "subdirs": []
                          }
                        ]
                      },
                      {
                        "name": "rbms",
                        "files": [ { "name": "tswtgpd.jsp", "size": 72618 } ],
                        "subdirs": []
                      }
                    ]
                  }
                ]
              },
              {
                "name": "jhmvgjrr",
                "files": [
                  { "name": "cqsblt.jwb", "size": 189022 },
                  { "name": "djp.npm", "size": 172682 },
                  { "name": "ggb", "size": 147256 },
                  { "name": "rhgmnqz", "size": 110715 },
                  { "name": "tswtgpd.jsp", "size": 183342 }
                ],
                "subdirs": [
                  {
                    "name": "gdfgtz",
                    "files": [
                      { "name": "cqsblt.jwb", "size": 268771 },
                      { "name": "dgrwz", "size": 190140 },
                      { "name": "sdpjprfb.dpw", "size": 248802 }
                    ],
                    "subdirs": []
                  },
                  {
                    "name": "ghv",
                    "files": [ { "name": "qzjtnr.qcf", "size": 304352 } ],
                    "subdirs": [
                      {
                        "name": "ggb",
                        "files": [ { "name": "ltfcmg.chw", "size": 285635 } ],
                        "subdirs": [
                          {
                            "name": "vzfdbtg",
                            "files": [],
                            "subdirs": [
                              {
                                "name": "pqmb",
                                "files": [
                                  { "name": "ggb.nmh", "size": 219019 }
                                ],
                                "subdirs": []
                              }
                            ]
                          }
                        ]
                      },
                      {
                        "name": "npqbngg",
                        "files": [ { "name": "cqsblt.jwb", "size": 242286 } ],
                        "subdirs": [
                          {
                            "name": "cfbfmprt",
                            "files": [
                              { "name": "cqsblt.jwb", "size": 34347 }
                            ],
                            "subdirs": [
                              {
                                "name": "gpnzggqb",
                                "files": [
                                  { "name": "tswtgpd.jsp", "size": 192404 },
                                  { "name": "vdb.rzm", "size": 88344 }
                                ],
                                "subdirs": [
                                  {
                                    "name": "pjmc",
                                    "files": [
                                      { "name": "psbppvhn", "size": 142330 },
                                      { "name": "qgbrczz.dhh", "size": 168892 },
                                      { "name": "vzzc.mtd", "size": 18858 },
                                      { "name": "zmjhz.tdv", "size": 135911 }
                                    ],
                                    "subdirs": [
                                      {
                                        "name": "pjmc",
                                        "files": [
                                          { "name": "mlf", "size": 197370 },
                                          { "name": "nwq.njv", "size": 36218 }
                                        ],
                                        "subdirs": []
                                      }
                                    ]
                                  },
                                  {
                                    "name": "pqbf",
                                    "files": [
                                      { "name": "gfr", "size": 233005 }
                                    ],
                                    "subdirs": []
                                  },
                                  {
                                    "name": "qjpwm",
                                    "files": [
                                      { "name": "qqmrm.jrj", "size": 129132 },
                                      { "name": "tswtgpd.jsp", "size": 6309 }
                                    ],
                                    "subdirs": []
                                  },
                                  {
                                    "name": "zjglfpt",
                                    "files": [
                                      { "name": "qgbrczz.dhh", "size": 186963 }
                                    ],
                                    "subdirs": []
                                  }
                                ]
                              },
                              {
                                "name": "nvdqw",
                                "files": [
                                  { "name": "fcgrqq", "size": 147955 },
                                  { "name": "gfr", "size": 224829 }
                                ],
                                "subdirs": []
                              },
                              {
                                "name": "qdtcwm",
                                "files": [
                                  { "name": "ltfcmg.chw", "size": 36443 }
                                ],
                                "subdirs": []
                              },
                              {
                                "name": "ssgg",
                                "files": [
                                  { "name": "jddfdj", "size": 250574 }
                                ],
                                "subdirs": []
                              }
                            ]
                          },
                          {
                            "name": "hrqfqpzr",
                            "files": [ { "name": "pjmc", "size": 143568 } ],
                            "subdirs": [
                              {
                                "name": "sdpjprfb",
                                "files": [
                                  { "name": "rhgmnqz", "size": 88050 }
                                ],
                                "subdirs": []
                              },
                              {
                                "name": "shcrrpc",
                                "files": [],
                                "subdirs": [
                                  {
                                    "name": "pjmc",
                                    "files": [],
                                    "subdirs": [
                                      {
                                        "name": "wbj",
                                        "files": [
                                          { "name": "gfr", "size": 196127 }
                                        ],
                                        "subdirs": []
                                      }
                                    ]
                                  },
                                  {
                                    "name": "pwnnmpm",
                                    "files": [],
                                    "subdirs": [
                                      {
                                        "name": "cgghrf",
                                        "files": [
                                          {
                                            "name": "lbpfnccl.mtj",
                                            "size": 108742
                                          }
                                        ],
                                        "subdirs": []
                                      },
                                      {
                                        "name": "rhgmnqz",
                                        "files": [
                                          {
                                            "name": "qgbrczz.dhh",
                                            "size": 89791
                                          }
                                        ],
                                        "subdirs": []
                                      },
                                      {
                                        "name": "vnbvq",
                                        "files": [
                                          {
                                            "name": "ltfcmg.chw",
                                            "size": 48961
                                          },
                                          {
                                            "name": "qgbrczz.dhh",
                                            "size": 241813
                                          }
                                        ],
                                        "subdirs": []
                                      }
                                    ]
                                  }
                                ]
                              }
                            ]
                          },
                          {
                            "name": "nsnfq",
                            "files": [],
                            "subdirs": [
                              {
                                "name": "tgdqz",
                                "files": [],
                                "subdirs": [
                                  {
                                    "name": "ggb",
                                    "files": [],
                                    "subdirs": [
                                      {
                                        "name": "rhgmnqz",
                                        "files": [
                                          {
                                            "name": "cfbfmprt.tbl",
                                            "size": 268661
                                          }
                                        ],
                                        "subdirs": []
                                      }
                                    ]
                                  }
                                ]
                              }
                            ]
                          },
                          {
                            "name": "rggzmfqm",
                            "files": [
                              { "name": "qqn", "size": 177501 },
                              { "name": "sdpjprfb.srj", "size": 55857 }
                            ],
                            "subdirs": []
                          },
                          {
                            "name": "wjdnwg",
                            "files": [
                              { "name": "lsjvsmsv", "size": 147729 },
                              { "name": "pjmc", "size": 242095 },
                              { "name": "sdpjprfb.cwf", "size": 237172 },
                              { "name": "tswtgpd.jsp", "size": 203791 }
                            ],
                            "subdirs": [
                              {
                                "name": "sqh",
                                "files": [
                                  { "name": "cfbfmprt", "size": 44848 },
                                  { "name": "cqsblt.jwb", "size": 214010 },
                                  { "name": "gfr", "size": 175692 },
                                  { "name": "lgsncr", "size": 107978 }
                                ],
                                "subdirs": []
                              },
                              {
                                "name": "zgfz",
                                "files": [
                                  { "name": "cfbfmprt.gpf", "size": 184114 },
                                  { "name": "qgbrczz.dhh", "size": 207186 }
                                ],
                                "subdirs": []
                              }
                            ]
                          }
                        ]
                      },
                      {
                        "name": "sdpjprfb",
                        "files": [ { "name": "hfbvz", "size": 73238 } ],
                        "subdirs": []
                      }
                    ]
                  },
                  {
                    "name": "pjmc",
                    "files": [ { "name": "cqsblt.jwb", "size": 210824 } ],
                    "subdirs": [
                      {
                        "name": "pllr",
                        "files": [
                          { "name": "ltfcmg.chw", "size": 210365 },
                          { "name": "rhgmnqz.wbc", "size": 96591 },
                          { "name": "tswtgpd.jsp", "size": 123059 }
                        ],
                        "subdirs": [
                          {
                            "name": "fshjdzp",
                            "files": [ { "name": "sdpjprfb", "size": 143719 } ],
                            "subdirs": []
                          },
                          {
                            "name": "rfbdg",
                            "files": [
                              { "name": "wllggqm.wcg", "size": 242103 }
                            ],
                            "subdirs": []
                          },
                          {
                            "name": "rzzwcb",
                            "files": [],
                            "subdirs": [
                              {
                                "name": "rhgmnqz",
                                "files": [
                                  { "name": "cqsblt.jwb", "size": 80525 }
                                ],
                                "subdirs": []
                              }
                            ]
                          },
                          {
                            "name": "zzcw",
                            "files": [ { "name": "jtgzqh", "size": 260646 } ],
                            "subdirs": []
                          }
                        ]
                      },
                      {
                        "name": "tqqjp",
                        "files": [ { "name": "vszrfcc", "size": 245089 } ],
                        "subdirs": []
                      }
                    ]
                  },
                  {
                    "name": "sdpjprfb",
                    "files": [ { "name": "cfbfmprt.dvj", "size": 7514 } ],
                    "subdirs": []
                  },
                  {
                    "name": "tjlf",
                    "files": [],
                    "subdirs": [
                      {
                        "name": "pjmc",
                        "files": [
                          { "name": "cfbfmprt.mqf", "size": 230234 },
                          { "name": "gfr", "size": 197486 }
                        ],
                        "subdirs": []
                      }
                    ]
                  }
                ]
              },
              {
                "name": "pjmc",
                "files": [
                  { "name": "fblsvg.btt", "size": 19935 },
                  { "name": "gjl.zrv", "size": 222906 },
                  { "name": "jfqqjzbd", "size": 84255 }
                ],
                "subdirs": [
                  {
                    "name": "fgvv",
                    "files": [
                      { "name": "dgn", "size": 94831 },
                      { "name": "tswtgpd.jsp", "size": 312078 },
                      { "name": "vzbl.mnq", "size": 132961 }
                    ],
                    "subdirs": []
                  },
                  {
                    "name": "ggb",
                    "files": [ { "name": "msdr.wnh", "size": 310301 } ],
                    "subdirs": [
                      {
                        "name": "hfcr",
                        "files": [ { "name": "dnp.lcn", "size": 318041 } ],
                        "subdirs": [
                          {
                            "name": "mjrhdq",
                            "files": [
                              { "name": "ctrrm.ljc", "size": 18541 },
                              { "name": "pjmc", "size": 247841 }
                            ],
                            "subdirs": []
                          },
                          {
                            "name": "qwvfg",
                            "files": [
                              { "name": "clvgmp.cvb", "size": 128875 },
                              { "name": "cqsblt.jwb", "size": 138276 },
                              { "name": "tswtgpd.jsp", "size": 26303 }
                            ],
                            "subdirs": []
                          }
                        ]
                      }
                    ]
                  },
                  {
                    "name": "pjmc",
                    "files": [ { "name": "ltfcmg.chw", "size": 106609 } ],
                    "subdirs": []
                  }
                ]
              },
              {
                "name": "sgpnzv",
                "files": [
                  { "name": "ltfcmg.chw", "size": 218397 },
                  { "name": "sdpjprfb.mfd", "size": 233365 }
                ],
                "subdirs": []
              }
            ]
          },
          {
            "name": "nwbndtgl",
            "files": [ { "name": "sdpjprfb.shs", "size": 198516 } ],
            "subdirs": [
              {
                "name": "fsdvzvvv",
                "files": [
                  { "name": "ggb", "size": 209527 },
                  { "name": "msgsztv.hnq", "size": 99039 },
                  { "name": "rhgmnqz", "size": 104248 }
                ],
                "subdirs": [
                  {
                    "name": "llwbm",
                    "files": [
                      { "name": "ghr.crq", "size": 187895 },
                      { "name": "qpr.gnm", "size": 274721 }
                    ],
                    "subdirs": [
                      {
                        "name": "qrrs",
                        "files": [ { "name": "mnmhqww", "size": 260559 } ],
                        "subdirs": []
                      }
                    ]
                  },
                  {
                    "name": "lzz",
                    "files": [],
                    "subdirs": [
                      {
                        "name": "tnmwncgl",
                        "files": [ { "name": "hqz", "size": 301449 } ],
                        "subdirs": []
                      },
                      {
                        "name": "wrjjmhz",
                        "files": [
                          { "name": "mdv", "size": 145193 },
                          { "name": "zjwlt.vqf", "size": 73533 }
                        ],
                        "subdirs": []
                      }
                    ]
                  }
                ]
              }
            ]
          },
          {
            "name": "pjmc",
            "files": [
              { "name": "cqsblt.jwb", "size": 40049 },
              { "name": "gvwcdhvn", "size": 169928 },
              { "name": "qgbrczz.dhh", "size": 314117 }
            ],
            "subdirs": []
          },
          {
            "name": "rgb",
            "files": [
              { "name": "cqsblt.jwb", "size": 57953 },
              { "name": "fvdpqr.vdz", "size": 240228 },
              { "name": "ltfcmg.chw", "size": 173344 },
              { "name": "sdpjprfb.qlh", "size": 28301 }
            ],
            "subdirs": [
              {
                "name": "bvwn",
                "files": [],
                "subdirs": [
                  {
                    "name": "cfbfmprt",
                    "files": [ { "name": "zmlrt.zwb", "size": 234044 } ],
                    "subdirs": [
                      {
                        "name": "vndbzj",
                        "files": [],
                        "subdirs": [
                          {
                            "name": "cfbfmprt",
                            "files": [],
                            "subdirs": [
                              {
                                "name": "ptzpcqh",
                                "files": [
                                  { "name": "cqsblt.jwb", "size": 141535 }
                                ],
                                "subdirs": []
                              }
                            ]
                          }
                        ]
                      }
                    ]
                  },
                  {
                    "name": "fjmbvhh",
                    "files": [
                      { "name": "gfr", "size": 244287 },
                      { "name": "rhgmnqz.bsq", "size": 146029 }
                    ],
                    "subdirs": []
                  },
                  {
                    "name": "ggb",
                    "files": [ { "name": "tswtgpd.jsp", "size": 279627 } ],
                    "subdirs": []
                  },
                  {
                    "name": "pdgsf",
                    "files": [
                      { "name": "qncpwnsw.jnc", "size": 21454 },
                      { "name": "sdpjprfb.mmp", "size": 49920 },
                      { "name": "tswtgpd.jsp", "size": 318538 }
                    ],
                    "subdirs": [
                      {
                        "name": "fjdlhn",
                        "files": [],
                        "subdirs": [
                          {
                            "name": "rhgmnqz",
                            "files": [ { "name": "wggmwlfm", "size": 209357 } ],
                            "subdirs": []
                          }
                        ]
                      }
                    ]
                  },
                  {
                    "name": "sdpjprfb",
                    "files": [ { "name": "rhgmnqz.wrv", "size": 39774 } ],
                    "subdirs": []
                  }
                ]
              },
              {
                "name": "pjmc",
                "files": [
                  { "name": "flhtvnq.gzc", "size": 115169 },
                  { "name": "ltfcmg.chw", "size": 147102 },
                  { "name": "rnn.cpc", "size": 279604 }
                ],
                "subdirs": []
              }
            ]
          },
          {
            "name": "sdpjprfb",
            "files": [
              { "name": "rhgmnqz", "size": 170481 },
              { "name": "szgwfcl.tlh", "size": 48045 },
              { "name": "tnfdmgfl", "size": 110279 }
            ],
            "subdirs": []
          }
        ]
      },
      {
        "name": "pdlpwdp",
        "files": [ { "name": "tswtgpd.jsp", "size": 59208 } ],
        "subdirs": [
          {
            "name": "fwsbsprp",
            "files": [ { "name": "rhczscsq.gmb", "size": 177666 } ],
            "subdirs": []
          },
          {
            "name": "gjjjwznz",
            "files": [
              { "name": "cpft.fvj", "size": 163647 },
              { "name": "gfr", "size": 60316 }
            ],
            "subdirs": []
          },
          {
            "name": "jzpwnpmc",
            "files": [ { "name": "ltfcmg.chw", "size": 46041 } ],
            "subdirs": [
              {
                "name": "cfbfmprt",
                "files": [ { "name": "cqsblt.jwb", "size": 16870 } ],
                "subdirs": [
                  {
                    "name": "slj",
                    "files": [ { "name": "gdjb.rfv", "size": 291893 } ],
                    "subdirs": []
                  }
                ]
              },
              {
                "name": "gpd",
                "files": [ { "name": "qgbrczz.dhh", "size": 159168 } ],
                "subdirs": []
              }
            ]
          },
          {
            "name": "qlvfslzp",
            "files": [
              { "name": "ggb.tth", "size": 102746 },
              { "name": "pjmc.hsc", "size": 35817 },
              { "name": "sgf.ssl", "size": 296043 },
              { "name": "wbhbmbm.bpz", "size": 134188 },
              { "name": "zdjmnjt.smn", "size": 153495 }
            ],
            "subdirs": [
              {
                "name": "clnms",
                "files": [],
                "subdirs": [
                  {
                    "name": "ggb",
                    "files": [ { "name": "rhgmnqz.bht", "size": 305684 } ],
                    "subdirs": []
                  }
                ]
              },
              {
                "name": "sdpjprfb",
                "files": [ { "name": "ghsjjc", "size": 29970 } ],
                "subdirs": []
              },
              {
                "name": "sqhbbsbj",
                "files": [ { "name": "pjmc.mzd", "size": 150243 } ],
                "subdirs": []
              }
            ]
          },
          {
            "name": "sdpjprfb",
            "files": [],
            "subdirs": [
              {
                "name": "cfbfmprt",
                "files": [],
                "subdirs": [
                  {
                    "name": "ggb",
                    "files": [ { "name": "jtcfv.mvc", "size": 158203 } ],
                    "subdirs": [
                      {
                        "name": "qnqcb",
                        "files": [ { "name": "cqsblt.jwb", "size": 71245 } ],
                        "subdirs": []
                      }
                    ]
                  }
                ]
              },
              {
                "name": "qnhl",
                "files": [],
                "subdirs": [
                  {
                    "name": "sdpjprfb",
                    "files": [ { "name": "cqsblt.jwb", "size": 306685 } ],
                    "subdirs": []
                  }
                ]
              }
            ]
          }
        ]
      },
      {
        "name": "sbps",
        "files": [
          { "name": "cqsblt.jwb", "size": 251286 },
          { "name": "rhgmnqz.nzh", "size": 213946 },
          { "name": "zhzslc.bvp", "size": 13484 }
        ],
        "subdirs": [
          {
            "name": "pjmc",
            "files": [
              { "name": "tswtgpd.jsp", "size": 9892 },
              { "name": "wjb.rwq", "size": 249059 }
            ],
            "subdirs": []
          }
        ]
      },
      {
        "name": "wvdlv",
        "files": [ { "name": "qlbqgp.njq", "size": 314303 } ],
        "subdirs": []
      }
    ]
  }

local ls = require("luasnip")
local extras = require("luasnip.extras")
local fmt = require("luasnip.extras.fmt").fmt
local s = ls.snippet
local sn = ls.snippet_node
local c = ls.choice_node
local i = ls.insert_node
local r = ls.restore_node
local t = ls.text_node
local f = ls.function_node
local k = require("luasnip.nodes.key_indexer").new_key
local d = ls.dynamic_node
local rep = extras.rep

c_snippets = {
  s({ trig = "stdbool", docstring = "Include <stdbool.h>" }, {
    t("#include <stdbool.h>"),
  }),
  s({ trig = "stdint", docstring = "Include <stdint.h>" }, {
    t("#include <stdint.h>"),
  }),
  s({ trig = "assert", docstring = "Include <assert.h>" }, {
    t("#include <assert.h>"),
  }),
}

cpp_snippets = {
  s({ trig = "stdbool", docstring = "Include <stdbool.h>" }, {
    t("#include <cstdbool>"),
  }),
  s({ trig = "stdint", docstring = "Include <stdint.h>" }, {
    t("#include <cstdint>"),
  }),
  s({ trig = "assert", docstring = "Include <assert.h>" }, {
    t("#include <cassert>"),
  }),
}

c_and_cpp_snippets = {
  s({ trig = "cpp", docstring = "C++ extern #define" },
    fmt("#if defined(__cplusplus)\n{}\n#endif\n", {
      c(1, { i(1, "extern \"C\" {"), i(2, "}"), })
    })
  ),
  s({ trig = "fprintf", docstring = "fprintf" }, {
    t("fprintf("),
    c(1, { i(1, "stderr"), i(2, "fp"), }),
    t(', "'), i(2, ""), t('\\n"'),
    d(3, function(values)
      local fmt_string = values[1][1]
      local nodes = {}
      for _ in fmt_string:gmatch("%%[^%%]") do
        local idx = #nodes / 2 + 1
        table.insert(nodes, t(", "))
        table.insert(nodes, r(idx, "arg" .. idx, i(nil, "arg" .. idx)))
      end
      return sn(1, nodes)
    end, { 2 }),
    t(");"),
  }, {
    stored = {},
  }),

  s({ trig = "printf", docstring = "printf" }, {
    t('printf("'),
    i(1, ""), t('\\n"'),
    d(2, function(values)
      local fmt_string = values[1][1]
      local nodes = {}
      for _ in fmt_string:gmatch("%%[^%%]") do
        local idx = #nodes / 2 + 1
        table.insert(nodes, t(", "))
        table.insert(nodes, r(idx, "arg" .. idx, i(nil, "arg" .. idx)))
      end
      return sn(1, nodes)
    end, { 1 }),
    t(");"),
  }, {
    stored = {},
  }),
}

ls.add_snippets("c", c_snippets, { key = "thecomet-c" })
ls.add_snippets("cpp", cpp_snippets, { key = "thecomet-cpp" })
ls.add_snippets("c", c_and_cpp_snippets, { key = "thecomet-c" })
ls.add_snippets("cpp", c_and_cpp_snippets, { key = "thecomet-cpp" })

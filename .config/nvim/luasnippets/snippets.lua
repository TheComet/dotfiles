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

local function dynamic_printf(values)
  local fmt_string = values[1][1]
  local nodes = {}
  for _ in fmt_string:gmatch("%%[^%%]") do
    local idx = #nodes / 2 + 1
    table.insert(nodes, t(", "))
    table.insert(nodes, r(idx, "arg" .. idx, i(nil, "arg" .. idx)))
  end
  return sn(1, nodes)
end

c_and_cpp_snippets = {
  s({ trig = "split", docstring = "/* --- */" }, {
    t("/* -------------------------------------------------------------------------- */")
  }),
  s({ trig = "cpp", docstring = "C++ extern #define" },
    fmt("#if defined(__cplusplus)\n{}\n#endif\n", {
      c(1, { i(1, "extern \"C\" {"), i(2, "}"), })
    })
  ),

  s({ trig = "fprintf", docstring = "fprintf" },
    fmt('fprintf({}, "{}\\n"{});', {
      c(1, { i(1, "stderr"), i(2, "fp"), }),
      i(2, ""),
      d(3, dynamic_printf, { 2 }),
    }, { stored = {} })
  ),
  s({ trig = "printf", docstring = "printf" },
    fmt('printf("{}\\n"{});', {
      i(1, ""),
      d(2, dynamic_printf, { 1 }),
    }, { stored = {} })
  ),

  s({ trig = "for", docstring = "index based for-loop" },
    fmt("for({} {} = 0; {} != {}; ++{})", {
      i(1, "int"),
      i(2, "i"),
      rep(2),
      i(3, "count"),
      rep(2),
    })
  ),
}

local function join_tables(...)
  local result = {}
  for _, t in ipairs({...}) do
    for _, v in ipairs(t) do
      table.insert(result, v)
    end
  end
  return result
end

ls.add_snippets("c", join_tables(
  c_snippets,
  c_and_cpp_snippets
), { key = "thecomet-c" })
ls.add_snippets("cpp", join_tables(
  cpp_snippets,
  c_and_cpp_snippets
), { key = "thecomet-cpp" })

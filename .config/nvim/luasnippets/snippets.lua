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

  s({ trig = "forr", docstring = "for-loop (range-based)" },
    fmt("for ({} {} : {})", {
      c(1, { i(1, "auto"), i(2, "auto&"), i(3, "const auto&") }),
      i(2, "var"),
      i(3, "container"),
    })
  ),
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
  s({ trig = "sep", docstring = "/* --- */" }, {
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
  s({ trig = "rtt", docstring = "SEGGER_RTT_printf" },
    fmt('SEGGER_RTT_printf({}, "{}\\n"{});', {
      i(1, "0"),
      i(2, ""),
      d(3, dynamic_printf, { 2 }),
    }, { stored = {} })
  ),

  s({ trig = "for", docstring = "index based for-loop" }, {
    t("for ("), c(1, {
      sn(1, { i(1, "i"), t(" = "), i(2, "0"), t("; "), rep(1), t(" != "), i(3, "count"), t("; ++"), rep(1), t(")"), }),
      sn(1, { i(1, "i"), t(" = "), i(2, "count"), t(" - 1; "), rep(1), t(" >= "), i(3, "0"), t("; --"), rep(1), t(")"), }),
    }),
  }),

  s({ trig = "sc", docstring = "static_cast" },
    fmt("static_cast<{}>({})", {
      i(1, "type"),
      i(2, "value"),
    })
  ),
}

gmock_snippets = {
  s({ trig = "geq", docstring = "ASSERT_EQ" },
    fmt("ASSERT_EQ({}, {})", { i(1, "actual"), i(2, "expected"), })),

  s({ trig = "gass", docstring = "ASSERT_THAT" },
    fmt("{}({}, {})", {
      c(1, { i(1, "ASSERT_THAT"), i(2, "EXPECT_THAT") }),
      i(2, "actual"),
      i(3, "matcher"),
    })
  ),

  s({ trig = "gcall", docstring = "EXPECT_CALL" }, {
    c(1, {
      fmt("EXPECT_CALL({}, {})", {
        i(1, "mock"),
        i(2, "method"),
      }),
      fmt("EXPECT_CALL(JOMOCK({}), JOMOCK_FUNC({}))", {
        i(1, "func"),
        i(2, "args"),
      }),
      fmt("EXPECT_CALL({}, JOMOCK_FUNC({}))", {
        i(1, "func"),
        i(2, "args"),
      }),
    }),
  }),

  s({ trig = "jomock", docstring = "JOMOCK member variable" },
    fmt("decltype(JOMOCK({})) {} = JOMOCK({});", {
      i(1, "func"),
      i(2, "member"),
      f(function(values) return values[1][1] end, {1}),
    })
  ),
}

local join_tables = function(...)
  local result = {}
  for _, tbl in ipairs({...}) do
    for _, t in ipairs(tbl) do
      table.insert(result, t)
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
  c_and_cpp_snippets,
  gmock_snippets
), { key = "thecomet-cpp" })

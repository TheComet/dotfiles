local function justify_words(words, width, is_last_line)
  local spaces = #words - 1
  if spaces <= 0 then
    return words
  end

  local actual_length = 0
  for _, word in ipairs(words) do
    actual_length = actual_length + #word
  end
  actual_length = actual_length + spaces

  if is_last_line and (actual_length / width < 0.8) then
    return words
  end

  local extra_spaces = width - actual_length
  local index = 1

  while extra_spaces > 0 do
    words[index] = words[index] .. " "
    index = index + 1
    if index > spaces then
      index = 1
    end
    extra_spaces = extra_spaces - 1
  end

  return words
end

local function format_paragraph(paragraph, width)
  local first_indent = paragraph[1]:match("^(%s*)") or ""
  local continuation_indent = first_indent

  if #paragraph > 1 then
    continuation_indent = paragraph[2]:match("^(%s*)") or first_indent
  end

  local words = {}
  for _, line in ipairs(paragraph) do
    for word in line:gmatch("%S+") do
      table.insert(words, word)
    end
  end

  local lines = {}
  local current = {}
  local count = 0
  local line_width = width - #first_indent
  local current_indent = first_indent

  for _, word in ipairs(words) do
    local cost = #word + 1

    if count + cost > line_width + 1 then
      table.insert(lines, { indent = current_indent, words = current })

      current = { word }
      count = cost
      current_indent = continuation_indent
      line_width = width - #continuation_indent
    else
      table.insert(current, word)
      count = count + cost
    end
  end

  if #current > 0 then
    table.insert(lines, { indent = current_indent, words = current })
  end

  for i, line in ipairs(lines) do
    justify_words(line.words, width - #line.indent, i == #lines)
  end

  local output = {}
  for _, line in ipairs(lines) do
    table.insert(output, line.indent .. table.concat(line.words, " "))
  end

  return output
end

function format_range(start_line, end_line, width)
  width = width or 80
  if start_line > end_line then
    start_line, end_line = end_line, start_line
  end

  local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)
  local result = {}
  local paragraph = {}
  local current_indent = nil

  local function flush_paragraph()
    if #paragraph > 0 then
      local formatted = format_paragraph(paragraph, width)
      vim.list_extend(result, formatted)
      paragraph = {}
      current_indent = nil
    end
  end

  for _, line in ipairs(lines) do
    if line:match("^%s*$") then
      flush_paragraph()
      table.insert(result, "")
    else
      local indent = line:match("^(%s*)")

      if current_indent == nil then
        current_indent = indent
      elseif indent ~= current_indent then
        flush_paragraph()
        current_indent = indent
      end

      table.insert(paragraph, line)
    end
  end

  flush_paragraph()

  vim.api.nvim_buf_set_lines(0, start_line - 1, end_line, false, result)
end

local function format_buffer(width)
  format_range(1, vim.fn.line("$"), width)
end

local function format_selection(width)
  local start_line = vim.fn.line("v")
  local end_line = vim.fn.line(".")
  format_range(start_line, end_line, width)
end

vim.api.nvim_create_user_command(
  "JustifyText",
  function(opts)
    local width = tonumber(opts.args) or 80
    if opts.range > 0 then
      format_range(opts.line1, opts.line2, width)
    else
      format_buffer(width)
    end
  end,
  { nargs = "?", range = true }
)

local function get_filetype()
    -- return vim.bo.filetype
    local bufnr = vim.api.nvim_get_current_buf()
    local filetype = vim.api.nvim_buf_get_option(bufnr, 'filetype')
    return filetype
end

local function get_line_until_cursor()

  -- Obtener el buffer actual
  local current_buffer = vim.api.nvim_get_current_buf()

  -- Obtener la posición del cursor (fila y columna)
  local cursor_pos = vim.api.nvim_win_get_cursor(0)
  local row = cursor_pos[1]
  local col = cursor_pos[2]

  -- Obtener la línea actual completa
  local line = vim.api.nvim_buf_get_lines(current_buffer, row - 1, row, false)[1]

  -- Extraer la parte de la línea hasta la posición del cursor
  local line_until_cursor = string.sub(line, 1, col)

  return line_until_cursor
end

local function format_string(str)
  -- Eliminar todos los espacios en blanco y saltos de línea
  local formatted_str = str:gsub("%s+", "")
  return formatted_str
end

local function check_health()
  return "todo ok"
end

local function notify(variable)
  vim.notify(vim.inspect(variable), vim.log.levels.INFO)
end

return {
  get_line_until_cursor = get_line_until_cursor,
  format_string = format_string,
  get_filetype = get_filetype,
  health = check_health,
  notify = notify
}

local M = {}

M.show_split = function(content)
	-- Implementa la lógica para mostrar un split con el contenido
end

-- Función para crear y mostrar la ventana emergente con texto enriquecido
M.show_popup = function(content)
	local buf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.split(content, "\n"))

	local width = 80
	local height = 20
	local row = math.ceil((vim.api.nvim_get_option("lines") - height) / 2)
	local col = math.ceil((vim.api.nvim_get_option("columns") - width) / 2)

	local win = vim.api.nvim_open_win(buf, true, {
		relative = "editor",
		width = width,
		height = height,
		row = row,
		col = col,
		border = "rounded",
		style = "minimal",
	})

	vim.api.nvim_buf_set_option(buf, "bufhidden", "wipe")

	-- Aplicar el formato Markdown en el contenido
	vim.cmd("syntax sync fromstart")
	vim.cmd("setlocal filetype=markdown")

	-- Cerrar la ventana con la letra 'q'
	vim.api.nvim_buf_set_keymap(buf, "n", "q", ":q<CR>", { noremap = true, silent = true })
end

return M

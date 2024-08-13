local M = {}
local utils = require("regex_ai.utils")
local config = require("regex_ai.config")
local llm = require("regex_ai.llm")

local function explain_regex_prompt(filetype, regex)
	return string.format(
		[[
Explain the following regular expression for the %s programming language:
%s

Please provide a detailed explanation of what this regex does and how it works.
    ]],
		filetype,
		regex
	)
end

-- Función para crear y mostrar una ventana con la explicación
local function show_explanation_window(content)
	local buf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.split(content, "\n"))

	local win_opts = {
		relative = "editor",
		width = 80,
		height = 20,
		row = math.floor((vim.o.lines - 20) / 2),
		col = math.floor((vim.o.columns - 80) / 2),
		style = "minimal",
		border = "rounded",
	}

	local win = vim.api.nvim_open_win(buf, true, win_opts)
	vim.api.nvim_win_set_option(win, "wrap", true) -- Habilitar el ajuste de línea
end

M.explain_regex = function()
	local filetype = utils.get_filetype()
	vim.notify("filetype: " .. filetype)

	local line = vim.fn.getline(".")
	vim.notify("line: " .. line)

	local regex = line:match("^%s*(.-)%s*$") -- Elimina espacios en blanco al inicio y final
	vim.notify("regex: " .. (regex or "none"))

	if not regex or regex == "" then
		vim.notify("No se encontró una expresión regular en la línea actual.", vim.log.levels.WARN)
		return
	end

	local prompt = explain_regex_prompt(filetype, regex)

	llm.query(prompt, function(response)
		if response then
			-- Mostrar la explicación en un popup o ventana según la configuración
			if config.options.ui.popup then
				-- Usar una ventana de Neovim para mostrar el contenido
				show_explanation_window(response)
			else
				-- Mostrar en un split si la opción `popup` no está habilitada
				ui.show_split(response)
			end
		else
			vim.notify("No se pudo obtener la explicación del regex", vim.log.levels.ERROR)
		end
	end)
end

return M

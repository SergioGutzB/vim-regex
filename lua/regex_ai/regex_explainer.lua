local M = {}
local utils = require("regex_ai.utils")
local ui = require("regex_ai.ui")
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
			ui.show_popup(response)
		else
			vim.notify("No se pudo obtener la explicación del regex", vim.log.levels.ERROR)
		end
	end)
end

return M

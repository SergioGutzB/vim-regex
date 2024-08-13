local M = {}
local utils = require("regex_ai.utils")
local llm = require("regex_ai.llm")
local ui = require("regex_ai.ui")
local vim = vim

local function generate_regex_prompt(filetype, description)
	return string.format(
		[[
Provide a JSON array of objects. Each object must contain two properties:
* "regex": The regular expression for the %s programming language.
* "description": A brief explanation of the regex.

PRIORITY: YOU SHOULD TRY NO TO generate regular expressions that must match from the beginning to the end of the string. for example avoid generating regular expressions with `^` and `$`.

IMPORTANT: try to generate as many regular expressions as possible that perfectly validate the requirement.

Do not include any code, explanations, or other text. Output only the JSON array.

If it only finds one object, it must also return it in an array.

Based on the following description:
%s

Example:
```json
[
  {"regex": "<regex1>", "description": "Explanation 1"},
  {"regex": "<regex2>", "description": "Explanation 2"}
]
]],
		filetype,
		description
	)
end

local spinner_symbols = { "|", "/", "-", "\\" }
local spinner_index = 1
local spinner_timer

local function start_spinner()
	spinner_timer = vim.defer_fn(function()
		if M.loading then
			vim.api.nvim_echo({ { spinner_symbols[spinner_index] .. " Loading...", "None" } }, false, {})
			spinner_index = (spinner_index % #spinner_symbols) + 1
			start_spinner()
		else
			vim.api.nvim_echo({ { "" } }, false, {}) -- Clear the spinner
		end
	end, 100)
end

local function stop_spinner()
	M.loading = false
	if spinner_timer then
		vim.defer_fn(function()
			vim.api.nvim_echo({ { "" } }, false, {}) -- Clear the spinner
		end, 0)
	end
end

M.generate_regex = function()
	-- Start loading spinner
	M.loading = true
	start_spinner()

	local h = utils.health()
	-- vim.notify("health: ")
	-- utils.notify(h)

	local filetype = utils.get_filetype()
	-- print("filetype: ", filetype)
	local current_line = vim.fn.getline(".")
	-- print("line:  ", current_line)
	local description = current_line
	-- print("description: ", description)

	if not description then
		vim.notify(
			"No se encontró una descripción en la línea actual. Asegúrate de que esté en un comentario.",
			vim.log.levels.WARN
		)
		return
	end

	local prompt = generate_regex_prompt(filetype, description)

	llm.query(prompt, function(response)
		stop_spinner()

		if response then
			-- print("response: ", response)
			local json_content = response:match("^%s*%[.-%]%s*$")

			if not json_content then
				json_content = response:match("```json%s*(.-)%s*```")
			end

			-- print("json_content: ", json_content)

			if not json_content then
				vim.notify("No se encontró un bloque JSON en la respuesta.", vim.log.levels.ERROR)
				return
			end

			-- Intentar decodificar el JSON
			local ok, options = pcall(vim.fn.json_decode, json_content)
			if not ok or type(options) ~= "table" then
				vim.notify("No se pudo parsear la respuesta JSON", vim.log.levels.ERROR)
				return
			end

			-- -- Crear una lista de opciones para que el usuario seleccione
			-- local regex_list = {}
			-- for i, option in ipairs(options) do
			-- 	local description = option.description:gsub(".{60}", "%0\n") -- Ajustar texto en líneas de 60 caracteres
			-- 	table.insert(regex_list, string.format("%d: %s - %s", i, option.regex, description))
			-- end

			-- -- Crear una lista de opciones para que el usuario seleccione
			-- local regex_list = {}
			-- for i, option in ipairs(options) do
			-- 	-- Ajustar el texto de la descripción a múltiples líneas
			-- 	local wrapped_description = option.description:gsub("(%S[%s]*)", function(w)
			-- 		if #w > 60 then
			-- 			return w:sub(1, 60) .. "\n" .. w:sub(61)
			-- 		else
			-- 			return w
			-- 		end
			-- 	end)
			-- 	table.insert(regex_list, string.format("%d: %s\n%s", i, option.regex, wrapped_description))
			-- end
			--
			-- Crear una lista de opciones para que el usuario seleccione
			local regex_list = {}
			for i, option in ipairs(options) do
				-- Dividir la descripción en múltiples líneas si es muy larga
				local wrapped_description = {}
				local width = 60 -- Máximo de caracteres por línea

				for line in option.description:gmatch("[^\r\n]+") do
					while #line > width do
						local wrapped_line = line:sub(1, width)
						table.insert(wrapped_description, wrapped_line)
						line = line:sub(width + 1)
					end
					table.insert(wrapped_description, line)
				end

				-- Concatenar la descripción envuelta en líneas
				local full_description = table.concat(wrapped_description, "\n")

				-- Crear el ítem con regex y descripción envuelta
				table.insert(regex_list, string.format("%d: %s\n%s", i, option.regex, full_description))
			end

			-- Mostrar la lista para que el usuario seleccione una opción
			vim.ui.select(regex_list, {
				prompt = "Select a regex:",
				format_item = function(item)
					return item
				end,
			}, function(choice, idx)
				-- Cerrar la ventana de selección si es válida
				if M.select_win and vim.api.nvim_win_is_valid(M.select_win) then
					vim.api.nvim_win_close(M.select_win, true)
				end

				if choice and idx then
					local regex = options[idx].regex
					local current_line_number = vim.fn.line(".")
					vim.api.nvim_buf_set_lines(0, current_line_number, current_line_number, false, { regex })

					-- Mostrar la explicación en un popup
					local explanation = options[idx].description
					ui.show_popup(explanation)
				end
			end)
		else
			vim.notify("No se pudo generar el regex", vim.log.levels.ERROR)
		end
	end)
end

return M

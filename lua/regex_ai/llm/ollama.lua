local curl = require("plenary.curl")
local M = {}

-- Función de logging
local function log_request(prompt, response)
	local log_file = vim.fn.stdpath("data") .. "~/regex_ai_ollama.log"
	local timestamp = os.date("%Y-%m-%d %H:%M:%S")
	local log_entry = string.format("[%s] Request:\n%s\n\nResponse:\n%s\n\n", timestamp, prompt, response)
	local file = io.open(log_file, "a")
	if file then
		file:write(log_entry)
		file:close()
	else
		vim.notify("No se pudo abrir el archivo de log", vim.log.levels.ERROR)
	end
end

local function build_prompt(context, query)
	return string.format(
		[[
Context: %s
Query: %s
Response:
]],
		context or "",
		query
	)
end

function M.setup(config)
	M.ollama_config = config.ollama
	M.model = config.model
	if not M.ollama_config or not M.model then
		error("Ollama configuration or model not found")
	end
end

function M.query(prompt, context)
	local full_prompt = build_prompt(context, prompt)
	local success, response = pcall(curl.post, M.ollama_config.url .. "/api/generate", {
		body = vim.json.encode({
			model = M.model,
			prompt = full_prompt,
			stream = false,
		}),
		headers = {
			content_type = "application/json",
		},
		timeout = M.ollama_config.timeout or 120000,
	})

	if not success then
		vim.notify("Error querying Ollama: " .. tostring(response), vim.log.levels.ERROR)
		log_request(full_prompt, "Error: " .. tostring(response))
		return nil
	end

	if response.status ~= 200 then
		vim.notify("Failed to query Ollama: " .. (response.body or "Unknown error"), vim.log.levels.ERROR)
		log_request(full_prompt, "Failed: " .. (response.body or "Unknown error"))
		return nil
	end

	local ok, result = pcall(vim.json.decode, response.body)
	if not ok then
		vim.notify("Failed to parse Ollama response", vim.log.levels.ERROR)
		log_request(full_prompt, "Parse error: " .. response.body)
		return nil
	end

	return result.response
end

function M.health_check()
	local success, response = pcall(curl.get, M.ollama_config.url .. "/api/version")
	if not success then
		return false, "Failed to connect to Ollama: " .. tostring(response)
	end
	if response.status ~= 200 then
		return false, "Failed to connect to Ollama"
	end
	return true, "Successfully connected to Ollama"
end

return M

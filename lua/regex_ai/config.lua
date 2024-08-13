local M = {}

local defaults = {
  llm = {
    provider = "ollama",
    model = "codeqwen",
    -- Configuraciones adicionales para Ollama
    ollama = {
      url = "http://localhost:11434",
      timeout = 120000,
    },
    -- Espacio para configuraciones de otros proveedores de LLM
  },
    shortcut = {
        generate = "<leader>rg",
        explain = "<leader>re",
    },
    ui = {
        popup = true,
        -- Otras opciones de UI
    }
}

M.options = {}

M.setup = function(opts)
    M.options = vim.tbl_deep_extend("force", {}, defaults, opts or {})
end

return M

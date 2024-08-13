local M = {}

-- Importar los módulos necesarios
local config = require('regex_ai.config')
local regex_generator = require('regex_ai.regex_generator')
local regex_explainer = require('regex_ai.regex_explainer')
local llm = require('regex_ai.llm')

-- Función de configuración
M.setup = function(opts)
    -- Configurar las opciones del plugin
    config.setup(opts)

    -- Configurar el proveedor LLM
    llm.setup()

    -- Definir los comandos de usuario
    vim.api.nvim_create_user_command('RegexAIGenerate', regex_generator.generate_regex, {})
    vim.api.nvim_create_user_command('RegexAIExplain', regex_explainer.explain_regex, {})

    -- Configurar los atajos de teclado
    vim.keymap.set('n', config.options.shortcut.generate, ':RegexAIGenerate<CR>', { noremap = true, silent = true })
    vim.keymap.set('n', config.options.shortcut.explain, ':RegexAIExplain<CR>', { noremap = true, silent = true })
end

-- Función para generar regex
M.generate_regex = regex_generator.generate_regex

-- Función para explicar regex
M.explain_regex = regex_explainer.explain_regex

return M

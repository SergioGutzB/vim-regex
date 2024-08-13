if vim.g.loaded_regex_ai then
    return
end
vim.g.loaded_regex_ai = true

local regex_generator = require('regex_ai.regex_generator')
local regex_explainer = require('regex_ai.regex_explainer')
local config = require('regex_ai.config')

vim.api.nvim_create_user_command('RegexAIGenerate', regex_generator.generate_regex, {})
vim.api.nvim_create_user_command('RegexAIExplain', regex_explainer.explain_regex, {})

-- Función para configurar los atajos de teclado
local function setup_keymaps()
    local opts = config.options
    if opts and opts.shortcut then
        if opts.shortcut.generate then
            vim.keymap.set('n', opts.shortcut.generate, ':RegexAIGenerate<CR>', { noremap = true, silent = true })
        end
        if opts.shortcut.explain then
            vim.keymap.set('n', opts.shortcut.explain, ':RegexAIExplain<CR>', { noremap = true, silent = true })
        end
    end
end

-- Intentar configurar los atajos de teclado, pero no fallar si la configuración no está lista
pcall(setup_keymaps)

-- Proporcionar un comando para configurar el plugin más tarde si es necesario
vim.api.nvim_create_user_command('RegexAISetup', function(args)
    require('regex_ai').setup(args.args)
    setup_keymaps()
end, { nargs = '?', desc = 'Setup RegexAI plugin' })

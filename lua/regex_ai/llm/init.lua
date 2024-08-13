local M = {}
local config = require('regex_ai.config')

function M.setup()
    local llm_config = config.options.llm
    if not llm_config or not llm_config.provider then
        error("LLM configuration not found or provider not specified")
    end

    local provider_module = 'regex_ai.llm.' .. llm_config.provider
    M.provider = require(provider_module)
    
    if M.provider.setup then
        M.provider.setup(llm_config)
    end
end

function M.query(prompt, callback)
    if not M.provider then
        error("LLM provider not initialized. Make sure to call setup() first.")
    end
    
    local response = M.provider.query(prompt)
    callback(response)
end

return M

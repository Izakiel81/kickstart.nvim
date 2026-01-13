-- Pure vim.lsp configuration using NEW Neovim 0.11+ API
-- Location: lua/core/lsp.lua

-------------------------------------------------------------------------------
-- 1. Path Helpers (Needed for the TS Plugin)
-------------------------------------------------------------------------------
-- This finds the Vue plugin that ts_ls needs to talk to Volar
local vue_plugin_path = vim.fn.stdpath 'data' .. '/mason/packages/vue-language-server/node_modules/@vue/language-server'

-------------------------------------------------------------------------------
-- 2. LSP Attach (Keymaps & Fix-on-Save)
-------------------------------------------------------------------------------
vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('lsp-attach', { clear = true }),
  callback = function(event)
    local client = vim.lsp.get_client_by_id(event.data.client_id)
    local map = function(keys, func, desc)
      vim.keymap.set('n', keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
    end

    -- Standard Keymaps
    map('gd', vim.lsp.buf.definition, '[G]oto [D]efinition')
    map('gr', vim.lsp.buf.references, '[G]oto [R]eferences')
    map('K', vim.lsp.buf.hover, 'Hover Documentation')
    map('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')
    map('<leader>f', function()
      vim.lsp.buf.format { async = true }
    end, '[F]ormat')

    -- ESLint: Auto-fix on save
    if client and client.name == 'eslint' then
      vim.api.nvim_create_autocmd('BufWritePre', {
        buffer = event.buf,
        command = 'EslintFixAll',
      })
    end
  end,
})

-------------------------------------------------------------------------------
-- 3. Server Configurations
-------------------------------------------------------------------------------
local capabilities = vim.lsp.protocol.make_client_capabilities()

-- TypeScript (Must be configured for the Vue bridge to work)
vim.lsp.config['ts_ls'] = {
  cmd = { 'typescript-language-server', '--stdio' },
  filetypes = { 'javascript', 'typescript', 'vue' }, -- Added 'vue'
  root_markers = { 'package.json', 'tsconfig.json', '.git' },
  capabilities = capabilities,
  init_options = {
    plugins = {
      {
        name = '@vue/typescript-plugin',
        location = vue_plugin_path,
        languages = { 'vue' },
      },
    },
  },
}

-- Vue (Using your official Hybrid Mode config)
vim.lsp.config['vue_ls'] = {
  cmd = { 'vue-language-server', '--stdio' },
  filetypes = { 'vue' },
  root_markers = { 'package.json', 'tsconfig.json' },
  capabilities = capabilities,
  init_options = {
    vue = {
      hybridMode = true, -- Mandatory for the tsserver bridge
    },
  },
  on_init = function(client)
    local retries = 0
    local function typescriptHandler(_, result, context)
      local ts_client = vim.lsp.get_clients({ bufnr = context.bufnr, name = 'ts_ls' })[1]
      if not ts_client then
        if retries <= 10 then
          retries = retries + 1
          vim.defer_fn(function()
            typescriptHandler(_, result, context)
          end, 100)
        end
        return
      end
      local param = unpack(result)
      local id, command, payload = unpack(param)
      ts_client:exec_cmd({
        title = 'vue_request_forward',
        command = 'typescript.tsserverRequest',
        arguments = { command, payload },
      }, { bufnr = context.bufnr }, function(_, r)
        client:notify('tsserver/response', { { id, r and r.body } })
      end)
    end
    client.handlers['tsserver/request'] = typescriptHandler
  end,
}

-- Basic Servers
local servers = { 'lua_ls', 'html', 'cssls', 'jsonls' }
for _, server in ipairs(servers) do
  vim.lsp.config[server] = { capabilities = capabilities }
  vim.lsp.enable(server)
end

-- Enable the complex ones
vim.lsp.enable 'ts_ls'
vim.lsp.enable 'vue_ls'

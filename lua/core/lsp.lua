-- Pure vim.lsp configuration using NEW Neovim 0.11+ API
-- Put this in lua/core/lsp.lua

-- LSP Attach - Setup keymaps and features when LSP attaches
vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('lsp-attach', { clear = true }),
  callback = function(event)
    local map = function(keys, func, desc)
      vim.keymap.set('n', keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
    end

    -- Navigation
    map('gd', vim.lsp.buf.definition, '[G]oto [D]efinition')
    map('gr', vim.lsp.buf.references, '[G]oto [R]eferences')
    map('gI', vim.lsp.buf.implementation, '[G]oto [I]mplementation')
    map('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
    map('<leader>D', vim.lsp.buf.type_definition, 'Type [D]efinition')
 


    map('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')
    
    -- Documentation
    map('K', vim.lsp.buf.hover, 'Hover Documentation')
    map('<C-k>', vim.lsp.buf.signature_help, 'Signature Help')
    
    -- Format
    map('<leader>f', function() vim.lsp.buf.format({ async = true }) end, '[F]ormat')

    -- Document highlighting
    local client = vim.lsp.get_client_by_id(event.data.client_id)
    if client and client.server_capabilities.documentHighlightProvider then
      local hl_group = vim.api.nvim_create_augroup('lsp-highlight', { clear = false })
      vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
        buffer = event.buf,
        group = hl_group,
        callback = vim.lsp.buf.document_highlight,
      })
      vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
        buffer = event.buf,
        group = hl_group,
        callback = vim.lsp.buf.clear_references,
      })
    end

    -- Inlay hints toggle (Neovim 0.10+)
    if client and client.server_capabilities.inlayHintProvider and vim.lsp.inlay_hint then
      map('<leader>th', function()
        vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf }), { bufnr = event.buf })
      end, '[T]oggle Inlay [H]ints')
    end
  end,
})

-- Diagnostic configuration
vim.diagnostic.config({
  virtual_text = {
    spacing = 4,
    prefix = '●',
  },
  signs = true,
  update_in_insert = false,
  underline = true,
  severity_sort = true,
  float = {
    border = 'rounded',
    source = 'always',
  },
})

-- Diagnostic signs
local signs = { Error = ' ', Warn = ' ', Hint = ' ', Info = ' ' }
for type, icon in pairs(signs) do
  local hl = 'DiagnosticSign' .. type
  vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end

-- Handlers with rounded borders
vim.lsp.handlers['textDocument/hover'] = vim.lsp.with(vim.lsp.handlers.hover, { border = 'rounded' })
vim.lsp.handlers['textDocument/signatureHelp'] = vim.lsp.with(vim.lsp.handlers.signature_help, { border = 'rounded' })

-- Capabilities for completion
local capabilities = vim.lsp.protocol.make_client_capabilities()

-- If using blink.cmp, extend capabilities:
local has_blink, blink = pcall(require, 'blink.cmp')
if has_blink then
  capabilities = vim.tbl_deep_extend('force', capabilities, blink.get_lsp_capabilities())
end

-- If using nvim-cmp, extend capabilities:
-- local has_cmp, cmp_lsp = pcall(require, 'cmp_nvim_lsp')
-- if has_cmp then
--   capabilities = vim.tbl_deep_extend('force', capabilities, cmp_lsp.default_capabilities())
-- end

-- Configure LSP servers using NEW vim.lsp.config API

-- Lua Language Server
vim.lsp.config['lua_ls'] = {
  cmd = { 'lua-language-server' },
  filetypes = { 'lua' },
  root_markers = { { '.luarc.json', '.luarc.jsonc', '.luacheckrc' }, '.git' },
  capabilities = capabilities,
  settings = {
    Lua = {
      runtime = {
        version = 'LuaJIT',
      },
      workspace = {
        checkThirdParty = false,
        library = { vim.env.VIMRUNTIME },
      },
      completion = {
        callSnippet = 'Replace',
      },
      diagnostics = {
        globals = { 'vim' },
      },
      telemetry = {
        enable = false,
      },
    },
  },
}

-- TypeScript/JavaScript
vim.lsp.config['ts_ls'] = {
  cmd = { 'typescript-language-server', '--stdio' },
  filetypes = { 'javascript', 'javascriptreact', 'typescript', 'typescriptreact' },
  root_markers = { 'package.json', 'tsconfig.json', 'jsconfig.json', '.git' },
  capabilities = capabilities,
}

-- Python
vim.lsp.config['pyright'] = {
  cmd = { 'pyright-langserver', '--stdio' },
  filetypes = { 'python' },
  root_markers = { 'pyproject.toml', 'setup.py', 'setup.cfg', 'requirements.txt', 'Pipfile', '.git' },
  capabilities = capabilities,
}

-- Vue (vue_ls)
vim.lsp.config['vue_ls'] = {
  cmd = { 'vue-language-server', '--stdio' },
  filetypes = { 'vue' },
  root_markers = { 'package.json', '.git' },
  capabilities = capabilities,
  init_options = {
    vue = {
      hybridMode = false,
    },
  },
}

-- HTML
vim.lsp.config['html'] = {
  cmd = { 'vscode-html-language-server', '--stdio' },
  filetypes = { 'html' },
  root_markers = { 'package.json', '.git' },
  capabilities = capabilities,
}

-- CSS
vim.lsp.config['cssls'] = {
  cmd = { 'vscode-css-language-server', '--stdio' },
  filetypes = { 'css', 'scss', 'less' },
  root_markers = { 'package.json', '.git' },
  capabilities = capabilities,
}

-- JSON
vim.lsp.config['jsonls'] = {
  cmd = { 'vscode-json-language-server', '--stdio' },
  filetypes = { 'json', 'jsonc' },
  root_markers = { 'package.json', '.git' },
  capabilities = capabilities,
}

-- ESLint
vim.lsp.config['eslint'] = {
  cmd = { 'vscode-eslint-language-server', '--stdio' },
  filetypes = { 'javascript', 'javascriptreact', 'typescript', 'typescriptreact', 'vue' },
  root_markers = { '.eslintrc', '.eslintrc.json', '.eslintrc.js', 'package.json', '.git' },
  capabilities = capabilities,
}

-- Docker
vim.lsp.config['dockerls'] = {
  cmd = { 'docker-langserver', '--stdio' },
  filetypes = { 'dockerfile' },
  root_markers = { 'Dockerfile', '.git' },
  capabilities = capabilities,
}

-- Docker Compose
vim.lsp.config['docker_compose_language_service'] = {
  cmd = { 'docker-compose-langserver', '--stdio' },
  filetypes = { 'yaml.docker-compose' },
  root_markers = { 'docker-compose.yml', 'docker-compose.yaml', '.git' },
  capabilities = capabilities,
}

-- YAML
vim.lsp.config['yamlls'] = {
  cmd = { 'yaml-language-server', '--stdio' },
  filetypes = { 'yaml', 'yaml.docker-compose' },
  root_markers = { '.git' },
  capabilities = capabilities,
  settings = {
    yaml = {
      schemas = {
        ['https://json.schemastore.org/github-workflow.json'] = '/.github/workflows/*',
        ['https://raw.githubusercontent.com/compose-spec/compose-spec/master/schema/compose-spec.json'] = 'docker-compose*.yml',
      },
    },
  },
}

-- Enable all configured servers
vim.lsp.enable('lua_ls')
vim.lsp.enable('ts_ls')
vim.lsp.enable('pyright')
vim.lsp.enable('vue_ls')
vim.lsp.enable('html')
vim.lsp.enable('cssls')
vim.lsp.enable('jsonls')
vim.lsp.enable('eslint')
vim.lsp.enable('dockerls')
vim.lsp.enable('docker_compose_language_service')
vim.lsp.enable('yamlls')


vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('my.lsp', {}),
  callback = function(args)
    local client = assert(vim.lsp.get_client_by_id(args.data.client_id))
    if client:supports_method('textDocument/implementation') then
      -- Create a keymap for vim.lsp.buf.implementation ...
    end
    -- Enable auto-completion. Note: Use CTRL-Y to select an item. |complete_CTRL-Y|
    if client:supports_method('textDocument/completion') then
      -- Optional: trigger autocompletion on EVERY keypress. May be slow!
      -- local chars = {}; for i = 32, 126 do table.insert(chars, string.char(i)) end
      -- client.server_capabilities.completionProvider.triggerCharacters = chars
      vim.lsp.completion.enable(true, client.id, args.buf, {autotrigger = true})
    end
    -- Auto-format ("lint") on save.
    -- Usually not needed if server supports "textDocument/willSaveWaitUntil".
    if not client:supports_method('textDocument/willSaveWaitUntil')
        and client:supports_method('textDocument/formatting') then
      vim.api.nvim_create_autocmd('BufWritePre', {
        group = vim.api.nvim_create_augroup('my.lsp', {clear=false}),
        buffer = args.buf,
        callback = function()
          vim.lsp.buf.format({ bufnr = args.buf, id = client.id, timeout_ms = 1000 })
        end,
      })
    end
  end,
})

return {
  'folke/noice.nvim',
  event = 'VeryLazy',
  dependencies = {
    'MunifTanjim/nui.nvim',
    'rcarriga/nvim-notify',
  },
  opts = {
    lsp = {
      override = {
        ['vim.lsp.util.convert_input_to_markdown_lines'] = true,
        ['vim.lsp.util.stylize_markdown'] = true,
        ['cmp.entry.get_documentation'] = true,
      },
    },
    presets = {
      bottom_search = true,
      command_palette = true,
      long_message_to_split = true,
      inc_rename = false,
      lsp_doc_border = false,
    },
  },
  keys = {
    { '<leader>sn', '<cmd>Noice<cr>', desc = '[S]earch [N]oice messages' },
    { '<leader>snl', '<cmd>NoiceLast<cr>', desc = '[S]earch [N]oice [L]ast message' },
    { '<leader>snh', '<cmd>NoiceHistory<cr>', desc = '[S]earch [N]oice [H]istory' },
  },
}

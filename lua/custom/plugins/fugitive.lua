return {
  'tpope/vim-fugitive',
  config = function()
    vim.keymap.set('n', '<leader>gs', vim.cmd.Git, { desc = '[G]it [S]tatus' })
    vim.keymap.set('n', '<leader>gp', '<cmd>Git push<cr>', { desc = '[G]it [P]ush' })
    vim.keymap.set('n', '<leader>gl', '<cmd>Git pull<cr>', { desc = '[G]it Pul[l]' })
    vim.keymap.set('n', '<leader>gb', '<cmd>Git blame<cr>', { desc = '[G]it [B]lame' })
    vim.keymap.set('n', '<leader>gd', '<cmd>Gdiffsplit<cr>', { desc = '[G]it [D]iff' })
  end,
}

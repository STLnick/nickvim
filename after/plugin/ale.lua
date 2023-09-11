vim.g.ale_fixers = {
    css = {'prettier', 'trim_whitespace'},
    javascript = {'prettier', 'trim_whitespace'},
    svelte = {'prettier', 'trim_whitespace'},
    vue = {'prettier', 'trim_whitespace'}
}
vim.g.ale_fix_on_save = 1
vim.g.ale_linters_explicit = 1

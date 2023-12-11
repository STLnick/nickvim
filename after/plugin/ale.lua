vim.g.ale_fixers = {
    css = {'prettier', 'trim_whitespace'},
    javascript = {'prettier', 'eslint', 'trim_whitespace'},
    svelte = {'prettier', 'eslint', 'trim_whitespace'},
    vue = {'prettier', 'eslint', 'trim_whitespace'}
}
vim.g.ale_linters = {
    javascript = {'eslint'},
}
vim.g.ale_fix_on_save = 0
vim.g.ale_linters_explicit = 1

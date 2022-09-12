vim.g.mapleader = ','

-- Настройка оступов
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4
vim.opt.tabstop = 4
vim.cmd 'set expandtab'
vim.cmd 'set background=dark'


vim.cmd 'set number'
vim.opt.colorcolumn = '80'


vim.cmd([[colorscheme codedark]])

-----------------------------------------------------------
-- Настрока внешнего вида LuaLine
-----------------------------------------------------------
local function filetype()
    return string.format(" %s ", vim.bo.filetype):upper()
end

require('lualine').setup{
    options = {
        icons_enabled = true,
        theme = 'auto',
        component_separators = { left = '|', right = '|'},
        section_separators = { left = '', right = ''},
    },
    sections = {
        lualine_a = {'mode'},
        lualine_b = {'branch', 'diff', 'diagnostics'},
        lualine_c = {'filename'},
        lualine_x = { filetype },
        lualine_y = {'%3p%%'},
        lualine_z = {'location'}
    },
}


-----------------------------------------------------------
-- Файловый менеджер
-----------------------------------------------------------

require("nvim-tree").setup()


-----------------------------------------------------------
-- Интеграция Git
-----------------------------------------------------------

require('gitsigns').setup{
    signs = {
        add          = {hl = 'GitSignsAdd'   , text = '+', numhl='GitSignsAddNr'   , linehl='GitSignsAddLn'},
        change       = {hl = 'GitSignsChange', text = '+', numhl='GitSignsChangeNr', linehl='GitSignsChangeLn'},
        delete       = {hl = 'GitSignsDelete', text = '-', numhl='GitSignsDeleteNr', linehl='GitSignsDeleteLn'},
        topdelete    = {hl = 'GitSignsDelete', text = '-', numhl='GitSignsDeleteNr', linehl='GitSignsDeleteLn'},
        changedelete = {hl = 'GitSignsChange', text = '~', numhl='GitSignsChangeNr', linehl='GitSignsChangeLn'},
    },
    on_attach = function(bufnr)
        local gs = package.loaded.gitsigns

        local function map(mode, l, r, opts)
            opts = opts or {}
            opts.buffer = bufnr
            vim.keymap.set(mode, l, r, opts)
        end

        -- Navigation
        map('n', ']c', function()
            if vim.wo.diff then return ']c' end
            vim.schedule(function() gs.next_hunk() end)
            return '<Ignore>'
        end, {expr=true})

        map('n', '[c', function()
            if vim.wo.diff then return '[c' end
            vim.schedule(function() gs.prev_hunk() end)
            return '<Ignore>'
        end, {expr=true})

        -- Actions
        map('n', '<leader>gb', function() gs.blame_line{full=true} end)
    end
}

-----------------------------------------------------------
-- Настройка подсветки синтаксиса
-----------------------------------------------------------

require('nvim-treesitter.configs').setup{
    ensure_installed = { "c", "lua", "rust", "python", "yaml", "json", "go", "gomod", "http", "make", "markdown", "proto", "sql" },
    highlight = {
        -- `false` will disable the whole extension
        enable = true,
    },
}

-----------------------------------------------------------
-- Добавление json-тегов для структур
-- Требуется выполнить 'go install github.com/fatih/gomodifytags@latest'
-----------------------------------------------------------
vim.api.nvim_create_user_command(
    'GoAddTags',
    function(opts)
        buf = vim.api.nvim_get_current_buf()
        lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
        path = vim.fn.expand('%p')
        
        local content = ''
        for _, v in pairs(lines) do -- for every key in the table with a corresponding non-nil value 
            content = content .. v .. '\n'
        end
        local length = content:len()

        local cmd = 'gomodifytags -add-tags json'
        if (opts.args == '') then 
            cmd = cmd .. ' -line ' .. opts.line1
            if (opts.line1 ~= opts.line2) then
                cmd = cmd .. ',' .. opts.line2
            end
        else
            cmd = cmd .. ' -struct ' .. opts.args
        end
        
        local cmd = cmd .. ' -file ' .. path .. ' -modified -format json' .. ' <<EOF\n' .. path .. '\n' .. tostring(length) .. '\n' .. content .. 'EOF\n'
        local result = vim.fn.systemlist(cmd)

        local rawValue = ''
        for _, v in pairs(result) do
            rawValue = rawValue .. v .. '\n'
        end

        function fill()
            local jsonResult = vim.json.decode(rawValue)

            if (jsonResult['errors'] ~= nil) then
                print(jsonResult['errors'])
                return
            end

            vim.api.nvim_buf_set_lines(buf, jsonResult['start']-1, jsonResult['end'], true, jsonResult['lines'])
        end
        if pcall(fill) then
        else
            print(rawValue)
        end
    end,
    {desc = 'Add tags to struct', nargs = '?', range = true}
)

vim.api.nvim_create_user_command(
    'GoRemoveTags',
    function(opts)
        buf = vim.api.nvim_get_current_buf()
        lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
        path = vim.fn.expand('%p')
        
        local content = ''
        for _, v in pairs(lines) do -- for every key in the table with a corresponding non-nil value 
            content = content .. v .. '\n'
        end
        local length = content:len()
        content = content:gsub('`', '\\`') 

        local cmd = 'gomodifytags -remove-tags json'
        if (opts.args == '') then 
            cmd = cmd .. ' -line ' .. opts.line1
            if (opts.line1 ~= opts.line2) then
                cmd = cmd .. ',' .. opts.line2
            end
        else
            cmd = cmd .. ' -struct ' .. opts.args
        end
        
        local cmd = cmd .. ' -file ' .. path .. ' -modified -format json' .. ' <<EOF\n' .. path .. '\n' .. tostring(length) .. '\n' .. content .. 'EOF\n'
        local result = vim.fn.systemlist(cmd)

        local rawValue = ''
        for _, v in pairs(result) do
            rawValue = rawValue .. v .. '\n'
        end

        function fill()
            local jsonResult = vim.json.decode(rawValue)

            if (jsonResult['errors'] ~= nil) then
                print(jsonResult['errors'])
                return
            end

            vim.api.nvim_buf_set_lines(buf, jsonResult['start']-1, jsonResult['end'], true, jsonResult['lines'])
        end
        if pcall(fill) then
        else
            print(rawValue)
        end
    end,
    {desc = 'Add tags to struct', nargs = '?', range = true}
)

vim.api.nvim_create_user_command(
    "GoImports",
    function(opts)
        buf = vim.api.nvim_get_current_buf()
        lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
        path = vim.fn.expand('%p')

        local content = ''
        for _, v in pairs(lines) do -- for every key in the table with a corresponding non-nil value 
            content = content .. v .. '\n'
        end

        cmd = 'goimports <<EOF\n' .. content .. 'EOF\n'
        result = vim.fn.systemlist(cmd)
        vim.api.nvim_buf_set_lines(buf, 0, -1, true, result)
    end,
    {desc = 'Sort imports'}
)

vim.api.nvim_create_user_command(
    "GoInstallBinaries",
    function(opts)
        local cmds = {
            'go install golang.org/x/tools/cmd/goimports@latest',
            'go install github.com/fatih/gomodifytags@latest',
            'go install golang.org/x/tools/gopls@latest',
        }
        local cmd = ''

        for _, cmd in pairs(cmds) do
            vim.fn.systemlist(cmd)
        end
    end,
    {desc = 'Install binaries'}
)


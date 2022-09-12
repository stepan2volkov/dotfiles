-- Автоматическая установка "packer.nvim" на любой ПК, куда склонирована данная
-- конфигурация nvim
local fn = vim.fn
local install_path = fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
if fn.empty(fn.glob(install_path)) > 0 then
  packer_bootstrap = fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
  vim.cmd [[packadd packer.nvim]]
end


-- TODO: Debug-возможности
return require('packer').startup(function(use)
	-- Packer может обновлять себя сам
	use 'wbthomason/packer.nvim'

	-- набор Lua функций, используется как зависимость в большинстве
	-- плагинов, где есть работа с асинхронщиной
	use 'nvim-lua/plenary.nvim'

	-- Тема как в VS Code
	use 'tomasiser/vim-code-dark'

	-- Статyc-бар
	use {
   		'nvim-lualine/lualine.nvim',
        	requires = { 'kyazdani42/nvim-web-devicons', opt = true }
    	}

    -- Файловый менеджер
    use {
      'kyazdani42/nvim-tree.lua',
      requires = {
        'kyazdani42/nvim-web-devicons', -- optional, for file icons
      },
      tag = 'nightly' -- optional, updated every week. (see issue #1193)
    }

    -- Поддержка Git
    use 'lewis6991/gitsigns.nvim'

    -- Поиск по файлам и текста в файлах
    use {
        'nvim-telescope/telescope.nvim', tag = '0.1.0',
        requires = { {'nvim-lua/plenary.nvim'} }
    }

    -- Автодополнение для LSP
    use 'hrsh7th/cmp-nvim-lsp'
    use 'hrsh7th/cmp-buffer'
    use 'hrsh7th/cmp-path'
    use 'hrsh7th/cmp-cmdline'
    use 'hrsh7th/nvim-cmp'

    -- Сниппеты
    use 'L3MON4D3/LuaSnip'
    use 'saadparwaiz1/cmp_luasnip'
    use 'rafamadriz/friendly-snippets'

    -- Language Server Protocol
    use 'neovim/nvim-lspconfig'

    -- Подсветка синтаксиса
    use 'nvim-treesitter/nvim-treesitter'

  	-- Автоматическая установка всех плагинов после скачивания packer.nvim
  	-- Это условие должно быть после всех плагинов
  	if packer_bootstrap then
    		require('packer').sync()
  	end
end)


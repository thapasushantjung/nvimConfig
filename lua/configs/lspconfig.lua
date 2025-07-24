require("nvchad.configs.lspconfig").defaults()

local servers = { "html", "cssls" }
vim.lsp.enable(servers)

require("lspconfig").phpactor.setup {
  root_dir = function(_)
    return vim.loop.cwd()
  end,
  init_options = {
    ["language_server.diagnostics_on_update"] = false,
    ["language_server.diagnostics_on_open"] = false,
    ["language_server.diagnostics_on_save"] = false,
    ["language_server_phpstan.enabled"] = false,
    ["language_server_psalm.enabled"] = false,
  },
}

require("lspconfig").ts_ls.setup {
  root_dir = function(_)
    return vim.loop.cwd()
  end,
  init_options = {
    preferences = {
      importModuleSpecifierPreference = "non-relative",
      quotePreference = "single",
    },
  },
}
require("lspconfig").tailwindcss.setup {
  root_dir = function(_)
    return vim.loop.cwd()
  end,
  init_options = {
    userLanguages = {
      svelte = "html",
      typescriptreact = "javascript",
      javascriptreact = "javascript",
    },
  },
}

-- read :h vim.lsp.config for changing options of lsp servers

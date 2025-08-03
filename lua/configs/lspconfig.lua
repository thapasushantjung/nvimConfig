require("nvchad.configs.lspconfig").defaults()

local servers = { "html", "cssls" }
vim.lsp.enable(servers)

-- Ensure mason-lspconfig installs important servers
local mason_lspconfig = require("mason-lspconfig")
mason_lspconfig.setup({
  ensure_installed = {
    "html",
    "cssls", 
    "ts_ls",
    "jdtls",
    "gradle_ls",
    "tailwindcss",
    "phpactor",
  },
  automatic_installation = true,
})

-- Note: Java LSP (jdtls) is handled separately via nvim-jdtls plugin
-- See ftplugin/java.lua for Java configuration

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
require("lspconfig").gradle_ls.setup {
  cmd = {
    vim.fn.stdpath "data" .. "/mason/packages/gradle-language-server/gradle-language-server",
  },
  filetypes = { "groovy", "kotlin" },
  root_dir = require("lspconfig.util").root_pattern("settings.gradle", "settings.gradle.kts", "build.gradle", "build.gradle.kts", ".git"),
  settings = {
    gradleWrapperEnabled = true,
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

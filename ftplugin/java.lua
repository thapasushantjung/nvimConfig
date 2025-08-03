-- This file sets up JDTLS for Java files specifically
-- It's loaded when a Java file is opened

local jdtls = require "jdtls"
local home = os.getenv "HOME"

-- Determine Mason installation path
local mason_path = vim.fn.stdpath "data" .. "/mason"
local jdtls_path = mason_path .. "/packages/jdtls"

-- Check if JDTLS is installed
if vim.fn.isdirectory(jdtls_path) == 0 then
  vim.notify("JDTLS is not installed. Please install it via Mason: :MasonInstall jdtls", vim.log.levels.ERROR)
  return
end

-- Setup JDTLS configuration
local workspace_folder = home .. "/.local/share/eclipse/" .. vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t")

local config = {
  cmd = {
    "java",
    "-Declipse.application=org.eclipse.jdt.ls.core.id1",
    "-Dosgi.bundles.defaultStartLevel=4",
    "-Declipse.product=org.eclipse.jdt.ls.core.product",
    "-Dlog.protocol=true",
    "-Dlog.level=ALL",
    "-Xms1g",
    "-Xmx2G",
    "--add-modules=ALL-SYSTEM",
    "--add-opens", "java.base/java.util=ALL-UNNAMED",
    "--add-opens", "java.base/java.lang=ALL-UNNAMED",
    "-jar", vim.fn.glob(jdtls_path .. "/plugins/org.eclipse.equinox.launcher_*.jar"),
    "-configuration", jdtls_path .. "/config_linux",
    "-data", workspace_folder,
  },
  
  root_dir = require("jdtls.setup").find_root { ".git", "mvnw", "gradlew", "pom.xml", "build.gradle", "build.gradle.kts" },
  
  settings = {
    java = {
      eclipse = {
        downloadSources = true,
      },
      configuration = {
        updateBuildConfiguration = "interactive",
        runtimes = {
          -- Automatically detect system Java
          {
            name = "JavaSE-21",
            path = "/usr/lib/jvm/java-21-openjdk-amd64/",
          },
        }
      },
      maven = {
        downloadSources = true,
      },
      implementationsCodeLens = {
        enabled = true,
      },
      referencesCodeLens = {
        enabled = true,
      },
      references = {
        includeDecompiledSources = true,
      },
      format = {
        enabled = true,
      },
    },
    signatureHelp = { enabled = true },
    completion = {
      favoriteStaticMembers = {
        "org.hamcrest.MatcherAssert.assertThat",
        "org.hamcrest.Matchers.*",
        "org.hamcrest.CoreMatchers.*",
        "org.junit.jupiter.api.Assertions.*",
        "java.util.Objects.requireNonNull",
        "java.util.Objects.requireNonNullElse",
        "org.mockito.Mockito.*",
      },
    },
    contentProvider = { preferred = "fernflower" },
    extendedClientCapabilities = jdtls.extendedClientCapabilities,
    sources = {
      organizeImports = {
        starThreshold = 9999,
        staticStarThreshold = 9999,
      },
    },
    codeGeneration = {
      toString = {
        template = "${object.className}{${member.name()}=${member.value}, ${otherMembers}}",
      },
      useBlocks = true,
    },
  },

  flags = {
    allow_incremental_sync = true,
  },

  init_options = {
    bundles = {},
  },

  on_attach = function(client, bufnr)
    -- Enable completion triggered by <c-x><c-o>
    vim.api.nvim_buf_set_option(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")

    -- Setup keybindings
    local opts = { noremap = true, silent = true, buffer = bufnr }
    
    -- LSP keybindings
    vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
    vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
    vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
    vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
    vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, opts)
    vim.keymap.set("n", "<leader>wa", vim.lsp.buf.add_workspace_folder, opts)
    vim.keymap.set("n", "<leader>wr", vim.lsp.buf.remove_workspace_folder, opts)
    vim.keymap.set("n", "<leader>wl", function()
      print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
    end, opts)
    vim.keymap.set("n", "<leader>D", vim.lsp.buf.type_definition, opts)
    vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
    vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
    vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
    vim.keymap.set("n", "<leader>f", function()
      vim.lsp.buf.format { async = true }
    end, opts)

    -- Java specific keybindings
    vim.keymap.set("n", "<leader>jo", function()
      require("jdtls").organize_imports()
    end, { desc = "Organize Imports", buffer = bufnr })

    vim.keymap.set("n", "<leader>jv", function()
      require("jdtls").extract_variable()
    end, { desc = "Extract Variable", buffer = bufnr })

    vim.keymap.set("v", "<leader>jv", function()
      require("jdtls").extract_variable(true)
    end, { desc = "Extract Variable", buffer = bufnr })

    vim.keymap.set("n", "<leader>jc", function()
      require("jdtls").extract_constant()
    end, { desc = "Extract Constant", buffer = bufnr })

    vim.keymap.set("v", "<leader>jc", function()
      require("jdtls").extract_constant(true)
    end, { desc = "Extract Constant", buffer = bufnr })

    vim.keymap.set("v", "<leader>jm", function()
      require("jdtls").extract_method(true)
    end, { desc = "Extract Method", buffer = bufnr })

    vim.keymap.set("n", "<leader>jt", function()
      require("jdtls").test_nearest_method()
    end, { desc = "Test Nearest Method", buffer = bufnr })

    vim.keymap.set("n", "<leader>jT", function()
      require("jdtls").test_class()
    end, { desc = "Test Class", buffer = bufnr })

    vim.keymap.set("n", "<leader>ju", function()
      require("jdtls").update_projects_config()
    end, { desc = "Update Project Config", buffer = bufnr })
  end,
}

-- Setup debugging and testing bundles
local bundles = {}

-- Find and add Java debug adapter
local java_debug_path = mason_path .. "/packages/java-debug-adapter"
if vim.fn.isdirectory(java_debug_path) == 1 then
  local debug_jar = vim.fn.glob(java_debug_path .. "/extension/server/com.microsoft.java.debug.plugin-*.jar")
  if debug_jar ~= "" then
    table.insert(bundles, debug_jar)
  end
end

-- Find and add Java test adapters
local java_test_path = mason_path .. "/packages/java-test"
if vim.fn.isdirectory(java_test_path) == 1 then
  local test_jars = vim.fn.glob(java_test_path .. "/extension/server/*.jar", false, true)
  for _, jar in ipairs(test_jars) do
    table.insert(bundles, jar)
  end
end

config.init_options.bundles = bundles

-- Start or attach JDTLS
jdtls.start_or_attach(config)

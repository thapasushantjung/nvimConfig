local jdtls = require "jdtls"
local home = os.getenv "HOME"

local mason_path = home .. "/.local/share/nvim/mason/packages"
local bundles = {
  mason_path .. "/java-debug-adapter/extension/server/com.microsoft.java.debug.plugin-0.53.1.jar",
}

vim.list_extend(bundles, vim.split(vim.fn.glob(mason_path .. "/java-test/extension/server/*.jar"), "\n"))

local workspace_folder = home .. "/.local/share/eclipse/" .. vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t")

local config = {
  cmd = {
    "jdtls",
    "-data",
    workspace_folder,
  },
  root_dir = require("jdtls.setup").find_root { ".git", "mvnw", "gradlew", "pom.xml", "build.gradle" },
  init_options = {
    bundles = bundles,
  },
  on_attach = function(_, _)
    require("jdtls").setup_dap { hotcodereplace = "auto" }
    require("jdtls.dap").setup_dap_main_class_configs()

    vim.keymap.set("n", "<leader>djt", function()
      require("jdtls").test_nearest_method()
    end, { desc = "Run nearest Java test" })

    vim.keymap.set("n", "<leader>djc", function()
      require("jdtls").test_class()
    end, { desc = "Run current Java test class" })
    local dap = require "dap"
    local filename = vim.fn.expand "%:t:r" -- e.g., Main
    local package_line = vim.fn.search("package ", "nw")
    local package_name = ""
    if package_line ~= 0 then
      package_name = vim.fn.getline(package_line):gsub("package ", ""):gsub(";", ""):gsub("%s+", "")
    end
    local full_class = (package_name ~= "") and (package_name .. "." .. filename) or filename

    dap.configurations.java = {
      {
        type = "java",
        request = "launch",
        name = "Launch " .. full_class,
        mainClass = full_class,
        projectName = "DemoProject",
      },
    }
  end,
}

jdtls.start_or_attach(config)

-- DAP configuration for Java debugging
-- This file sets up nvim-dap for Java when JDTLS is attached

local dap = require "dap"

-- Java adapter configuration
dap.adapters.java = function(callback, config)
  -- Wait for JDTLS to be ready before setting up DAP
  local function setup_java_dap()
    local jdtls_dap = require "jdtls.dap"
    
    -- Setup DAP with hot code replace support
    require("jdtls").setup_dap({ hotcodereplace = "auto" })
    
    -- Setup main class configurations
    jdtls_dap.setup_dap_main_class_configs()
    
    callback({
      type = "server",
      host = "127.0.0.1",
      port = "${port}",
    })
  end
  
  -- Check if JDTLS is attached
  local clients = vim.lsp.get_active_clients({ name = "jdtls" })
  if #clients > 0 then
    setup_java_dap()
  else
    -- Retry after a short delay
    vim.defer_fn(function()
      local retry_clients = vim.lsp.get_active_clients({ name = "jdtls" })
      if #retry_clients > 0 then
        setup_java_dap()
      else
        vim.notify("JDTLS not ready for debugging", vim.log.levels.WARN)
      end
    end, 1000)
  end
end

-- Basic Java configurations
dap.configurations.java = {
  {
    type = "java",
    request = "attach",
    name = "Debug (Attach) - Remote",
    hostName = "127.0.0.1",
    port = 5005,
  },
  {
    type = "java",
    request = "launch",
    name = "Debug (Launch) - Current File",
    mainClass = function()
      -- Get current file's main class
      local current_file = vim.fn.expand("%:t:r")
      local package = ""
      
      -- Try to extract package from current file
      local lines = vim.api.nvim_buf_get_lines(0, 0, 10, false)
      for _, line in ipairs(lines) do
        local package_match = line:match("^package%s+([%w%.]+);")
        if package_match then
          package = package_match .. "."
          break
        end
      end
      
      return package .. current_file
    end,
  },
}

-- Keymaps for Java debugging
local function setup_java_debug_keymaps()
  local opts = { noremap = true, silent = true }
  
  vim.keymap.set("n", "<leader>djb", function()
    dap.toggle_breakpoint()
  end, vim.tbl_extend("force", opts, { desc = "Toggle DAP Breakpoint" }))
  
  vim.keymap.set("n", "<leader>djc", function()
    dap.continue()
  end, vim.tbl_extend("force", opts, { desc = "DAP Continue" }))
  
  vim.keymap.set("n", "<leader>djs", function()
    dap.step_over()
  end, vim.tbl_extend("force", opts, { desc = "DAP Step Over" }))
  
  vim.keymap.set("n", "<leader>dji", function()
    dap.step_into()
  end, vim.tbl_extend("force", opts, { desc = "DAP Step Into" }))
  
  vim.keymap.set("n", "<leader>djo", function()
    dap.step_out()
  end, vim.tbl_extend("force", opts, { desc = "DAP Step Out" }))
  
  vim.keymap.set("n", "<leader>djr", function()
    dap.repl.open()
  end, vim.tbl_extend("force", opts, { desc = "DAP Open REPL" }))
  
  vim.keymap.set("n", "<leader>djl", function()
    dap.run_last()
  end, vim.tbl_extend("force", opts, { desc = "DAP Run Last" }))
  
  vim.keymap.set("n", "<leader>djt", function()
    require("jdtls").test_nearest_method()
  end, vim.tbl_extend("force", opts, { desc = "Run nearest Java test" }))
  
  vim.keymap.set("n", "<leader>djT", function()
    require("jdtls").test_class()
  end, vim.tbl_extend("force", opts, { desc = "Run current Java test class" }))
end

-- Setup keymaps when this file is loaded
setup_java_debug_keymaps()

-- Auto-command to setup additional debugging when JDTLS attaches
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("JavaDapSetup", { clear = true }),
  pattern = "*.java",
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if client and client.name == "jdtls" then
      -- JDTLS has attached, setup DAP
      require("jdtls").setup_dap({ hotcodereplace = "auto" })
      require("jdtls.dap").setup_dap_main_class_configs()
    end
  end,
})

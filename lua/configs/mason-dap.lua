require("mason-nvim-dap").setup {
  ensure_installed = { 
    "java-debug-adapter",
    "java-test",
  },
  automatic_installation = { exclude = {} },
  handlers = {
    function(config)
      -- Default handler for all DAP adapters
      require("mason-nvim-dap").default_setup(config)
    end,
    -- Note: Java debugging is handled by nvim-jdtls, not through mason-nvim-dap
    -- The java-debug-adapter and java-test are installed but configured in ftplugin/java.lua
  },
}

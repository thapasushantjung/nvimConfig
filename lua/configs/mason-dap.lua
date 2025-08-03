require("mason-nvim-dap").setup {
  ensure_installed = { 
    "java-debug-adapter",
    "java-test",
  },
  automatic_installation = { exclude = {} },
  handlers = {
    function(config)
      -- Default handler
      require("mason-nvim-dap").default_setup(config)
    end,
    java = function(config)
      -- Java debugging is handled by nvim-jdtls
      -- No additional setup needed here
    end,
  },
}

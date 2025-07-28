local jdtls = require "jdtls"
local home = os.getenv "HOME"

local mason_path = home .. "/.local/share/nvim/mason/packages"
local bundles = {}

-- Add debug adapter bundle
local debug_jar = mason_path .. "/java-debug-adapter/extension/server/com.microsoft.java.debug.plugin-0.53.1.jar"
if vim.fn.filereadable(debug_jar) == 1 then
  table.insert(bundles, debug_jar)
end

-- Add only essential test bundles (exclude problematic ones)
local test_jars = {
  "com.microsoft.java.test.plugin-0.43.1.jar",
  "org.eclipse.jdt.junit4.runtime_1.3.100.v20231214-1952.jar",
  "org.eclipse.jdt.junit5.runtime_1.1.300.v20231214-1952.jar",
}

for _, jar in ipairs(test_jars) do
  local jar_path = mason_path .. "/java-test/extension/server/" .. jar
  if vim.fn.filereadable(jar_path) == 1 then
    table.insert(bundles, jar_path)
  end
end

-- Helper function to detect project type and structure
local function get_project_info()
  local cwd = vim.fn.getcwd()
  local project_name = vim.fn.fnamemodify(cwd, ":t")
  local is_gradle = vim.fn.filereadable(cwd .. "/build.gradle") == 1 or vim.fn.filereadable(cwd .. "/build.gradle.kts") == 1
  local is_maven = vim.fn.filereadable(cwd .. "/pom.xml") == 1
  local has_settings_gradle = vim.fn.filereadable(cwd .. "/settings.gradle") == 1 or vim.fn.filereadable(cwd .. "/settings.gradle.kts") == 1
  
  -- Check for gradle multi-module project
  local is_multi_module = false
  local subprojects = {}
  
  if is_gradle and has_settings_gradle then
    local settings_file = vim.fn.filereadable(cwd .. "/settings.gradle") == 1 and "settings.gradle" or "settings.gradle.kts"
    local settings_content = vim.fn.readfile(cwd .. "/" .. settings_file)
    for _, line in ipairs(settings_content) do
      -- Match various include patterns
      local include_match = line:match("include%s*['\"]([^'\"]+)['\"]") or 
                           line:match("include%s*%(.*['\"]([^'\"]+)['\"]") or
                           line:match("include%s+([^%s,)]+)")
      if include_match then
        table.insert(subprojects, include_match)
        is_multi_module = true
      end
    end
  end
  
  -- Also check for Maven multi-module projects
  if is_maven and not is_multi_module then
    local pom_content = vim.fn.readfile(cwd .. "/pom.xml")
    local in_modules = false
    for _, line in ipairs(pom_content) do
      if line:match("<modules>") then
        in_modules = true
      elseif line:match("</modules>") then
        in_modules = false
      elseif in_modules then
        local module_match = line:match("<module>([^<]+)</module>")
        if module_match then
          table.insert(subprojects, module_match)
          is_multi_module = true
        end
      end
    end
  end
  
  return {
    name = project_name,
    is_gradle = is_gradle,
    is_maven = is_maven,
    is_multi_module = is_multi_module,
    subprojects = subprojects,
    root_dir = cwd
  }
end

-- Generate unique workspace folder name
local function get_workspace_folder()
  local project_info = get_project_info()
  local workspace_name = project_info.name
  
  -- Add hash of full path to avoid conflicts
  local path_hash = vim.fn.fnamemodify(project_info.root_dir, ":p"):gsub("/", "_"):gsub(":", "")
  workspace_name = workspace_name .. "_" .. string.sub(vim.fn.sha256(path_hash), 1, 8)
  
  return home .. "/.local/share/eclipse/" .. workspace_name
end

local workspace_folder = get_workspace_folder()

-- Clean up any corrupted workspace data
local function cleanup_workspace()
  if vim.fn.isdirectory(workspace_folder) == 1 then
    local metadata_file = workspace_folder .. "/.metadata"
    if vim.fn.isdirectory(metadata_file) == 1 then
      -- Check if workspace is corrupted
      local lock_file = metadata_file .. "/.lock"
      if vim.fn.filereadable(lock_file) == 1 then
        vim.fn.delete(lock_file)
      end
    end
  end
end

cleanup_workspace()

local config = {
  cmd = {
    "jdtls",
    "-data",
    workspace_folder,
    "--add-modules=ALL-SYSTEM",
    "--add-opens",
    "java.base/java.util=ALL-UNNAMED",
    "--add-opens",
    "java.base/java.lang=ALL-UNNAMED",
  },
  root_dir = require("jdtls.setup").find_root { ".git", "mvnw", "gradlew", "pom.xml", "build.gradle" },
  init_options = {
    bundles = bundles,
    extendedClientCapabilities = {
      progressReportProvider = true,
    },
  },
  settings = {
    java = {
      eclipse = {
        downloadSources = true,
      },
      configuration = {
        updateBuildConfiguration = "interactive",
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
  on_attach = function(_, _)
    require("jdtls").setup_dap { hotcodereplace = "auto" }
    require("jdtls.dap").setup_dap_main_class_configs()

    vim.keymap.set("n", "<leader>djt", function()
      require("jdtls").test_nearest_method()
    end, { desc = "Run nearest Java test" })

    vim.keymap.set("n", "<leader>djc", function()
      require("jdtls").test_class()
    end, { desc = "Run current Java test class" })
    
    -- Additional keymaps for multi-module projects
    vim.keymap.set("n", "<leader>djr", function()
      local project_info = get_project_info()
      if project_info.is_multi_module then
        vim.ui.select(project_info.subprojects, {
          prompt = "Select subproject to run:",
          format_item = function(item)
            return item:gsub(":", " > ")
          end,
        }, function(choice)
          if choice then
            vim.cmd("terminal ./gradlew " .. choice .. ":run")
          end
        end)
      else
        if project_info.is_gradle then
          vim.cmd("terminal ./gradlew run")
        elseif project_info.is_maven then
          vim.cmd("terminal ./mvnw exec:java")
        end
      end
    end, { desc = "Run Java project/subproject" })
    
    vim.keymap.set("n", "<leader>djb", function()
      local project_info = get_project_info()
      if project_info.is_gradle then
        if project_info.is_multi_module then
          vim.cmd("terminal ./gradlew build")
        else
          vim.cmd("terminal ./gradlew build")
        end
      elseif project_info.is_maven then
        vim.cmd("terminal ./mvnw compile")
      end
    end, { desc = "Build Java project" })
    
    vim.keymap.set("n", "<leader>djp", function()
      local project_info = get_project_info()
      if project_info.is_multi_module then
        print("Multi-module project: " .. project_info.name)
        print("Subprojects: " .. table.concat(project_info.subprojects, ", "))
      else
        print("Single module project: " .. project_info.name)
      end
      print("Build system: " .. (project_info.is_gradle and "Gradle" or project_info.is_maven and "Maven" or "Unknown"))
    end, { desc = "Show Java project info" })
    
    -- Additional troubleshooting keymaps
    vim.keymap.set("n", "<leader>djR", function()
      vim.cmd("LspRestart jdtls")
    end, { desc = "Restart JDTLS" })
    
    vim.keymap.set("n", "<leader>djC", function()
      local workspace_folder = get_workspace_folder()
      if vim.fn.isdirectory(workspace_folder) == 1 then
        vim.fn.delete(workspace_folder, "rf")
        print("Workspace cleaned: " .. workspace_folder)
        vim.cmd("LspRestart jdtls")
      else
        print("No workspace to clean")
      end
    end, { desc = "Clean Java workspace and restart JDTLS" })
    
    vim.keymap.set("n", "<leader>djL", function()
      vim.cmd("edit " .. vim.fn.stdpath("log") .. "/lsp.log")
    end, { desc = "Open LSP log file" })
    
    -- Dynamic DAP configuration setup
    local function setup_dap_configurations()
      local dap = require "dap"
      local project_info = get_project_info()
      
      -- Helper function to get current file info
      local function get_current_file_info()
        local filename = vim.fn.expand "%:t:r" -- e.g., Main
        local filepath = vim.fn.expand "%:p"
        local package_line = vim.fn.search("package ", "nw")
        local package_name = ""
        
        if package_line ~= 0 then
          package_name = vim.fn.getline(package_line):gsub("package ", ""):gsub(";", ""):gsub("%s+", "")
        end
        
        local full_class = (package_name ~= "") and (package_name .. "." .. filename) or filename
        
        -- Try to determine which subproject this file belongs to
        local subproject_name = nil
        if project_info.is_multi_module then
          for _, subproject in ipairs(project_info.subprojects) do
            local subproject_path = project_info.root_dir .. "/" .. subproject:gsub(":", "/")
            if filepath:find(subproject_path, 1, true) then
              subproject_name = subproject:gsub(":", "")
              break
            end
          end
        end
        
        return {
          filename = filename,
          full_class = full_class,
          package_name = package_name,
          subproject = subproject_name or project_info.name
        }
      end
      
      -- Create configurations for current file
      local function create_current_file_config()
        local file_info = get_current_file_info()
        return {
          type = "java",
          request = "launch",
          name = "Launch " .. file_info.full_class .. " (" .. file_info.subproject .. ")",
          mainClass = file_info.full_class,
          projectName = file_info.subproject,
          console = "internalConsole",
          stopOnEntry = false,
        }
      end
      
      -- Create configurations for multi-module projects
      local function create_multimodule_configs()
        local configs = {}
        
        -- Add a generic "Ask for main class" configuration
        table.insert(configs, {
          type = "java",
          request = "launch",
          name = "Launch Java Application",
          mainClass = function()
            return vim.fn.input("Main class: ", "", "file")
          end,
          projectName = project_info.name,
          console = "internalConsole",
          stopOnEntry = false,
        })
        
        -- Add configurations for each subproject if they have main classes
        for _, subproject in ipairs(project_info.subprojects) do
          local subproject_clean = subproject:gsub(":", "")
          table.insert(configs, {
            type = "java",
            request = "launch",
            name = "Launch " .. subproject_clean .. " Application",
            mainClass = function()
              return vim.fn.input("Main class for " .. subproject_clean .. ": ", "", "file")
            end,
            projectName = subproject_clean,
            console = "internalConsole",
            stopOnEntry = false,
          })
        end
        
        return configs
      end
      
      -- Set up DAP configurations
      local configs = {}
      
      -- Always add current file configuration if we're in a Java file
      if vim.bo.filetype == "java" then
        table.insert(configs, create_current_file_config())
      end
      
      -- Add multi-module configurations
      if project_info.is_multi_module then
        vim.list_extend(configs, create_multimodule_configs())
      else
        -- Single module project
        table.insert(configs, {
          type = "java",
          request = "launch",
          name = "Launch Java Application",
          mainClass = function()
            return vim.fn.input("Main class: ", "", "file")
          end,
          projectName = project_info.name,
          console = "internalConsole",
          stopOnEntry = false,
        })
      end
      
      -- Add test configurations
      table.insert(configs, {
        type = "java",
        request = "launch",
        name = "Launch Java Tests",
        mainClass = "",
        projectName = project_info.name,
        console = "internalConsole",
        stopOnEntry = false,
        vmArgs = "-ea", -- Enable assertions for tests
        args = "",
      })
      
      dap.configurations.java = configs
    end
    
    -- Set up configurations immediately
    setup_dap_configurations()
    
    -- Update configurations when entering a Java buffer
    vim.api.nvim_create_autocmd("BufEnter", {
      pattern = "*.java",
      callback = function()
        setup_dap_configurations()
      end,
    })
  end,
}

jdtls.start_or_attach(config)

# Java & Gradle LSP Setup Fixed

## What was fixed:

### Java LSP (JDTLS)
1. **Moved JDTLS configuration to `ftplugin/java.lua`** - This ensures JDTLS loads properly for each Java buffer
2. **Fixed JDTLS command path** - Now uses correct Mason installation path
3. **Added proper debugging integration** - Java debugging now works with nvim-dap
4. **Fixed workspace handling** - Better workspace folder management for projects

### Gradle LSP
1. **Fixed gradle-language-server command** - Now uses the correct executable from Mason
2. **Improved root directory detection** - Better detection of Gradle projects
3. **Added proper settings** - Enabled Gradle wrapper support

### Mason Integration
1. **Added mason-lspconfig plugin** - Ensures LSP servers are properly installed
2. **Auto-installation** - Important LSP servers are automatically installed
3. **Fixed DAP integration** - Java debugging adapters are properly configured

## How to test:

### Java LSP Testing
1. Open a Java file: `nvim ~/my-first-project/app/src/main/java/com/example/app/Main.java`
2. You should see:
   - Syntax highlighting (treesitter)
   - LSP diagnostics and completion
   - Code actions available
   - Hover documentation

### Java-specific keybindings (when in a Java file):
- `<leader>jo` - Organize imports
- `<leader>jv` - Extract variable
- `<leader>jc` - Extract constant
- `<leader>jm` - Extract method (visual mode)
- `<leader>jt` - Test nearest method
- `<leader>jT` - Test class
- `<leader>ju` - Update project config

### Java Debugging keybindings:
- `<leader>djb` - Toggle breakpoint
- `<leader>djc` - Continue debugging
- `<leader>djs` - Step over
- `<leader>dji` - Step into
- `<leader>djo` - Step out
- `<leader>djr` - Open REPL
- `<leader>djl` - Run last configuration

### Gradle LSP Testing
1. Open a Gradle file: `nvim ~/my-first-project/build.gradle.kts`
2. You should see:
   - Syntax highlighting
   - LSP completion for Gradle DSL
   - Error checking

### General LSP Testing
1. `:LspInfo` - Check which LSP servers are attached
2. `:Mason` - Open Mason to install/manage LSP servers
3. `:checkhealth lsp` - Check LSP health

## Troubleshooting:

### If Java LSP doesn't work:
1. Check if JDTLS is installed: `:MasonInstall jdtls`
2. Restart LSP: `:LspRestart`
3. Check logs: `:edit ~/.local/share/nvim/lsp.log`

### If Gradle LSP doesn't work:
1. Check if Gradle LS is installed: `:MasonInstall gradle-language-server`
2. Ensure you're in a Gradle project (has build.gradle or build.gradle.kts)
3. Check LSP status: `:LspInfo`

### If debugging doesn't work:
1. Install debug adapters: `:MasonInstall java-debug-adapter java-test`
2. Check DAP status: `:lua print(vim.inspect(require('dap').configurations.java))`
3. Try DAP UI: `<leader>du`

## Project Structure Created:
- `~/my-first-project/settings.gradle.kts` - Multi-module project configuration
- `~/my-first-project/build.gradle.kts` - Root build file
- `~/my-first-project/app/build.gradle.kts` - App module build file
- `~/my-first-project/app/src/main/java/com/example/app/Main.java` - Sample Java class

The project is now properly configured as a Gradle multi-module project with Java 21 support.

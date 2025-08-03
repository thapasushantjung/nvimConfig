# Java & Gradle LSP - Quick Reference

## ✅ What's Fixed & Configured

### Java LSP (JDTLS)
- **Proper JDTLS Integration**: Uses `ftplugin/java.lua` for per-buffer loading
- **Mason Integration**: Auto-installs and manages JDTLS
- **Debugging Support**: Fully configured with nvim-dap and DAP UI
- **Java 21 Support**: Configured for OpenJDK 21
- **Project Detection**: Supports Maven and Gradle projects

### Gradle LSP
- **Language Server**: Properly configured with Mason installation
- **File Types**: Supports `.gradle`, `.gradle.kts`, and Kotlin DSL
- **Project Detection**: Recognizes Gradle wrapper and settings files

### Debug Adapters
- **Java Debug Adapter**: For debugging Java applications
- **Java Test**: For running and debugging JUnit tests

## 🎯 Key Commands & Shortcuts

### General LSP (works in any LSP-enabled file)
- `gd` - Go to definition
- `K` - Show hover documentation
- `gr` - Show references
- `<leader>ca` - Code actions
- `<leader>rn` - Rename symbol
- `<leader>f` - Format file

### Java-Specific Commands (when in .java files)
- `<leader>jo` - Organize imports
- `<leader>jv` - Extract variable
- `<leader>jc` - Extract constant
- `<leader>jm` - Extract method (visual mode)
- `<leader>jt` - Test nearest method
- `<leader>jT` - Test class
- `<leader>ju` - Update project config

### Java Debugging Commands
- `<leader>djb` - Toggle breakpoint
- `<leader>djc` - Continue/Start debugging
- `<leader>djs` - Step over
- `<leader>dji` - Step into
- `<leader>djo` - Step out
- `<leader>djr` - Open debug REPL
- `<leader>djl` - Run last debug configuration
- `<leader>djt` - Run nearest test method
- `<leader>djT` - Run test class

### General DAP Commands
- `<leader>db` - Toggle breakpoint (general)
- `<leader>du` - Toggle DAP UI
- `<leader>dr` - Start/continue debugging (general)

### Utility Commands
- `:LspInfo` - Show LSP status and attached servers
- `:LspRestart` - Restart LSP servers
- `:Mason` - Open Mason package manager
- `:checkhealth lsp` - Check LSP health
- `:MasonInstall <package>` - Install specific package

## 📁 Test Project Structure

The test project at `~/my-first-project` includes:
```
my-first-project/
├── settings.gradle.kts          # Multi-module configuration
├── build.gradle.kts             # Root build script
└── app/
    ├── build.gradle.kts         # App module build script
    └── src/main/java/com/example/app/
        └── Main.java            # Sample Java class
```

## 🚀 Quick Start

1. **Open Java file**:
   ```bash
   cd ~/my-first-project
   nvim app/src/main/java/com/example/app/Main.java
   ```

2. **Verify LSP is working**:
   - Type `:LspInfo` to see attached servers
   - Hover over `System` with `K` to see documentation
   - Use `gd` on any method to go to definition

3. **Test Gradle LSP**:
   ```bash
   nvim build.gradle.kts
   ```
   - Should see syntax highlighting and completion

4. **Test Debugging**:
   - Set breakpoint on line 4: `<leader>djb`
   - Start debugging: `<leader>djc`
   - Open DAP UI: `<leader>du`

## 🔧 Configuration Files Modified

- **`ftplugin/java.lua`**: JDTLS setup (loads per Java buffer)
- **`lua/configs/lspconfig.lua`**: General LSP configuration
- **`lua/configs/dap-java.lua`**: Java debugging configuration
- **`lua/configs/mason-dap.lua`**: Debug adapter management
- **`lua/plugins/init.lua`**: Plugin configurations

## 📊 Installation Status

All required packages are installed via Mason:
- ✅ jdtls (Java Language Server)
- ✅ gradle-language-server (Gradle LSP)
- ✅ java-debug-adapter (Java debugging)
- ✅ java-test (JUnit test support)

## 🛠 Troubleshooting

### Java LSP not working?
1. Check JDTLS installation: `:MasonInstall jdtls`
2. Restart LSP: `:LspRestart`
3. Check workspace: Ensure you're in a Java project directory
4. Check logs: `:edit ~/.local/share/nvim/lsp.log`

### Gradle LSP not working?
1. Check installation: `:MasonInstall gradle-language-server`
2. Ensure you're in a Gradle project (has `build.gradle` or `build.gradle.kts`)
3. Check `:LspInfo` for attached servers

### Debugging not working?
1. Install debug adapters: `:MasonInstall java-debug-adapter java-test`
2. Check DAP configurations: `:lua print(vim.inspect(require('dap').configurations.java))`
3. Ensure JDTLS is attached before debugging

### General Issues
- Run test script: `bash ~/.config/nvim/test_lsp_setup.sh`
- Check health: `:checkhealth lsp`
- Update packages: `:MasonUpdate`

---

**🎉 Your Java and Gradle LSP setup is now complete and ready to use!**

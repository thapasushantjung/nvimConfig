#!/bin/bash

# Java & Gradle LSP Test Script
# This script helps test if the Java and Gradle LSP configurations are working properly

echo "=== Java & Gradle LSP Configuration Test ==="
echo ""

# Test 1: Check if required tools are installed
echo "1. Checking required tools..."
echo -n "  Java: "
if command -v java >/dev/null 2>&1; then
    java -version 2>&1 | head -1
else
    echo "❌ NOT FOUND"
    exit 1
fi

echo -n "  Neovim: "
if command -v nvim >/dev/null 2>&1; then
    nvim --version | head -1
else
    echo "❌ NOT FOUND"
    exit 1
fi

# Test 2: Check Mason installations
echo ""
echo "2. Checking Mason LSP installations..."
MASON_DIR="$HOME/.local/share/nvim/mason/packages"

check_mason_package() {
    local package_name=$1
    if [ -d "$MASON_DIR/$package_name" ]; then
        echo "  ✅ $package_name"
    else
        echo "  ❌ $package_name"
    fi
}

check_mason_package "jdtls"
check_mason_package "gradle-language-server" 
check_mason_package "java-debug-adapter"
check_mason_package "java-test"

# Test 3: Check configuration files
echo ""
echo "3. Checking configuration files..."

check_config_file() {
    local file_path=$1
    local description=$2
    if [ -f "$file_path" ]; then
        echo "  ✅ $description"
    else
        echo "  ❌ $description"
    fi
}

check_config_file "$HOME/.config/nvim/ftplugin/java.lua" "Java ftplugin configuration"
check_config_file "$HOME/.config/nvim/lua/configs/lspconfig.lua" "LSP configuration"
check_config_file "$HOME/.config/nvim/lua/configs/dap-java.lua" "Java DAP configuration"

# Test 4: Check test project
echo ""
echo "4. Checking test project structure..."
PROJECT_DIR="$HOME/my-first-project"

check_project_file() {
    local file_path=$1
    local description=$2
    if [ -f "$file_path" ]; then
        echo "  ✅ $description"
    else
        echo "  ❌ $description"
    fi
}

check_project_file "$PROJECT_DIR/settings.gradle.kts" "Gradle settings"
check_project_file "$PROJECT_DIR/build.gradle.kts" "Root build file"
check_project_file "$PROJECT_DIR/app/build.gradle.kts" "App build file"
check_project_file "$PROJECT_DIR/app/src/main/java/com/example/app/Main.java" "Main Java class"

echo ""
echo "=== How to test manually ==="
echo ""
echo "1. Open Java file:"
echo "   cd ~/my-first-project"
echo "   nvim app/src/main/java/com/example/app/Main.java"
echo ""
echo "2. In Neovim, check LSP status:"
echo "   :LspInfo"
echo "   :Mason"
echo ""
echo "3. Test Java features:"
echo "   - Hover over 'System' to see documentation (K)"
echo "   - Go to definition on methods (gd)"
echo "   - Use code actions (<leader>ca)"
echo "   - Try Java-specific commands (<leader>jo for organize imports)"
echo ""
echo "4. Test Gradle LSP:"
echo "   :e build.gradle.kts"
echo "   - Should see syntax highlighting and completion"
echo ""
echo "5. Test debugging:"
echo "   - Set breakpoint with <leader>djb"
echo "   - Start debugging with <leader>djc"
echo "   - Open DAP UI with <leader>du"
echo ""
echo "=== Troubleshooting ==="
echo ""
echo "If something doesn't work:"
echo "1. Restart LSP: :LspRestart"
echo "2. Check health: :checkhealth lsp"
echo "3. Install missing packages: :MasonInstall <package>"
echo "4. Check logs: :edit ~/.local/share/nvim/lsp.log"
echo ""

# Final check
echo "=== Test Results ==="
if [ -d "$MASON_DIR/jdtls" ] && [ -f "$HOME/.config/nvim/ftplugin/java.lua" ] && [ -f "$PROJECT_DIR/app/src/main/java/com/example/app/Main.java" ]; then
    echo "✅ Configuration appears to be complete!"
    echo "📝 See JAVA_GRADLE_LSP_SETUP.md for detailed instructions"
else
    echo "❌ Some components are missing. Please check the errors above."
fi

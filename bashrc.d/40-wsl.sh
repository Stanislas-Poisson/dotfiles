# WSL specific aliases (core.fileMode is set once in ~/.gitconfig).

if grep -qEi "(Microsoft|WSL)" /proc/version &>/dev/null; then
    alias explore='explorer.exe .'
    alias open='explorer.exe'
fi

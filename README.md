# Dotfiless

Personal configuration for **Neovim**, **tmux**, and **Kitty**. The Neovim setup is written in Lua and uses Neovim's built-in plugin manager.

## What's included

- **Neovim**: Moonfly colorscheme, `mini.nvim` tools (file browser, fuzzy picker, completion, snippets, and more), Tree-sitter highlighting, LSP support, Git integration, and a code runner.
- **tmux**: mouse support, a top status bar, and styled window and pane indicators.
- **Kitty**: JetBrainsMono Nerd Font, Catppuccin Mocha terminal colors, a bottom tab bar, and shortcuts for tabs, windows, and font sizing.

## Screenshots

![tmux terminal screenshot](https://plain-apac-prod-public.komododecks.com/202610/12/UWhGXu3UW9Et6uzhQ9vj/image.png)

## Requirements

- Neovim **0.12 or newer** (`vim.pack` is used to manage plugins)
- Git, for downloading Neovim plugins
- tmux
- Kitty (optional if you use another terminal)
- JetBrainsMono Nerd Font installed on your system for the configured Kitty font
- The `tree-sitter` CLI for installing Neovim parsers
- `/usr/bin/zsh`, as configured as tmux's default shell

Neovim language-server support is configured for Lua, Markdown, Go, and Rust. Install the language servers you need with Mason from Neovim, for example:

```vim
:MasonInstall lua-language-server marksman gopls rust-analyzer
```

The code runner also needs the relevant language toolchains available on your `PATH` (such as Python, Node.js, Go, Rust, GCC, or Java) for the file types you want to run. System clipboard integration requires a working Neovim clipboard provider.

## Install

Clone this repository, then run these commands from its root. Back up or move any existing configuration files at the target paths first.

```sh
mkdir -p "$HOME/.config"
ln -s "$PWD/.config/nvim" "$HOME/.config/nvim"
mkdir -p "$HOME/.config/kitty"
ln -s "$PWD/.config/kitty/kitty.conf" "$HOME/.config/kitty/kitty.conf"
ln -s "$PWD/tmux.conf" "$HOME/.tmux.conf"
```

Start Neovim with `nvim`. Its first launch downloads the configured plugins. Parsers listed in the Tree-sitter configuration are installed through the Neovim plugin setup.

## Neovim shortcuts

The leader key is **Space**.

| Shortcut | Action |
| --- | --- |
| `-` | Open the file explorer |
| `<Space>-` | Open the explorer at the current file |
| `<Space>pf` | Find files |
| `<Space>ps` | Search for the word under the cursor |
| `<Space>vh` | Search Neovim help |
| `<Space>xx` | Browse diagnostics |
| `<Space>pk` | Search keymaps |
| `gd` | Go to definition |
| `<Space>f` | Format the current buffer |
| `<Space>e` | Show diagnostics for the current line |
| `F6` / `F7` | Run the current file / close the runner |
| `<Space>gg` | Open Fugitive in a new tab |
| `<Space>gd` | Open a Git diff split |
| `<Space>u` | Open the undo tree |

To update plugins, run `:PackUpdate` in Neovim. `:PackAdd` and `:PackDel` are also available for adding and removing plugins.

## Kitty shortcuts

| Shortcut | Action |
| --- | --- |
| `Ctrl+Shift+T` | Open a tab in the current working directory |
| `Ctrl+Shift+Enter` | Open a window in the current working directory |
| `Ctrl+Shift+=` | Increase font size |
| `Ctrl+Shift+-` | Decrease font size |
| `Ctrl+Shift+0` | Reset font size |
| `Ctrl+Shift+F5` | Reload Kitty configuration |

## Configuration files

- Neovim: `.config/nvim/`
- Kitty: `.config/kitty/kitty.conf`
- tmux: `tmux.conf`
#update 

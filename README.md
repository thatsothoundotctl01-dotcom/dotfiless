# Dotfiless

A polished personal terminal setup for **Neovim**, **tmux**, and **Kitty**. This config is tuned for a fast, distraction-free workflow with Lua-based Neovim configuration and built-in plugin management.

![Neovim](https://plain-apac-prod-public.komododecks.com/202610/12/uqAB3B5q9U1IAtTRqXfo/image.png)

## Highlights

- Lua-first Neovim configuration
- Modern tmux workflow with a zsh default shell
- Kitty terminal setup with Nerd Font styling
- LSP support for Lua, Markdown, Go, and Rust
- Fast file navigation and project search
- Built-in code execution and diagnostics workflow

## Screenshots

### Cursor demo

[![Cursor animation](https://cdn.videotourl.net/thumbnails/4b0c2ca7-67c2-459d-8156-89160e3d7235.jpg)](https://videotourl.net/v/4b0c2ca7-67c2-459d-8156-89160e3d7235)

### tmux workspace

![tmux terminal](https://plain-apac-prod-public.komododecks.com/202610/12/UWhGXu3UW9Et6uzhQ9vj/image.png)

## Requirements

Before installing, make sure you have:

- Neovim **0.12 or newer** (`vim.pack` is used to manage plugins)
- Git for fetching plugins
- tmux
- Kitty (optional if you use another terminal)
- JetBrainsMono Nerd Font installed
- `tree-sitter` CLI for installing language parsers
- `/usr/bin/zsh` configured as tmux's default shell

Neovim LSP support is configured for Lua, Markdown, Go, and Rust. Install the language servers you need with Mason:

```vim
:MasonInstall lua-language-server marksman gopls rust-analyzer
```

The code runner also expects the relevant toolchains to be on your `PATH` (for example Python, Node.js, Go, Rust, GCC, or Java), depending on the file types you want to execute. Clipboard integration also requires a working Neovim clipboard provider.

## Quick install

Install Neovim 0.12.2 and place it on your `PATH`:

```bash
curl -LO https://github.com/neovim/neovim/releases/download/v0.12.2/nvim-linux-x86_64.tar.gz && \
  sudo rm -rf /opt/nvim-linux-x86_64 && \
  sudo tar -C /opt -xzf nvim-linux-x86_64.tar.gz && \
  sudo ln -sf /opt/nvim-linux-x86_64/bin/nvim /usr/local/bin/nvim && \
  nvim --version | head -
```

After that, open Neovim and install the plugin set:

```vim
:PackUpdate
```


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




# dotfiles (zsh)
Portable zsh setup for Linux/macOS with selectable themes.

## Recommended themes
1. `powerlevel10k` (default): fastest + most configurable, ideal daily driver.
2. `spaceship`: clean and modern prompt, balanced info density.
3. `pure`: minimal prompt, good for low-noise workflows.
4. `agnoster`: classic segmented look, works well on Nerd Fonts.

## Install
```bash
cd ~/.bashrc
./install.sh --theme powerlevel10k
```

Available theme values:
- `powerlevel10k`
- `spaceship`
- `pure`
- `agnoster`

## Re-apply with another theme
```bash
cd ~/.bashrc
./install.sh --theme pure
exec zsh
```

## Terminal animations
```bash
# ASCII frame animation
~/.chacharc/bin/cinamol -i ~/.chacharc/bin/imgs --fps 8 -m RGB

# NyanCat saver (Ctrl-C to stop)
~/.chacharc/bin/saver
```

## Self-heal check
If animation tools stop working:
```bash
cd ~/.bashrc
./refresh.sh
```

## Vim fixed layout
Vim now starts in a fixed layout only:
- left: NERDTree
- bottom: terminal
- remaining area: editor window

Other optional IDE behaviors were removed to keep this layout stable.

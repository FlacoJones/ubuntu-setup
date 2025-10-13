# Make Ctrl+E (^E) the interrupt (INTR) character in the terminal
stty intr ^E
gsettings set org.gnome.desktop.interface can-change-accels true
gsettings set org.gnome.Terminal.Legacy.Keybindings:/org/gnome/terminal/legacy/keybindings/ copy '<Primary>c'
gsettings set org.gnome.Terminal.Legacy.Keybindings:/org/gnome/terminal/legacy/keybindings/ paste '<Primary>v'
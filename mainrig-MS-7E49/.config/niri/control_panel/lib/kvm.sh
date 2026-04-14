
# menu: KVM | 🖥️ Manage PiKVM Port 0
manage_pikvm_port_0() {
	source ~/scripts/functions/pikvm
	alacritty -e zsh -c "source /home/blu/scripts/functions/pikvm; manage_pikvm_port 0; exec zsh"
}

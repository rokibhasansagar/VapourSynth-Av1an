# syntax=docker/dockerfile:1-labs
FROM --platform=$BUILDPLATFORM archlinux:base-devel

ARG TARGETPLATFORM
ARG BUILDPLATFORM

# USER root

SHELL ["/bin/bash", "-c"]

RUN <<-'EOL'
	# Update System Immediately
	( sudo pacman -Syu --noconfirm 2>/dev/null ) || ( sudo pacman -Syu --noconfirm 2>/dev/null || true )
	( sudo rm -rvf /var/cache/pacman/pkg/*.pkg.tar.zst* 2>/dev/null || true )
	# Fix pacman-key
	pacman-key --init && pacman-key --populate archlinux
	# Add "app" user with "sudo" access
	useradd -G wheel -m -s /bin/bash app
	echo -e "\n%wheel ALL=(ALL:ALL) NOPASSWD: ALL\napp   ALL=(ALL:ALL) NOPASSWD: ALL\n" | sudo tee -a /etc/sudoers
EOL

USER app

WORKDIR /tmp

RUN <<-'EOL'
	set -ex
	export PATH="/usr/local/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin:/bin"
	echo -e "[+] List of PreInstalled Packages:"
	echo -e "$(sudo pacman -Q | awk '{print $1}' | sed -z 's/\n/ /g;s/\s$/\n/g')" 2>/dev/null
	sudo pacman -Syu --noconfirm && sudo pacman -S --noconfirm --needed pacman-contrib pacutils
	echo -e "[+] Installing yay & paru (pacman helpers)"
	# Direct Download from CachyOS
	for pachelper in yay-12.5.7-1-x86_64.pkg.tar.zst paru-2.1.0-2-x86_64.pkg.tar.zst; do
	  curl -sLO "https://mirror.cachyos.org/repo/x86_64/cachyos/${pachelper}"
	done
	sudo pacman -U --noconfirm /tmp/*.pkg.tar.zst
	# for app in yay-bin paru-bin; do
	  # git clone -q https://aur.archlinux.org/${app}.git
	  # cd ./${app} && makepkg -si --noconfirm --noprogressbar --clean --needed
	  # cd .. && rm -rf -- ./${app}
	# done
	# sudo pacman -S --noconfirm --needed patchelf
	# sudo patchelf --replace-needed libalpm.so.15 libalpm.so.16 "$(which paru)"
	# ( sudo pacman -Rdd git --noconfirm 2>/dev/null || true )
	( sudo rm -rvf /tmp/* /var/lib/pacman/sync/* /var/cache/pacman/pkg/* /home/app/.cache/yay/* /home/app/.cache/paru/* 2>/dev/null || true )
EOL


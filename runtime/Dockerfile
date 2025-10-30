# syntax=docker/dockerfile:1-labs
FROM --platform=$BUILDPLATFORM fr3akyphantom/vapoursynth-av1an-base:latest

ARG TARGETPLATFORM
ARG BUILDPLATFORM

# USER app

# WORKDIR /tmp

# SHELL ["/bin/bash", "-c"]

RUN --mount=type=secret,id=RCLONE_CONFIG_HASH,uid=1000 <<-'EOL'
	echo -e "TARGETPLATFORM=${TARGETPLATFORM} and BUILDPLATFORM=${BUILDPLATFORM}"
	# Update System Immediately
	( sudo pacman -Syu --noconfirm 2>/dev/null ) || ( sudo pacman -Syu --noconfirm 2>/dev/null || true )
	( sudo rm -rvf /var/cache/pacman/pkg/*.pkg.tar.zst* 2>/dev/null || true )
	set -ex
	export PATH="/usr/local/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin:/bin"
	echo -e "[+] List of PreInstalled Packages:"
	echo -e "$(sudo pacman -Q | awk '{print $1}' | sed -z 's/\n/ /g;s/\s$/\n/g')" 2>/dev/null
	sudo pacman -S --noconfirm --needed git unzip
	echo -e "[+] List of Packages Before Actual Operation:"
	echo -e "$(sudo pacman -Q | awk '{print $1}' | sed -z 's/\n/ /g;s/\s$/\n/g')" 2>/dev/null
	export PARU_OPTS="--skipreview --noprovides --useask --combinedupgrade --batchinstall --noinstalldebug --removemake --cleanafter --nokeepsrc"
	echo -e "[+] Build Tools PreInstallation"
	paru -S --noconfirm --needed ${PARU_OPTS} cmake ninja clang yasm meson compiler-rt jq rust cargo-c libgit2 zip p7zip python-pip python-utils
	paru -S --noconfirm --needed ${PARU_OPTS} rclone
	# Setup personal rclone config, again
	export RCLONE_CONFIG_HASH=$(< /run/secrets/RCLONE_CONFIG_HASH) || true
	mkdir -p ~/.config/rclone
	curl -sL --retry 5 --retry-connrefused "https://gist.github.com/rokibhasansagar/${RCLONE_CONFIG_HASH}" >./rcl.log
	curl -sL --retry 5 --retry-connrefused "https://gist.github.com/rokibhasansagar/${RCLONE_CONFIG_HASH}/$(grep -m1 -o "archive/.*.zip" ./rcl.log)" -O
	unzip -j *.zip && cat *.rclone.config >~/.config/rclone/rclone.conf
	rm *.zip ./rcl.log *.rclone.config
	export PARU_OPTS="--skipreview --noprovides --useask --combinedupgrade --batchinstall --noinstalldebug --removemake --nocleanafter --nokeepsrc"
	echo -e "[+] List of Packages Before Installing Dependency Apps:"
	echo -e "$(sudo pacman -Q | awk '{print $1}' | sed -z 's/\n/ /g;s/\s$/\n/g')" 2>/dev/null
	mkdir -p /home/app/.cache/paru/clone 2>/dev/null
	git clone -q --filter=blob:none https://github.com/rokibhasansagar/Arch_PKGBUILDs.git /home/app/.cache/paru/pkgbuilds/
	rm -rf /home/app/.cache/paru/pkgbuilds/.git
	_custPKGBuilder() {
	  for pkg in "${pkgs[@]}"; do
	    echo -e "[+] ${pkg} Build+Installation with makepkg"
	    cd /home/app/.cache/paru/pkgbuilds/${pkg}/
	    ( paru -Ui --noconfirm --needed ${PARU_OPTS} --mflags="--force" --rebuild )
	  done
	}
	_uninstPKG() {
	  for pkg in "${unpkgs[@]}"; do
	    ( sudo pacman -Rdd ${pkg} --noconfirm 2>/dev/null ) || true
	  done
	}
	echo -e "[%] nasm hack"
	export pkgs=(nasm) && _custPKGBuilder
	sudo sed -i '/^#IgnorePkg/c\IgnorePkg = nasm' /etc/pacman.conf 2>/dev/null
	echo -e "[+] vapoursynth-git, ffmpeg and other tools Installation with pacman"
	export unpkgs=(zimg) && _uninstPKG
	export pkgs=({zimg,libdovi,libhdr10plus-rs}-git) && _custPKGBuilder
	paru -S --noconfirm --needed ${PARU_OPTS} ffmpeg ffms2 mkvtoolnix-cli numactl
	export unpkgs=(libjxl) && _uninstPKG
	export pkgs=(libjxl-metrics-git) && _custPKGBuilder
	export unpkgs=(vapoursynth aom) && _uninstPKG
	export pkgs=({aom-psy101,vapoursynth,foosynth-plugin-lsmashsource}-git) && _custPKGBuilder
	export pythondir=$(python -c "import os;print(os.path.dirname(os.__file__))")
	libtool --finish /usr/lib &>/dev/null
	libtool --finish ${pythondir}/site-packages &>/dev/null
	sudo ldconfig 2>/dev/null
	echo -e "[-] Removing x265, svt-av1 in order to install latest version"
	export unpkgs=(x265 svt-av1) && _uninstPKG
	sudo ldconfig 2>/dev/null
	export pkgs=({x265,svt-av1-psy}-git) && _custPKGBuilder
	echo -e "[+] List of All Packages After Base Installation:"
	echo -e "$(sudo pacman -Q | awk '{print $1}' | sed -z 's/\n/ /g;s/\s$/\n/g')" 2>/dev/null
	echo -e "[>] PacCache Investigation"
	sudo du -sh /var/cache/pacman/pkg /home/app/.cache/paru/*
	ls -lAog /var/cache/pacman/pkg/*.pkg.tar.zst 2>/dev/null
	echo -e "[+] Plugins Installation Block Starts Here"
	# vsakarin can now use Arch llvm(21)-libs
	export pkgs=(vapoursynth-plugin-{vsakarin,adjust,adaptivegrain}-git) && _custPKGBuilder
	export pkgs=({vapoursynth-plugin-,}waifu2x-ncnn-vulkan-git) && _custPKGBuilder
	# export silentFlags='-Wno-unused-parameter -Wno-deprecated-declarations -Wno-unknown-pragmas -Wno-implicit-fallthrough'
	# CFLAGS+=" ${silentFlags}" CXXFLAGS+=" ${silentFlags}"
	cd /tmp && paru -S --noconfirm --needed ${PARU_OPTS} onetbb vapoursynth-tools-getnative-git vapoursynth-plugin-{bestsource,bm3dcuda-cpu,eedi3m,havsfunc,imwri,kagefunc,knlmeanscl,muvsfunc,mvtools_sf,neo_f3kdb,neo_fft3dfilter,nlm,retinex,soifunc,ttempsmooth,vsdeband,vsdehalo,vsmasktools,vspyplugin,vstools,d2vsource,vssource,znedi3,resize2}-git vapoursynth-plugin-dgdecodenv-bin && sudo pacman -Rdd nvidia-utils --noconfirm 2>/dev/null && paru -S --noconfirm --needed ${PARU_OPTS} vulkan-swrast
	libtool --finish /usr/lib/vapoursynth &>/dev/null
	sudo ldconfig 2>/dev/null
	# vszip uses zig-bin (v0.15.2 from Custom AUR)
	export pkgs=(zig-bin vapoursynth-plugin-{bmdegrain,wnnm,julek,vszip}-git av1an-git) && _custPKGBuilder
	libtool --finish /usr/lib/vapoursynth &>/dev/null
	sudo ldconfig 2>/dev/null
	export XDG_RUNTIME_DIR=/run/user/$UID
	echo -e "[i] Encoder and Av1an Investigation"
	( ffmpeg -hide_banner -version || true )
	( x265 -V 2>&1 || true )
	( aomenc --help | grep "AOMedia Project AV1 Encoder" || true )
	( vspipe --version || true )
	( rav1e --version || true )
	( av1an --version || true )
	( SvtAv1EncApp --version || true )
	echo -e "[>] PostPlugs PacCache Investigation"
	set +ex
	case "${TARGETPLATFORM}" in
	  "linux/amd64/v2") export rclarch="x86-64-v2" ;;
	  "linux/amd64/v3") export rclarch="x86-64-v3" ;;
	  *) export rclarch="native" ;;
	esac
	if [[ ${rclarch} == "native" ]]; then
	  # find /tmp /home/app/.cache/paru/ -maxdepth 3 -type f -name "*.pkg.tar.zst" | xargs -i sudo cp -vf {} /var/cache/pacman/pkg/
	  find /tmp /home/app/.cache/paru/ -maxdepth 3 -type f -name "*.pkg.tar.zst" | while read -r i; do curl -s -F"file=@${i}" https://temp.sh/upload && echo; done
	fi
	set -ex
	sudo du -sh /var/cache/pacman/pkg
	ls -lAog /home/app/.cache/paru/pkgbuilds/*/*.pkg.tar.zst /var/cache/pacman/pkg/*.pkg.tar.zst
	(
	  mkdir -p /tmp/pkgs
	  ( rclone purge "ms365:Public/ArchVapourBuilds/${rclarch}/Step_Zero2/" --fast-list --retries=1 2>/dev/null ) || true
	  find /home/app/.cache/paru/pkgbuilds/ -depth -type f -name "*.pkg.tar.zst" | xargs -i sudo mv -vf {} /tmp/pkgs/
	  rclone copy /tmp/pkgs/ --include="*.pkg.tar.zst" "ms365:Public/ArchVapourBuilds/${rclarch}/Step_Zero2/" --fast-list -v 2>/dev/null && rm /tmp/pkgs/*
	  ( rclone purge "ms365:Public/ArchVapourBuilds/${rclarch}/Step_Zero3/" --fast-list --retries=1 2>/dev/null ) || true
	  find /home/app/.cache/paru/clone/ -depth -type f -name "*.pkg.tar.zst" | xargs -i sudo mv -vf {} /tmp/pkgs/
	  rclone copy /tmp/pkgs/ --include="*.pkg.tar.zst" "ms365:Public/ArchVapourBuilds/${rclarch}/Step_Zero3/" --fast-list -v 2>/dev/null && rm /tmp/pkgs/*
	  ( rclone purge "ms365:Public/ArchVapourBuilds/${rclarch}/Step_Zero4/" --fast-list --retries=1 2>/dev/null ) || true
	  find /var/cache/pacman/pkg/ -depth -type f -name "*.pkg.tar.zst" | xargs -i sudo mv -vf {} /tmp/pkgs/
	  rclone copy /tmp/pkgs/ --include="*.pkg.tar.zst" "ms365:Public/ArchVapourBuilds/${rclarch}/Step_Zero4/" --fast-list -v 2>/dev/null && rm /tmp/pkgs/*
	  sudo rm ~/.config/rclone/rclone.conf
	  sudo pacman -Rdd rclone --noconfirm 2>/dev/null
	) || true
	set +ex
	echo -e "[>] PostPlugs ParuCache Investigation"
	sudo du -sh /home/app/.cache/zig /home/app/.cache/paru/*/*
	echo -e "[i] All Installed AppList:"
	echo -e "$(sudo pacman -Q | awk '{print $1}' | grep -v 'vapoursynth-' | sed -z 's/\n/ /g;s/\s$/\n/g')" 2>/dev/null
	echo -e "[i] All Installed Vapoursynth Plugins:"
	echo -e "$(sudo pacman -Q | awk '{print $1}' | grep 'vapoursynth-' | sed -z 's/\n/ /g;s/\s$/\n/g')" 2>/dev/null
	set -ex
	ls -lAog /usr/lib/vapoursynth/*.so 2>/dev/null
	echo -e "[i] Home directory Investigation"
	sudo du -sh ~/\.[a-z]* 2>/dev/null
	echo -e "[<] Cleanup"
	find "${pythondir}" -depth -type d -name __pycache__ -exec sudo rm -rf '{}' + 2>/dev/null  # /usr/share/
	( sudo pacman -Rdd cmake ninja clang yasm meson rust cargo-c compiler-rt --noconfirm 2>/dev/null || true )
	sudo rm -rf /tmp/* /var/cache/pacman/pkg/* /home/app/.cache/zig/* /home/app/.cache/yay/* /home/app/.cache/paru/{clone,pkgbuilds}/* /home/app/.cargo/* 2>/dev/null
	echo -e "[+] List of All Packages At The End Of All Process:"
	echo -e "$(sudo pacman -Q | awk '{print $1}' | sed -z 's/\n/ /g;s/\s$/\n/g')" 2>/dev/null
EOL

VOLUME ["/videos"]
WORKDIR /videos

ENTRYPOINT [ "/usr/bin/bash" ]


# syntax=docker/dockerfile:1.5
FROM archlinux:base-devel

# USER root

SHELL ["/bin/bash", "-c"]

# Add "app" user with "sudo" access
RUN <<-'EOL'
	pacman-key --init
	pacman-key --populate archlinux
	useradd -m -G wheel -s /bin/bash app
	sed -i 's/# %wheel ALL=(ALL:ALL) NOPASSWD: ALL/%wheel ALL=(ALL:ALL) NOPASSWD: ALL/' /etc/sudoers
	sed -i 's/# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers
EOL

USER app

WORKDIR /tmp

# Update pacman database and install yay and paru helpers
RUN <<-'EOL'
	set -ex
	sudo pacman -Syu --noconfirm 2>/dev/null
	export PATH="/usr/local/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin:/bin"
	echo -e "[+] List of PreInstalled Packages:"
	echo -e "$(sudo pacman -Q | awk '{print $1}' | sed -z 's/\n/ /g;s/\s$/\n/g')" 2>/dev/null
	sudo pacman -Syu --noconfirm && sudo pacman -S --noconfirm --needed git pacman-contrib
	echo -e "[+] Installing yay-bin & paru-bin (pacman helpers)"
	for app in yay-bin paru-bin; do
	  git clone -q https://aur.archlinux.org/${app}.git
	  cd ./${app} && makepkg -si --noconfirm --noprogressbar --clean --needed
	  cd .. && rm -rf -- ./${app}
	done
	echo -e "[+] List of Packages Before Actual Operation:"
	echo -e "$(sudo pacman -Q | awk '{print $1}' | sed -z 's/\n/ /g;s/\s$/\n/g')" 2>/dev/null
	export PARU_OPTS="--skipreview --noprovides --removemake --cleanafter --useask --combinedupgrade --batchinstall --nokeepsrc --noinstalldebug"
	mkdir -p /home/app/.cache/paru/clone 2>/dev/null
	echo -e "[+] Build Tools PreInstallation"
	paru -S --noconfirm --needed ${PARU_OPTS} cmake ninja clang nasm yasm compiler-rt jq zig-dev-bin rust cargo-c libgit2 zip unzip p7zip python-pip
	echo -e "[+] List of Packages Before Installing Dependency Apps:"
	echo -e "$(sudo pacman -Q | awk '{print $1}' | sed -z 's/\n/ /g;s/\s$/\n/g')" 2>/dev/null
	export custPKGRootHash="46d764782ad15bbf546ad694cc820b45"
	export custPKGRootRev=$(git ls-remote -q "https://gist.github.com/rokibhasansagar/${custPKGRootHash}" HEAD | awk '{print $1}')
	export custPKGRootAddr="https://gist.github.com/rokibhasansagar/${custPKGRootHash}/raw/${custPKGRootRev}"
	echo -e "[+] vapoursynth-git, ffmpeg and other tools Installation with pacman"
	( sudo pacman -Rdd zimg --noconfirm 2>/dev/null || true )
	cd /home/app/.cache/paru/clone/ && paru --getpkgbuild zimg-git
	sed -i "/'zimg'/d" zimg-git/PKGBUILD
	cd ./zimg-git && paru -Ui --noconfirm --needed ${PARU_OPTS} --rebuild && cd ..
	paru -S --noconfirm --needed ${PARU_OPTS} ffmpeg ffms2 mkvtoolnix-cli numactl
	( sudo pacman -Rdd vapoursynth highway libjxl --noconfirm 2>/dev/null || true )
	echo -e "[+] highway-git Installation with makepkg"
	cd /home/app/.cache/paru/clone/ && paru --getpkgbuild highway-git
	curl -sL "${custPKGRootAddr}/highway-git.PKGBUILD" | sed '1d' >highway-git/PKGBUILD
	cd ./highway-git && paru -Ui --noconfirm --needed ${PARU_OPTS} --mflags="--force" --rebuild && cd ..
	echo -e "[+] libjxl-metrics-git Installation with makepkg"
	cd /home/app/.cache/paru/clone/ && paru --getpkgbuild libjxl-metrics-git
	curl -sL "${custPKGRootAddr}/libjxl-metrics-git.PKGBUILD" | sed '1d' >libjxl-metrics-git/PKGBUILD
	cd ./libjxl-metrics-git && paru -Ui --noconfirm --needed ${PARU_OPTS} --mflags="--force" --rebuild && cd ..
	( sudo pacman -Rdd aom --noconfirm 2>/dev/null || true )
	echo -e "[+] aom-psy101-git Installation with makepkg"
	cd /home/app/.cache/paru/clone/ && mkdir -p aom-psy101-git
	curl -sL "${custPKGRootAddr}/aom-psy101-git.PKGBUILD" | sed '1d' >aom-psy101-git/PKGBUILD
	cd ./aom-psy101-git && paru -Ui --noconfirm --needed ${PARU_OPTS} --mflags="--force" --rebuild && cd ..
	cd /home/app/.cache/paru/clone/ && paru --getpkgbuild vapoursynth-git
	sed -i 's|git+https://github.com/vapoursynth/vapoursynth.git|git+https://github.com/vapoursynth/vapoursynth.git#commit=976f022|g' vapoursynth-git/PKGBUILD
	cd ./vapoursynth-git && paru -Ui --noconfirm --needed ${PARU_OPTS} --mflags="--force" --rebuild && cd ..
	paru -S --noconfirm --needed ${PARU_OPTS} vapoursynth-plugin-lsmashsource-git
	sudo ldconfig 2>/dev/null
	libtool --finish /usr/lib &>/dev/null && libtool --finish /usr/lib/python3.11/site-packages &>/dev/null
	( vspipe --version || true )
	echo -e "[-] Removing x265, svt-av1 & rav1e in order to install latest version"
	( sudo pacman -Rdd x265 svt-av1 rav1e --noconfirm 2>/dev/null || true )
	echo -e "[+] rav1e-git Installation with makepkg"
	cd /home/app/.cache/paru/clone/ && paru --getpkgbuild rav1e-git
	curl -sL "${custPKGRootAddr}/rav1e-git.PKGBUILD" | sed '1d' >rav1e-git/PKGBUILD
	cd ./rav1e-git && paru -Ui --noconfirm --needed ${PARU_OPTS} --mflags="--force" --rebuild && cd ..
	sudo ldconfig 2>/dev/null
	echo -e "[+] x265-git Installation with makepkg"
	cd /home/app/.cache/paru/clone/ && paru --getpkgbuild x265-git
	curl -sL "${custPKGRootAddr}/x265-git.PKGBUILD" | sed '1d' >x265-git/PKGBUILD
	cd ./x265-git && paru -Ui --noconfirm --needed ${PARU_OPTS} --mflags="--force" --rebuild && cd ..
	echo -e "[+] svt-av1-psy-git Installation with makepkg"
	cd /home/app/.cache/paru/clone/ && mkdir -p svt-av1-psy-git
	curl -sL "${custPKGRootAddr}/svt-av1-psy-git.PKGBUILD" | sed '1d' >svt-av1-psy-git/PKGBUILD
	cd ./svt-av1-psy-git && paru -Ui --noconfirm --needed ${PARU_OPTS} --mflags="--force" --rebuild && cd ..
	echo -e "[i] ffmpeg version check"
	( ffmpeg -hide_banner -version || true )
	echo -e "[-] /tmp directory cleanup"
	cd /tmp && rm -rf -- *
	echo -e "[+] List of All Packages After Base Installation:"
	echo -e "$(sudo pacman -Q | awk '{print $1}' | sed -z 's/\n/ /g;s/\s$/\n/g')" 2>/dev/null
	echo -e "[>] PacCache Investigation"
	sudo du -sh /var/cache/pacman/pkg
	ls -lAog /var/cache/pacman/pkg/*.pkg.tar.zst 2>/dev/null
	echo -e "[+] Plugins Installation Block Starts Here"
	cd /tmp && CFLAGS+=' -Wno-unused-parameter -Wno-deprecated-declarations -Wno-unknown-pragmas -Wno-implicit-fallthrough' CXXFLAGS+=' -Wno-unused-parameter -Wno-deprecated-declarations -Wno-unknown-pragmas -Wno-implicit-fallthrough' paru -S --noconfirm --needed ${PARU_OPTS} onetbb vapoursynth-plugin-muvsfunc-git vapoursynth-plugin-vstools-git vapoursynth-plugin-imwri-git vapoursynth-plugin-vsdehalo-git vapoursynth-plugin-vsdeband-git vapoursynth-plugin-neo_f3kdb-git vapoursynth-plugin-neo_fft3dfilter-git vapoursynth-plugin-havsfunc-git vapoursynth-tools-getnative-git vapoursynth-plugin-vspyplugin-git vapoursynth-plugin-vsmasktools-git vapoursynth-plugin-bm3dcuda-cpu-git vapoursynth-plugin-knlmeanscl-git vapoursynth-plugin-nlm-git vapoursynth-plugin-retinex-git vapoursynth-plugin-eedi3m-git vapoursynth-plugin-znedi3-git vapoursynth-plugin-ttempsmooth-git vapoursynth-plugin-mvtools_sf-git vapoursynth-plugin-soifunc-git
	( sudo pacman -Rdd vapoursynth-plugin-vsakarin-git --noconfirm 2>/dev/null || true )
	cd /home/app/.cache/paru/clone/ && paru --getpkgbuild vapoursynth-plugin-vsakarin-git
	sed -i -e '/prepare()/a\  sed -i "152,154d" ${_plug}/expr2/reactor/LLVMJIT.cpp && if grep -q "\-x86-asm-syntax=intel" ${_plug}/expr2/reactor/LLVMJIT.cpp; then echo "VSAkarin Patch Failed"; fi' vapoursynth-plugin-vsakarin-git/PKGBUILD
	cd ./vapoursynth-plugin-vsakarin-git && paru -Ui --noconfirm --needed ${PARU_OPTS} --mflags="--force" --rebuild && cd ..
	libtool --finish /usr/lib/vapoursynth &>/dev/null
	sudo ldconfig 2>/dev/null
	echo -e "[+] vapoursynth-plugin-{bmdegrain,wnnm}-git Installation with makepkg"
	export custPlugPKGHash="560defd34555c9f7652523377e96adff"
	export custPlugPKGRev=$(git ls-remote -q "https://gist.github.com/rokibhasansagar/${custPlugPKGHash}" HEAD | awk '{print $1}')
	export custPlugPKGAddr="https://gist.github.com/rokibhasansagar/${custPlugPKGHash}/raw/${custPlugPKGRev}"
	cd /home/app/.cache/paru/clone/ && mkdir -p vapoursynth-plugin-bmdegrain-git
	curl -sL "${custPlugPKGAddr}/vapoursynth-plugin-bmdegrain-git.PKGBUILD" | sed '1d' >vapoursynth-plugin-bmdegrain-git/PKGBUILD
	cd ./vapoursynth-plugin-bmdegrain-git && paru -Ui --noconfirm --needed ${PARU_OPTS} --mflags="--force" --rebuild && cd ..
	cd /home/app/.cache/paru/clone/ && mkdir -p vapoursynth-plugin-wnnm-git
	curl -sL "${custPlugPKGAddr}/vapoursynth-plugin-wnnm-git.PKGBUILD" | sed '1d' >vapoursynth-plugin-wnnm-git/PKGBUILD
	cd ./vapoursynth-plugin-wnnm-git && paru -Ui --noconfirm --needed ${PARU_OPTS} --mflags="--force" --rebuild && cd ..
	echo -e "[+] Install {libjulek,libssimulacra2}.so"
	cd /home/app/.cache/paru/clone/
	git clone --filter=blob:none https://github.com/dnjulek/vapoursynth-ssimulacra2
	cd vapoursynth-ssimulacra2
	zig build -Doptimize=ReleaseFast
	sudo chmod 755 zig-out/lib/libssimulacra2.so
	sudo cp -a -v zig-out/lib/libssimulacra2.so /usr/lib/vapoursynth/
	cd /home/app/.cache/paru/clone/
	git clone --filter=blob:none --recurse-submodules --shallow-submodules https://github.com/dnjulek/vapoursynth-julek-plugin
	cd vapoursynth-julek-plugin/thirdparty
	mkdir libjxl_build && cd libjxl_build
	cmake -C ../libjxl_cache.cmake -DCMAKE_CXX_COMPILER=clang++ -DCMAKE_C_COMPILER=clang -G Ninja ../libjxl
	cmake --build . && cmake --install .
	cd ../..
	cmake -B build -DCMAKE_CXX_COMPILER=clang++ -DCMAKE_BUILD_TYPE=Release -G Ninja
	cmake --build build
	sudo cmake --install build
	libtool --finish /usr/lib/vapoursynth &>/dev/null
	sudo ldconfig 2>/dev/null
	echo -e "[+] av1an-git Installation with makepkg"
	cd /home/app/.cache/paru/clone/ && paru --getpkgbuild av1an-git
	curl -sL "${custPKGRootAddr}/av1an-git.PKGBUILD" | sed '1d' >av1an-git/PKGBUILD
	cd ./av1an-git && paru -Ui --noconfirm --needed ${PARU_OPTS} --mflags="--force" --rebuild && cd ..
	echo -e "[i] Encoder and Av1an Investigation"
	rav1e --version
	av1an --version
	SvtAv1EncApp --version
	echo -e "[>] PostPlugs PacCache Investigation"
	find /home/app/.cache/paru/clone/ -maxdepth 4 -iname *."pkg.tar.zst"* -type f | xargs -i sudo cp -vf {} /var/cache/pacman/pkg/
	sudo du -sh /var/cache/pacman/pkg
	ls -lAog /var/cache/pacman/pkg/*.pkg.tar.zst
	echo -e "[>] PostPlugs ParuCache Investigation"
	sudo du -sh /home/app/.cache/paru/* /home/app/.cache/paru/clone/*
	echo -e "[i] All Installed AppList:"
	echo -e "$(sudo pacman -Q | awk '{print $1}' | grep -v 'vapoursynth-' | sed -z 's/\n/ /g;s/\s$/\n/g')" 2>/dev/null
	echo -e "[i] All Installed Vapoursynth Plugins:"
	echo -e "$(sudo pacman -Q | awk '{print $1}' | grep 'vapoursynth-' | sed -z 's/\n/ /g;s/\s$/\n/g')" 2>/dev/null
	ls -lAog /usr/lib/vapoursynth/*.so 2>/dev/null
	echo -e "[i] Home directory Investigation"
	sudo du -sh ~/\.[a-z]* 2>/dev/null
	echo -e "[<] Cleanup"
	find "$(python -c "import os;print(os.path.dirname(os.__file__))")" -depth -type d -name __pycache__ -exec sudo rm -rf '{}' + 2>/dev/null
	( sudo pacman -Rdd cmake ninja clang nasm yasm rust cargo-c compiler-rt zig-dev-bin --noconfirm 2>/dev/null || true )
	sudo rm -rf /tmp/* /var/cache/pacman/pkg/* /home/app/.cache/yay/* /home/app/.cache/paru/* /home/app/.cargo/* 2>/dev/null
EOL

VOLUME ["/videos"]
WORKDIR /videos

ENTRYPOINT [ "/usr/bin/bash" ]


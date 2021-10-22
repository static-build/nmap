
prepare(){
    if [ -d code ]; then
        echo "Already exists"
        git subtree pull --prefix code https://github.com/bootandy/dust.git master --squash
    else
        git subtree add --prefix code https://github.com/bootandy/dust.git master --squash
    fi
}

# apt-get install mingw-w64
# apt install gcc

build_win(){
    (
        cd code
        cross build --target x86_64-pc-windows-gnu --release
    )
    cp code/target/x86_64-pc-windows-gnu/release/dust.exe bin/dust.x64.exe
    (
        cd bin
        # xrc 7z
        # 7z a dust.x64.exe.7z dust.x64.exe
        # rm dust.x64.exe
    )
}

build_main(){

    local rust_target=${1:?rust_target}
    local target_name=${2:?binary}
    local exe=${3:-dust}

    echo "Building $rust_target with $target_name"

    [ -f "bin/$target_name.7z" ] && return 0

    (
        cd code && {
            cross build --target "$rust_target" --release
        }
    ) && {
        cp "code/target/$rust_target/release/$exe" "bin/$target_name" && (
            cd bin && {
                xrc 7z
                7z a "$target_name.7z" "$target_name"
                rm "$target_name"
            }
        )
    }
}

build_linux_x64(){
    build_main x86_64-unknown-linux-musl dust.linux.x64
}

build_linux_arm64(){
    build_main aarch64-unknown-linux-musl dust.linux.arm64
}

build_linux_armv7hf(){
    build_main armv7-unknown-linux-musleabihf dust.linux.armv7hf
}

build_linux_armv7(){
    build_main armv7-unknown-linux-musleabi dust.linux.armv7
}

main(){
    build_linux_x64
    build_linux_arm64
    # build_linux_armv7
    build_linux_armv7hf

    build_main aarch64-apple-darwin dust.darwin.arm64
    build_main x86_64-apple-darwin dust.darwin.x64

    build_main x86_64-pc-windows-gnu dust.x64.exe dust.exe
}

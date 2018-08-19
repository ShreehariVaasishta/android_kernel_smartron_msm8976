export CROSS_COMPILE="/home/gary/aarch64-linux-android-4.9/bin/aarch64-linux-android-"
export ARCH=arm64 && export SUBARCH=arm64
export KBUILD_BUILD_HOST="ZERO_ADDITION_V-1.0"
export KBUILD_BUILD_USER="shreehari"


mkdir -p out
make O=out clean
make O=out mrproper
make O=out msm-perf_defconfig
make O=out -j$(nproc --all)

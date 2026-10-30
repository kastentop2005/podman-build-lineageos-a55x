FROM debian:trixie-slim

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive \
    USER=build \
    ANDROID_BUILD_TOP=/home/build/lineageos-a55x \
    PATH="/home/build/bin:${PATH}" \
    USE_CCACHE=1 \
    CCACHE_DIR=/home/build/.ccache \
    CCACHE_EXEC=/usr/bin/ccache

# Install dependencies
RUN apt-get update && apt-get install -y \
    bc \
    bison \
    build-essential \
    ccache \
    curl \
    flex \
    g++-multilib \
    gcc-multilib \
    git \
    git-lfs \
    gnupg \
    gperf \
    imagemagick \
    lib32ncurses-dev \
    lib32readline-dev \
    lib32z1-dev \
    libelf-dev \
    liblz4-dev \
    libncurses6 \
    libsdl1.2-dev \
    libssl-dev \
    libxml2 \
    libxml2-utils \
    lzop \
    pngcrush \
    rsync \
    schedtool \
    squashfs-tools \
    sudo \
    xsltproc \
    zip \
    zlib1g-dev \
    openjdk-21-jdk \
    python3 \
    python3-pip \
    wget \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Create build user
RUN useradd -m -s /bin/bash build && \
    echo "build ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Install repo tool into the build user's ~/bin
RUN mkdir -p /home/build/bin && \
    curl -fsSL https://storage.googleapis.com/git-repo-downloads/repo \
        -o /home/build/bin/repo && \
    chmod a+x /home/build/bin/repo && \
    chown -R build:build /home/build/bin

# Switch to build user
USER build
WORKDIR /home/build

# Make ~/bin available for interactive bash sessions
RUN printf '%s\n' \
      'if [ -d "$HOME/bin" ] ; then' \
      '    PATH="$HOME/bin:$PATH"' \
      'fi' >> ~/.bashrc

# Configure git and git-lfs
RUN git config --global user.email "builder@lineageos.local" && \
    git config --global user.name "LineageOS Builder" && \
    git config --global color.ui false && \
    git config --global trailer.changeid.key "Change-Id" && \
    git lfs install

# (Optional) Set up ccache
# RUN mkdir -p /home/build/.ccache && \
#    ccache --set-config=max_size=50G && \
#    ccache --set-config=compression=true && \
#    ccache --set-config=compression_level=3 && \
#    ccache -s

# Initialize LineageOS repository
# NOTE: repo sync of LineageOS is ~250+ GB. Doing it in a RUN layer
# creates a HUGE container image. Prefer running these commands at container runtime,
# or mount a volume for ${ANDROID_BUILD_TOP} instead. Kept here as an option.
# Uncomment if you want
# RUN mkdir -p ${ANDROID_BUILD_TOP} && \
#    cd ${ANDROID_BUILD_TOP} && \
#    repo init -u https://github.com/LineageOS/android.git -b lineage-24.0 --git-lfs && \
#    repo sync -c -j$(nproc) --force-sync --no-clone-bundle --no-tags

# Set up build environment
WORKDIR ${ANDROID_BUILD_TOP}

# Build command (kept here for convinience, use at runtime)
# RUN source build/envsetup.sh && \
#     breakfast lineage_a55x-cp2a-userdebug && \
#     brunch lineage_a55x-cp2a-userdebug

CMD ["/bin/bash"]

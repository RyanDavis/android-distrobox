# syntax=docker/dockerfile:1
FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    openjdk-17-jdk \
    wget unzip git curl cmake ninja-build \
    libglu1-mesa \
    libx11-6 libxext6 libxrender1 libxtst6 libxi6 libfreetype6 libfontconfig1 libxrandr2 \
    usbutils \
    gradle \
    locales \
    gnupg \
    software-properties-common \
    sudo \
    && rm -rf /var/lib/apt/lists/*

RUN locale-gen en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8

# See https://developer.android.com/studio for latest Android Studio Version
# ARG ANDROID_STUDIO_VERSION=2023.3.1.18
ARG ANDROID_STUDIO_VERSION=2025.1.4.8 
ENV ANDROID_HOME=/opt/android-sdk
ENV ANDROID_STUDIO_HOME=/opt/android-studio
ENV PATH="$PATH:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools:$ANDROID_HOME/emulator:$ANDROID_STUDIO_HOME/bin"

RUN mkdir -p $ANDROID_HOME/cmdline-tools \
    && cd /tmp \
    && wget https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip \
    && unzip commandlinetools-linux-*.zip -d $ANDROID_HOME/cmdline-tools \
    && mv $ANDROID_HOME/cmdline-tools/cmdline-tools $ANDROID_HOME/cmdline-tools/latest \
    && rm commandlinetools-linux-*.zip

RUN yes | $ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager --licenses

RUN $ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager \
    "platform-tools" \
    "platforms;android-34" \
    "build-tools;34.0.0" \
    "ndk;25.2.9519653" \
    "cmake;3.22.1"

# Android Studio installation
RUN cd /tmp && \
    wget https://dl.google.com/dl/android/studio/ide-zips/${ANDROID_STUDIO_VERSION}/android-studio-${ANDROID_STUDIO_VERSION}-linux.tar.gz -O android-studio.tar.gz && \
    tar -xzf android-studio.tar.gz -C /opt/ && \
    ln -s /opt/android-studio/bin/studio.sh /usr/local/bin/studio && \
    rm android-studio.tar.gz

# Bazel installation
RUN curl -fsSL https://bazel.build/bazel-release.pub.gpg | gpg --dearmor > bazel.gpg \
    && mv bazel.gpg /usr/share/keyrings/bazel-archive-keyring.gpg \
    && echo "deb [arch=amd64 signed-by=/usr/share/keyrings/bazel-archive-keyring.gpg] https://storage.googleapis.com/bazel-apt stable jdk1.8" | tee /etc/apt/sources.list.d/bazel.list \
    && apt-get update && apt-get install -y bazel \
    && rm -rf /var/lib/apt/lists/*

ARG USERNAME=dev
ARG USER_UID=1000
ARG USER_GID=$USER_UID

RUN export DEBIAN_FRONTEND=noninteractive && \
    EXISTING_USER_NAME=$(getent passwd $USER_UID | cut -d: -f1 || true) && \
    EXISTING_GROUP_NAME=$(getent group $USER_GID | cut -d: -f1 || true) && \
    \
    if [ -n "$EXISTING_GROUP_NAME" ] && [ "$EXISTING_GROUP_NAME" != "$USERNAME" ]; then \
        groupmod -n $USERNAME $EXISTING_GROUP_NAME; \
    elif [ -z "$EXISTING_GROUP_NAME" ]; then \
        groupadd --gid $USER_GID $USERNAME; \
    fi && \
    \
    if [ -n "$EXISTING_USER_NAME" ] && [ "$EXISTING_USER_NAME" != "$USERNAME" ]; then \
        usermod -d /home/$USERNAME -m -l $USERNAME -g $USERNAME $EXISTING_USER_NAME; \
    elif [ -z "$EXISTING_USER_NAME" ]; then \
        useradd --uid $USER_UID --gid $USERNAME -m $USERNAME --shell /bin/bash; \
    fi && \
    \
    usermod -aG plugdev $USERNAME && \
    echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" | tee -a /etc/sudoers

USER $USERNAME
WORKDIR /home/$USERNAME

ENV PATH="$PATH:/opt/gradle/bin:$ANDROID_HOME/ndk/25.2.9519653"
ENV GRADLE_USER_HOME="/home/$USERNAME/.gradle"

RUN mkdir -p $GRADLE_USER_HOME && chmod -R 777 $GRADLE_USER_HOME

LABEL dev.containers.features="android,bazel"

CMD ["/bin/bash"]

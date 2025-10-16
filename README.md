# 🧭 Android Development Environment (Docker + Distrobox + VS Code)

This repository provides a **fully reproducible Android development environment** based on:

- 🐳 **Docker** — for reproducibility and CI/CD  
- 📦 **Distrobox** — for smooth local GUI and device integration  
- 🧰 **VS Code Remote Containers** — for lightweight IDE support  
- 🧱 **Android SDK + NDK + Gradle + Bazel** — pre-installed and ready to use.

---

## ✨ Features

- ✅ Android SDK / NDK pinned versions
- 🧰 Gradle and Bazel pre-installed
- 🧩 CMake and Ninja for native builds
- 🔌 ADB + USB passthrough support
- 🪟 Works with Wayland or X11 hosts
- 🐧 Non-root user matching host UID for volume compatibility
- 🚀 Compatible with VS Code Remote - Containers
- 🧪 Optional Android Studio GUI inside distrobox

---

## 🐳 1. Build the Docker Image

```bash
docker build -t android-dev:ndk25 .
```


## 📦 2. Create the Distrobox Environment

Run the helper script:

```bash
chmod +x distrobox-setup.sh
./distrobox-setup.sh
```

This will:
* Build the image if not present
* Create a distrobox container named android-dev
* Mount:
* * Your ~/Android SDK/NDK directory
* * The current project directory
* Forward USB for ADB access
* Drop you into a shell inside the environment


## 🧰 3. VS Code Remote Container Support

This repo includes a .devcontainer/devcontainer.json file.

#### Open the project in VS Code:

* Install “Remote - Containers” (or Dev Containers extension)
* Press F1 → Reopen in Container
* VS Code will mount your source and start the dev container with all tools pre-installed.

#### Installed extensions automatically:

* Android tooling
* C/C++ support
* Java support
* Gradle extension
* Python (optional)


## 🪄 4. GUI & ADB Device Access

Because Distrobox uses your user’s Wayland/X11 session:

* GUI apps like studio.sh (Android Studio) work out of the box.
* adb devices will work with your attached devices.

If needed, you can explicitly pass:

```bash
distrobox enter android-dev --additional-flags "--device /dev/bus/usb"
```

Make sure your user is in the plugdev group:

```bash
sudo usermod -aG plugdev $USER
```

## ⚡ 5. Gradle & Bazel Usage

Inside the container:

```bash
gradle build
bazel build //app:debug
```

Or through VS Code integrated terminal.
The environment already has GRADLE_USER_HOME configured to avoid permission issues.


## 🧪 6. Android Studio (Optional)

If you need full Android Studio:

```bash
distrobox enter android-dev
wget https://redirector.gvt1.com/edgedl/android/studio/ide-zips/2024.1.1.11/android-studio-2024.1.1.11-linux.tar.gz
tar -xf android-studio-*.tar.gz
~/android-studio/bin/studio.sh
```

## 🧭 7. CI/CD Integration

You can use the same android-dev:ndk25 image in:

* GitHub Actions
* GitLab CI
* Jenkins or other CI platforms

This guarantees your local and CI builds use the exact same toolchain.

## 🛠 Optional Volume Configuration

To avoid repeated SDK/NDK downloads:

* Mount ~/Android from the host → /opt/android-sdk
* Mount ~/.gradle for Gradle cache

Configured automatically in distrobox-setup.sh and .devcontainer/devcontainer.json.


## 🧭 8. File Overview

```bash
project/
 ├─ Dockerfile                     # Build the Android dev image
 ├─ distrobox-setup.sh             # Helper script for local dev shell
 ├─ .devcontainer/
 │   └─ devcontainer.json          # VS Code Remote Container config
 ├─ README.md                      # This file
 └─ app/                           # Your Android project
```

## 🧭 9. Quick Commands

| Task                           | Command                               |
|--------------------------------|---------------------------------------|
| Build image                    | `docker build -t android-dev:ndk25 .` |
| Create & enter distrobox shell | `./distrobox-setup.sh`                |
| Re-enter distrobox manually    | `distrobox enter android-dev`         |
| Open project in VS Code        | `code .` → “Reopen in Container”      |
| Check SDK / NDK                | `sdkmanager --list`                   |
| Build                          | `gradlew build`                       |
|    debug APK                   | `gradlew assembleDebug`               |
|    release APK                 | `gradlew assembleRelease`             |
| Build with Gradle              | `gradle build`                        |
| Build with Bazel               | `bazel build //:target`               |
| List ADB devices               | `adb devices`                         |
| Rebuild                        | `DBX_CONTAINER_MANAGER="docker" distrobox rm -f android-dev && docker build -t android-dev:ndk25 .` |

## ✅ Summary:

* Reproducible builds via Docker
* Seamless local dev via Distrobox
* Modern IDE support via VS Code Remote Containers
* Ready for both Gradle and Bazel based Android builds.

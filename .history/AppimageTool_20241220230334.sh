#!/bin/bash

# 函数：显示帮助信息
show_help() {
  echo "Usage: $0 [install|uninstall|info]"
  echo "  install    - Install an AppImage"
  echo "  uninstall  - Uninstall an AppImage"
  echo "  info       - Show information about installed AppImage"
  echo "  -h, --help - Display this help message"
  exit 1
}

# 函数：安装 AppImage
install_appimage() {
  # 获取用户输入
  read -p "Enter the AppImage URL: " APPIMAGE_URL
  read -p "Enter the AppImage file name (e.g., myapp.AppImage): " APPIMAGE_NAME
  read -p "Enter the installation directory (default: $HOME/Applications): " APPIMAGE_DIR
  APPIMAGE_DIR="${APPIMAGE_DIR:-$HOME/Applications}" # 如果用户没有输入，则使用默认目录

  # 创建目录（如果不存在）
  mkdir -p "$APPIMAGE_DIR"

  # 下载 AppImage 文件
  echo "Downloading AppImage..."
  wget -O "$APPIMAGE_DIR/$APPIMAGE_NAME" "$APPIMAGE_URL"

  # 赋予 AppImage 文件执行权限
  echo "Setting executable permission..."
  chmod +x "$APPIMAGE_DIR/$APPIMAGE_NAME"

  echo "AppImage installed to: $APPIMAGE_DIR/$APPIMAGE_NAME"

  # 创建桌面快捷方式
  create_desktop_entry

  # 安装脚本自身到 ~/bin
  install_self
}

# 函数：卸载 AppImage
uninstall_appimage() {
  read -p "Enter the AppImage name you want to uninstall (e.g., myapp.AppImage): " APPIMAGE_NAME
  read -p "Enter the installation directory (default: $HOME/Applications): " APPIMAGE_DIR
  APPIMAGE_DIR="${APPIMAGE_DIR:-$HOME/Applications}"

  # 删除 AppImage 文件
  if [ -f "$APPIMAGE_DIR/$APPIMAGE_NAME" ]; then
    rm "$APPIMAGE_DIR/$APPIMAGE_NAME"
    echo "AppImage file removed: $APPIMAGE_DIR/$APPIMAGE_NAME"
  else
    echo "AppImage file not found: $APPIMAGE_DIR/$APPIMAGE_NAME"
  fi

  # 删除桌面快捷方式
  DESKTOP_ENTRY_FILE="$HOME/.local/share/applications/$APPIMAGE_NAME.desktop"
  if [ -f "$DESKTOP_ENTRY_FILE" ]; then
    rm "$DESKTOP_ENTRY_FILE"
    echo "Desktop entry removed: $DESKTOP_ENTRY_FILE"
  else
    echo "Desktop entry not found: $DESKTOP_ENTRY_FILE"
  fi
}

# 函数：显示 AppImage 信息
show_appimage_info() {
  read -p "Enter the AppImage name (e.g., myapp.AppImage): " APPIMAGE_NAME
  read -p "Enter the installation directory (default: $HOME/Applications): " APPIMAGE_DIR
  APPIMAGE_DIR="${APPIMAGE_DIR:-$HOME/Applications}"

  echo "AppImage file:"
  if [ -f "$APPIMAGE_DIR/$APPIMAGE_NAME" ]; then
    find "$APPIMAGE_DIR" -name "$APPIMAGE_NAME" -print
  else
    echo "  Not found"
  fi

  echo "Desktop entry:"
  DESKTOP_ENTRY_FILE="$HOME/.local/share/applications/$APPIMAGE_NAME.desktop"
  if [ -f "$DESKTOP_ENTRY_FILE" ]; then
    echo "  $DESKTOP_ENTRY_FILE"
  else
    echo "  Not found"
  fi

  # 可以在这里添加查找其他相关配置文件的逻辑，例如：
  # echo "Configuration files:"
  # find "$HOME/.config" -name "*$APPIMAGE_NAME*" -print 2>/dev/null
}

# 函数：创建桌面快捷方式
create_desktop_entry() {
  read -p "Enter the application name for the desktop entry: " APP_NAME
  APP_NAME="${APP_NAME:-$APPIMAGE_NAME}"
  read -p "Enter icon name (must be in ~/.local/share/icons, /usr/share/icons/ or a full path):" APP_ICON
  DESKTOP_ENTRY_FILE="$HOME/.local/share/applications/$APPIMAGE_NAME.desktop"

  echo "[Desktop Entry]" > "$DESKTOP_ENTRY_FILE"
  echo "Version=1.0" >> "$DESKTOP_ENTRY_FILE"
  echo "Type=Application" >> "$DESKTOP_ENTRY_FILE"
  echo "Name=$APP_NAME" >> "$DESKTOP_ENTRY_FILE"
  echo "Exec=$APPIMAGE_DIR/$APPIMAGE_NAME" >> "$DESKTOP_ENTRY_FILE"
  echo "Icon=$APP_ICON" >> "$DESKTOP_ENTRY_FILE"
  echo "Comment=Installed via AppImage installer" >> "$DESKTOP_ENTRY_FILE"
  echo "Categories=Utility;" >> "$DESKTOP_ENTRY_FILE"
  echo "Terminal=false" >> "$DESKTOP_ENTRY_FILE"
  echo "StartupNotify=true" >> "$DESKTOP_ENTRY_FILE"

  echo "Desktop entry created at: $DESKTOP_ENTRY_FILE"
}

# 函数：安装脚本自身
install_self() {
  read -p "Do you want to install this script to ~/bin for easier access? (y/n): " INSTALL_SELF
  if [ "$INSTALL_SELF" == "y" ]; then
    TARGET_DIR="$HOME/bin"
    mkdir -p "$TARGET_DIR"
    cp "$0" "$TARGET_DIR/appimage-installer"
    chmod +x "$TARGET_DIR/appimage-installer"
    echo "Script installed to: $TARGET_DIR/appimage-installer"
    echo "You can now run it from anywhere using: appimage-installer"

    # 确保 ~/bin 在 PATH 中
    if ! grep -q 'export PATH=.*$HOME/bin' "$HOME/.bashrc"; then # 也可以改为~/.zshrc等
      echo 'export PATH=$HOME/bin:$PATH' >> "$HOME/.bashrc"
      source "$HOME/.bashrc"
    fi
  fi
}

# 主逻辑
case "$1" in
  install)
    install_appimage
    ;;
  uninstall)
    uninstall_appimage
    ;;
  info)
    show_appimage_info
    ;;
  -h|--help)
    show_help
    ;;
  *)
    echo "Invalid argument. Use -h or --help for usage information."
    exit 1
    ;;
esac
#!/bin/bash
BASE_DIR="/home"
crear_base_dir() {
    if [ ! -d "$BASE_DIR" ]; then
        sudo mkdir -p "$BASE_DIR"         # Crea el directorio base si no existe.
        sudo chmod 755 "$BASE_DIR"        # Asigna permisos para lectura/ejecución global y escritura solo para el propietario.
    fi
}

generar_usuario() {
    local last_num
    last_num=$(ls "$BASE_DIR" | grep -oP 'usuario\K\d+' | sort -n | tail -n 1)

    if [ -z "$last_num" ]; then
        USER_NUM=1                       # Si no hay usuarios, empieza desde 1.
    else
        USER_NUM=$((last_num + 1))      # Si hay, incrementa en 1.
    fi

    USER_NAME=$(printf "usuario%02d" "$USER_NUM")   # Genera nombre tipo usuario01, usuario02...
    USER_DIR="${BASE_DIR}/${USER_NAME}"             # Ruta completa del usuario.
    PUBLIC_HTML="${USER_DIR}/public_html"           # Directorio web del usuario.
    DOMAIN="${USER_NAME}.com"                       # Dominio ficticio para el usuario.
}

generar_contrasena() {
    PASS=$(openssl rand -base64 12)   # Genera una contraseña aleatoria segura de 12 caracteres en base64.
}

crear_usuario_sistema() {
    sudo useradd -d "$USER_DIR" -s /bin/bash "$USER_NAME"       # Crea el usuario con su carpeta personal y bash como shell.
    echo "${USER_NAME}:${PASS}" | sudo chpasswd                 # Establece la contraseña generada.
    sudo mkdir -p "$PUBLIC_HTML"                                # Crea el directorio `public_html`.
}

    # Crear info.php
    echo "<?php phpinfo(); ?>" | sudo tee "${PUBLIC_HTML}/info.php" > /dev/null

    # credenciales.html con plantilla de credenciales
    sudo tee "${PUBLIC_HTML}/credenciales.html" > /dev/null <<EOF
    ...
EOF

ajustar_permisos_y_enjaular() {
  sudo chown -R "$USER_NAME:$USER_NAME" "$USER_DIR"     # Asigna propiedad del directorio al usuario.
  sudo chmod -R 755 "$USER_DIR"                         # Permisos: lectura/ejecución general, escritura para el dueño.

  sudo useradd -d "$USER_DIR" -s /usr/sbin/nologin "$USER_NAME"

  if ! grep -q "^DenyUsers.*\b$USER_NAME\b" /etc/ssh/sshd_config; then
    echo "DenyUsers $USER_NAME" | sudo tee -a /etc/ssh/sshd_config > /dev/null
    sudo systemctl restart ssh
  fi 

}

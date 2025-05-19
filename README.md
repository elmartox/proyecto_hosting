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
    # Configurar permisos y ownership para FTP 
   sudo chown -R "${FTP_USER}:${FTP_USER}" "$WEB_ROOT"
   sudo chmod 755 "$WEB_ROOT"
   sudo chmod 755 "$PUBLIC_HTML"
   
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
    #Prohíbe el acceso SSH al usuario agregándolo a la directiva DenyUsers en la configuración SSH y reinicia el servicio para aplicar los cambios.
  fi 
  crear_bd_y_usuario_mariadb() {
  sudo mariadb -e "CREATE DATABASE ${USER_NAME};"
  sudo mariadb -e "CREATE USER '${USER_NAME}'@'localhost' IDENTIFIED BY '${PASS}';"
  
  #Se le conceden todos los privilegios (crear tablas, insertar datos, etc.) pero únicamente sobre su propia base de datos. El .* indica todas las tablas dentro de esa base, no otras bases de datos.
  sudo mariadb -e "GRANT ALL PRIVILEGES ON ${USER_NAME}.* TO '${USER_NAME}'@'localhost';" 

  sudo mariadb -e "FLUSH PRIVILEGES;"

}
# Define una variable local con la ruta donde se va a crear el archivo de configuración de NGINX para el dominio del usuario
Crear_config_nginx() {
  local NGINX_CONF="/etc/nginx/sites-available/${DOMAIN}"
  sudo tee "$NGINX_CONF" > /dev/null <<EOF
  # Usa tee con sudo para crear y escribir en el archivo de configuración como superusuario.
🔹 > /dev/null oculta la salida en pantalla.
🔹 <<EOF indica que lo que sigue es un bloque de texto que se insertará en el archivo.

server {
    listen 80;
    server_name ${DOMAIN};

    root ${PUBLIC_HTML};
    index index.php index.html;

    location / {
        try_files \$uri \$uri/ =404;
    }

    location ~ \.php\$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/run/php/php8.1-fpm.sock;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
        include fastcgi_params;
    }

    location ~ /\.ht {
        deny all;
    }
}
EOF
# Crea un enlace simbólico en sites-enabled para activar el sitio en NGINX.
🔹 La opción -sf fuerza el enlace y sobreescribe si ya existe.
  sudo ln -sf "$NGINX_CONF" /etc/nginx/sites-enabled/
}
#  Verifica si el dominio ya está en /etc/hosts, esto solo tiene efecto local, útil si estás probando sin un DNS público.
actualizar_hosts() {
  if ! grep -q "${DOMAIN}" /etc/hosts; then
    echo "127.0.0.1 ${DOMAIN}" | sudo tee -a /etc/hosts > /dev/null
  fi
}

recargar_nginx() {
  sudo systemctl reload nginx
}
# Recarga NGINX para aplicar los cambios
}

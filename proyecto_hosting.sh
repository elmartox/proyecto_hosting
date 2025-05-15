#!/bin/bash

BASE_DIR="/home"

crear_base_dir() {
    if [ ! -d "$BASE_DIR" ]; then
        sudo mkdir -p "$BASE_DIR"
        sudo chmod 755 "$BASE_DIR"
    fi
}

generar_usuario() {
    local last_num
    last_num=$(ls "$BASE_DIR" | grep -oP 'usuario\K\d+' | sort -n | tail -n 1)
    if [ -z "$last_num" ]; then
        USER_NUM=1
    else
        USER_NUM=$((last_num + 1))
    fi
    USER_NAME=$(printf "usuario%02d" "$USER_NUM")
    USER_DIR="${BASE_DIR}/${USER_NAME}"
    PUBLIC_HTML="${USER_DIR}/public_html"
    DOMAIN="${USER_NAME}.com"
}

generar_contrasena() {
    PASS=$(openssl rand -base64 12)
}

crear_usuario_sistema() {
    sudo useradd -d "$USER_DIR" -s /bin/bash "$USER_NAME"
    echo "${USER_NAME}:${PASS}" | sudo chpasswd
    sudo mkdir -p "$PUBLIC_HTML"
}

crear_archivos_html() {
    # index.html con plantilla de bienvenida
    sudo tee "${PUBLIC_HTML}/index.html" > /dev/null <<EOF
<!DOCTYPE html>
<html lang="es">
<head>
<meta charset="UTF-8" />
<meta name="viewport" content="width=device-width, initial-scale=1" />
<title>Bienvenido</title>
<style>
  body {
    background-color: #121212;
    color: #0ff; /* texto fosfo */
    font-family: Arial, sans-serif;
    text-align: center;
    margin: 0;
    padding: 20px;
    display: flex;
    flex-direction: column;
    align-items: center;
  }
  h1 {
    margin-top: 20px;
    margin-bottom: 40px;
    text-shadow: 0 0 8px #0ff;
  }
  button {
    padding: 12px 24px;
    font-size: 18px;
    background: #0ff;
    border: none;
    border-radius: 8px;
    color: #121212;
    cursor: pointer;
    box-shadow: 0 0 10px #0ff;
    margin-top: 40px;
    transition: background 0.3s ease;
  }
  button:hover {
    background: #0cc;
  }
  /* Pingüino */
  .penguin {
    position: relative;
    width: 150px;
    height: 220px;
    background: black;
    border-radius: 80px / 110px;
    box-shadow: inset 0 0 30px #333;
    margin: 0 auto;
  }
  .belly {
    position: absolute;
    top: 50px;
    left: 30px;
    width: 90px;
    height: 140px;
    background: white;
    border-radius: 50% / 60%;
    box-shadow: inset 0 0 20px #ccc;
  }
  .eye {
    position: absolute;
    top: 40px;
    width: 20px;
    height: 20px;
    background: white;
    border-radius: 50%;
    box-shadow: inset 0 0 10px #eee;
  }
  .eye.left {
    left: 40px;
  }
  .eye.right {
    right: 40px;
  }
  .pupil {
    position: absolute;
    top: 6px;
    left: 6px;
    width: 8px;
    height: 8px;
    background: black;
    border-radius: 50%;
  }
  .beak {
    position: absolute;
    top: 40px;
    left: 50%;
    transform: translateX(-50%);
    width: 30px;
    height: 20px;
    background: orange;
    border-radius: 50% 50% 50% 50% / 100% 100% 0 0;
    box-shadow: 0 2px 5px #c75d00;
  }
  .wing {
    position: absolute;
    top: 80px;
    width: 40px;
    height: 90px;
    background: black;
    border-radius: 40px / 90px;
    box-shadow: inset 0 0 15px #222;
  }
  .wing.left {
    left: -30px;
    transform: rotate(-15deg);
  }
  .wing.right {
    right: -30px;
    transform: rotate(15deg);
  }
  .foot {
    position: absolute;
    bottom: 10px;
    width: 50px;
    height: 20px;
    background: orange;
    border-radius: 25px / 50%;
    box-shadow: 0 2px 5px #c75d00;
  }
  .foot.left {
    left: 20px;
  }
  .foot.right {
    right: 20px;
  }
</style>
</head>
<body>
  <h1>Bienvenido - ${USER_NAME}</h1>
  
  <div class="penguin" aria-label="Pingüino decorativo">
    <div class="belly"></div>
    <div class="eye left"><div class="pupil"></div></div>
    <div class="eye right"><div class="pupil"></div></div>
    <div class="beak"></div>
    <div class="wing left"></div>
    <div class="wing right"></div>
    <div class="foot left"></div>
    <div class="foot right"></div>
  </div>
  
  <button onclick="window.location.href='credenciales.html'">Ver credenciales</button>
</body>
</html>
EOF
# Crear info.php
echo "<?php phpinfo(); ?>" | sudo tee "${PUBLIC_HTML}/info.php" > /dev/null

 # credenciales.html con plantilla de credenciales
    sudo tee "${PUBLIC_HTML}/credenciales.html" > /dev/null <<EOF
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8" />
  <title>Credenciales - ${USER_NAME}</title>
  <style>
    body {
      background: #0a1e3a; /* azul oscuro */
      color: #cce7ff; /* azul claro */
      font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
      display: flex;
      flex-direction: column;
      align-items: center;
      justify-content: center;
      min-height: 100vh;
      margin: 0;
      padding: 20px;
    }
    .container {
      background: #123456; /* un azul intermedio oscuro */
      border-radius: 12px;
      padding: 30px 40px;
      box-shadow: 0 0 15px #2a7fff88;
      max-width: 400px;
      width: 100%;
      text-align: center;
    }
    h1 {
      margin-bottom: 20px;
      font-weight: 700;
      font-size: 2rem;
      color: #a3cfff;
      text-shadow: 0 0 6px #66aaffbb;
    }
    .credencial {
      background: #0f2a54;
      border-radius: 8px;
      padding: 15px 20px;
      margin-bottom: 15px;
      box-shadow: inset 0 0 8px #2a7fffaa;
      font-size: 1.1rem;
      word-break: break-word;
    }
    button {
      background: #1e3c72;
      color: #cce7ff;
      border: none;
      border-radius: 8px;
      padding: 12px 25px;
      font-size: 1rem;
      cursor: pointer;
      box-shadow: 0 0 10px #2a7fffcc;
      transition: background 0.3s ease;
      margin-top: 20px;
      width: 100%;
    }
    button:hover {
      background: #2a5fcf;
      box-shadow: 0 0 15px #66aaffee;
    }
  </style>
</head>
<body>
  <div class="container">
    <h1>Credenciales - ${USER_NAME}</h1>
    <div class="credencial"><strong>Usuario:</strong> ${USER_NAME}</div>
    <div class="credencial"><strong>Contraseña:</strong> ${PASS}</div>
    <div class="credencial"><strong>Directorio:</strong> ${USER_DIR}</div>
    <div class="credencial"><strong>Base de datos:</strong> ${USER_NAME}</div>
    <button onclick="window.location.href='http://172.17.42.125:8018/phpmyadmin'">Acceder a phpMyAdmin</button>
  </div>
</body>
</html>
EOF
}
ajustar_permisos_y_enjaular() {
  sudo chown -R "$USER_NAME:$USER_NAME" "$USER_DIR"
  sudo chmod -R 755 "$USER_DIR"
  sudo useradd -d "$USER_DIR" -s /usr/sbin/nologin "$USER_NAME"
  if ! grep -q "^DenyUsers.*\b$USER_NAME\b" /etc/ssh/sshd_config; then
    echo "DenyUsers $USER_NAME" | sudo tee -a /etc/ssh/sshd_config > /dev/null
    sudo systemctl restart ssh
  fi 
}

crear_bd_y_usuario_mariadb() {
  sudo mariadb -e "CREATE DATABASE ${USER_NAME};"
  sudo mariadb -e "CREATE USER '${USER_NAME}'@'localhost' IDENTIFIED BY '${PASS}';"
  sudo mariadb -e "GRANT ALL PRIVILEGES ON ${USER_NAME}.* TO '${USER_NAME}'@'localhost';"
  sudo mariadb -e "FLUSH PRIVILEGES;"
}

crear_config_nginx() {
  local NGINX_CONF="/etc/nginx/sites-available/${DOMAIN}"
  sudo tee "$NGINX_CONF" > /dev/null <<EOF
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

  sudo ln -sf "$NGINX_CONF" /etc/nginx/sites-enabled/
}

actualizar_hosts() {
  if ! grep -q "${DOMAIN}" /etc/hosts; then
    echo "127.0.0.1 ${DOMAIN}" | sudo tee -a /etc/hosts > /dev/null
  fi
}

recargar_nginx() {
  sudo systemctl reload nginx
}

mostrar_info() {
  local IP_VM
  IP_VM=$(hostname -I | awk '{print $1}')
  echo ""
  echo "✅ Usuario creado: $USER_NAME"
  echo "🔑 Contraseña: $PASS"
  echo "📁 Carpeta: $USER_DIR"
  echo "🌐 Subdominio virtual: http://${DOMAIN} (interno VM)"
  echo "🌐 Accede desde tu navegador:"
  echo "   ➤ http://${DOMAIN}"
}
crear_base_dir
generar_usuario
generar_contrasena
crear_usuario_sistema
crear_archivos_html
ajustar_permisos_y_enjaular
crear_bd_y_usuario_mariadb
crear_config_nginx
actualizar_hosts
recargar_nginx
mostrar_info
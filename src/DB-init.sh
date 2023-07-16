#! /bin/bash
echo "`uname -n`: acceso a la BBDD de la app." > app.txt
echo "`uname -n`: acceso a la BBDD de la web." > web.txt
python3 -m http.server 1530
## ¡Estás usando la configuración de Vicente!

Por favor lee atentamente este documento para conocer más información acerca de las herramientas instaladas y cómo utilizarlas correctamente.

### Instalación de paquetes/apps

Cuando estás usando una distribución atómica como Fedora Silverblue la forma recomendada de instalar las cosas es la siguiente: Flatpak > Homebrew > Toolbox > RPM-Ostree (agrega paquete a la base del sistema).

### Flatpak

Aunque tengas instalado el repositorio de Flathub tanto en sistema como en usuario, te recomiendo seleccionar el repositorio remoto de usuario siempre cuando vayas a instalar una aplicación ya que así es más fácil identificar las apps que vinieron instaladas del sistema y de las tuyas, además simplifica la gestión si quieres usar más de un usuario.

Para usar Flatpak como usuario desde la terminal agrega `--user` en el comando.

### Homebrew

Instala el popular gestor de paquetes entre programadores [*Homebrew*](https://brew.sh/).
Este te permite instalar un montón de herramientas y utilidades, puedes explorar la lista en su página.

Cuando necesites una herramienta de terminal debes mirar primero si está aquí antes de intentar instalarla por otros medios.

Al instalarlo con el instalador de Universal Blue este se instala en un usuario nuevo.

#### Paquetes brew instalados

* [`bat`](https://github.com/sharkdp/bat): para leer el contenido de archivos, `cat` mejorado
* [`catimg`](https://github.com/posva/catimg): para ver imágenes en la terminal
* [`eza`](https://github.com/eza-community/eza): listado de archivos mejorado
* [`git-delta`](https://github.com/dandavison/delta): mejora el comando `git diff` con resaltado de sintaxis
* [`gh`](https://cli.github.com/): utilidad de terminal de GitHub
* [`micro`](https://github.com/zyedidia/micro): un editor de texto, alternativa a `nano`, usa atajos de teclado más comunes
* [`volta`](https://volta.sh/): gestor de Node.js
* [`pfetch`](https://github.com/dylanaraps/pfetch): alternativa a `neofetch` más rápida
* [`tldr`](https://tldr.sh/): cuando no sepas usar un comando o no tenga autocompletado usa `tldr Comando`
* [`starship`](https://starship.rs/): prompt bonito para la terminal
* [`glow`](https://github.com/charmbracelet/glow): renderiza markdown en la terminal, es lo que se está usando para mostrarte esto ;)

### [Fish](https://fishshell.com/)

Fish se instala en el sistema base a través de rpm-ostree.

Fish es la terminal que utilizo porque incluye autocompletado y otras características chulas por defecto y es mucho más rápida que oh-my-zsh.

El archivo de configuración es `config.fish` y ahí podrás ver las variables que agrego al PATH y los comandos sobreescritos que tengo (ls, rm, cat) para utilizar las herramientas mencionadas arriba. Recuerda que siempre que quieras saltarte el comando modificado puedes llamar directamente al comando de base desde por ejemplo `/bin/ls`.

### Visual Studio Code

Se instala también a través de Flatpak, por lo tanto es posible que la terminal por defecto esté dentro de la sandbox y por lo tanto no tenga acceso al sistema.

Para configurarlo correctamente sigue [estas instrucciones](https://github.com/flathub/com.visualstudio.code?tab=readme-ov-file#use-host-shell-in-the-integrated-terminal) pero recuerda cambiar `bash` por `fish`.

Al hacer eso deberías poder acceder a la misma terminal que tienes en tu sistema, desde que hagas eso además las extensiones que necesiten llamar a paquetes del sistema (ej eslint) deberían poder funcionar correctamente.

Si necesitas añadir el soporte a otro idioma que no esté soportado por defecto en el editor revisa también porque tiene instrucciones adicionales.

### Volta, Node y PNPM

Volta es un gestor de paquetes que te permite gestionar las versiones de Node instaladas e instalar una específica para un proyecto, a través de Volta puedes instalar Yarn y PNPM también.

Utilizo PNPM porque es más rápido que NPM y los comandos son prácticamente idénticos con algunas excepciones.

#### Utilidades para Node

Dejo por aquí una lista de utilidades que he instalado con PNPM que vienen muy bien en proyectos con Node.

* `taze`: permite ver y actualizar las dependencias utilizando las *versiones semánticas*, por ejemplo `taze patch` te mostrará y permitirá actualizar las dependencias que hayan incrementado el tercer dígito en su versión (`0.0.X`)
* `pnpm update --latest`: sirve también para actualizar pero de una forma muy interactiva
* `ni`: instala las dependencias pero utilizando el gestor de paquetes de identifica en el proyecto
* `nr`: lo mismo que antes pero para ejecutar scripts

## Salir

Puedes salir de la vista de este documento presionando la tecla `q`

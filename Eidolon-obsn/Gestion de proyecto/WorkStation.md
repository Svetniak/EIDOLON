### 1. El Puente Godot + Neovim
Para que Neovim no sea solo un editor de texto, sino un IDE real para Godot:

- [x] **LSP (Language Server Protocol):** Configura `godot-gdscript` en tu configuración de Neovim. Esto te dará autocompletado de nodos y funciones de Godot directamente en el editor.
- [x] **godot.nvim:** Hay plugins específicos que permiten ejecutar la escena actual o el proyecto con un _keybinding_ desde Neovim.
- [x] **Terminal Multiplexing:** Dado que usas Qtile, asegúrate de tener una terminal con pestañas o usar `tmux` para tener los logs de Godot en una ventana y el código en otra.

### 2. Control de Versiones (Git)
Para un MVP con mecánicas tan complejas (nodos que se cierran, IA que aprende), el control de versiones es tu red de seguridad:

- [ ] **Git LFS (Large File Storage):** Vital para Godot. Los assets de GIMP e Inkscape pesan. Configura LFS para que el repositorio no se vuelva lento al manejar imágenes y sonidos.
- [ ]  **Estructura de Ramas:** Una rama para el _Core Loop_ (movimiento) y otra para el _Sistema de Consecuencias_.

### 3. Pipeline de Assets (FOS Workflow)
Para que el paso de diseño a juego sea fluido:

- [x] **Inkscape:** Configura la exportación por lotes. Para un Metroidvania, usarás muchos _tilesets_. Aprender a usar capas para las diferentes facciones (Conservador/Bio-Punk) te ahorrará horas.
- [x] **GIMP:** Instala plugins para exportar en formato `.webp` o `.png` optimizado, manteniendo la fidelidad del Pixel Art que buscamos.
- [ ] **Aseprite:** Aunque usas GIMP, Aseprite es el estándar FOS para animación de Pixel Art. Si prefieres quedarte en GIMP, asegúrate de dominar las capas de animación.

### 4. Herramientas de Audio
Un juego llamado **PULSE** no puede avanzar sin sonido:

- [x] **Audacity:** Para editar los efectos de disparo y explosiones estilo _Metal Slug_.
- [ ] **LMMS o Ardour:** Para la música industrial/electrónica que marcará el ritmo del juego.

### 5. Documentación Dinámica:
Como supervisor de **MAZN** (tu identidad corporativa), necesitas un lugar donde mapear los nodos:

- [x] **Obsidian:** Herramientas Markdown que corren nativo en Linux. Ideales para crear el gráfico de "Nodos de Oportunidad" que planeamos y que se conecten entre sí.

---

### Tu Checklist de Setup "Day One":

1. [x] **Godot Engine:** Versión 4.x (recomendado por las mejoras en el motor 2D y el sistema de partículas para los efectos de humo y chispas).
2. [x] **Neovim Config:** Enlazar con el puerto de escucha de Godot para debugging en tiempo real.
3. [x] **Estructura de Carpetas:**
    - `/assets` (Sprites, Sonido)
    - `/scenes` (Nivel 01, Ruta Fantasma)
    - `/scripts` (IA_Resonancia, Controller_Player)
4. [ ] **Repo en GitHub/GitLab:** Para el respaldo del MVP.
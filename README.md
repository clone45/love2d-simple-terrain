# Love2D Simple Terrain Demo

This is a simple terrain rendering demo built using [Love2D](https://love2d.org/). The project showcases dynamic terrain generation, camera controls, and custom shaders for visual effects.

## Features

- Procedurally generated terrain with configurable grid size and height scaling.
- Interactive camera with pan, zoom, and rotation.
- Custom shaders for dynamic shading based on terrain height.
- Debug mode for visualizing terrain data.

## Controls

| Key/Action         | Description                             |
|---------------------|-----------------------------------------|
| **Left Click + Drag** | Pan the camera                        |
| **Mouse Wheel**      | Zoom in/out                           |
| **W/A/S/D**          | Move the camera (world space)         |
| **Q/E**              | Rotate the camera                     |
| **R**                | Reload the shader                    |
| **D**                | Toggle debug mode                     |

## File Overview

- **`main.lua`**: The main entry point that initializes the terrain, loads shaders, and handles user input.
- **`terrain.lua`**: Defines the `Terrain` class responsible for terrain generation, camera handling, and rendering.
- **`shaders.lua`**: Contains the vertex and pixel shader code used for rendering the terrain.

## Installation

1. Install [Love2D](https://love2d.org/).
2. Clone this repository:
   ```bash
   git clone https://github.com/clone45/love2d-simple-terrain.git
   cd love2d-simple-terrain
3. Run the project using Love2D:
   ```bash
   love .

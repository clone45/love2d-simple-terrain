-- main.lua
local Terrain = require('terrain')
local Shaders = require('shaders')

function love.load()
    -- Create terrain system with more dramatic heights
    terrain = Terrain.new(32, 32, 200)
    
    -- Load terrain texture
    terrainTexture = love.graphics.newImage("terrain.png")
    
    -- Load shader
    terrainShader = Shaders.get('terrain')
    
    -- Mouse interaction state
    isDragging = false
    lastMouseX = 0
    lastMouseY = 0
    
    -- Create initial mesh
    terrainMesh = terrain:createMesh(terrainTexture)
    
    -- Debug state
    debugMode = false
end

function love.keypressed(key)
    if key == 'r' then
        -- Reload shader
        terrainShader = Shaders.reload('terrain')
        print("Shader reloaded")
    elseif key == 'd' then
        -- Toggle debug mode
        debugMode = not debugMode
        print("Debug mode: " .. tostring(debugMode))
    end
end

function love.mousepressed(x, y, button)
    if button == 1 then
        isDragging = true
        lastMouseX = x
        lastMouseY = y
    end
end

function love.mousereleased(x, y, button)
    if button == 1 then
        isDragging = false
    end
end

function love.wheelmoved(x, y)
    terrain:setZoom(terrain.camera.zoom + y * 0.1)
end

function love.update(dt)
    -- Handle keyboard movement (in world space)
    local moveSpeed = 200 * dt
    if love.keyboard.isDown('a') then
        terrain:moveCamera(-moveSpeed, 0)
    elseif love.keyboard.isDown('d') then
        terrain:moveCamera(moveSpeed, 0)
    end
    if love.keyboard.isDown('w') then
        terrain:moveCamera(0, moveSpeed)
    elseif love.keyboard.isDown('s') then
        terrain:moveCamera(0, -moveSpeed)
    end
    
    -- Handle mouse drag (in screen space)
    if isDragging then
        local mouseX, mouseY = love.mouse.getPosition()
        local dx = mouseX - lastMouseX
        local dy = mouseY - lastMouseY
        
        terrain:moveCameraByScreen(dx, dy)
        
        lastMouseX = mouseX
        lastMouseY = mouseY
    end

    -- rotation handling
    local rotateSpeed = 2.0 * dt
    if love.keyboard.isDown('e') then
        terrain:rotate(-1.0 * dt)  -- Counter-clockwise
    elseif love.keyboard.isDown('q') then
        terrain:rotate(1.0 * dt)   -- Clockwise
    end

end

function love.draw()
    -- Send updated uniforms to shader
    local camera = terrain:getCameraUniforms()
    terrainShader:send('cameraX', camera.x)
    terrainShader:send('cameraY', camera.y)
    terrainShader:send('cameraZoom', camera.zoom)
    terrainShader:send('cameraRotation', camera.rotation)
    terrainShader:send('screenSize', {love.graphics.getWidth(), love.graphics.getHeight()})
    
    -- Draw terrain
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setShader(terrainShader)
    love.graphics.draw(terrainMesh)
    love.graphics.setShader()
    
    -- Draw debug visualization if enabled
    if debugMode then
        terrain:drawDebug()
    end
    
    -- Draw UI
    love.graphics.setColor(1, 1, 0)
    love.graphics.print([[
Controls:
Left click and drag: Pan view
Arrow keys: Move camera
Mouse wheel: Zoom in/out
R: Reload shader
D: Toggle debug view]], 10, 10)
    
    -- Draw debug info
    love.graphics.setColor(0, 1, 0)
    love.graphics.print(string.format(
        "Camera: X=%.2f, Y=%.2f, Height=%.2f, Zoom=%.2f\nDebug: %s",
        camera.x, camera.y, camera.height, camera.zoom,
        debugMode and "ON" or "OFF"
    ), 10, 100)
end
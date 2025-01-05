-- terrain.lua
local Terrain = {}
Terrain.__index = Terrain

function Terrain.new(gridSize, cellSize, heightScale)
    local terrain = {
        gridSize = gridSize or 32,
        cellSize = cellSize or 32,
        heightScale = 10,  -- Keep your lower height scale
        
        -- Camera position (in world space)
        camera = {
            x = 0,
            y = 0,
            height = 100,
            zoom = 1,
            rotation = 0
        }
    }
    setmetatable(terrain, Terrain)
    
    -- Generate heightmap
    terrain.heights = {}
    for x = 1, terrain.gridSize do
        terrain.heights[x] = {}
        for y = 1, terrain.gridSize do
            local height = math.sin(x/2) * math.cos(y/2) * terrain.heightScale
            height = height + math.sin(x/4 + y/4) * terrain.heightScale * 0.5
            terrain.heights[x][y] = height
        end
    end
    
    return terrain
end

function Terrain:createMesh(texture)
    local vertices = {}
    local indices = {}
    local vertexIndex = 1
    local indexCount = 1
    
    local halfGrid = self.gridSize / 2
    
    for x = 1, self.gridSize-1 do
        for y = 1, self.gridSize-1 do
            -- Get height values
            local h1 = self.heights[x][y]
            local h2 = self.heights[x+1][y]
            local h3 = self.heights[x+1][y+1]
            local h4 = self.heights[x][y+1]
            
            -- Calculate world positions
            local x1 = (x - halfGrid) * self.cellSize
            local x2 = (x + 1 - halfGrid) * self.cellSize
            local y1 = (y - halfGrid) * self.cellSize
            local y2 = (y + 1 - halfGrid) * self.cellSize
            
            -- UV coordinates
            local u1 = (x-1) / (self.gridSize-1)
            local v1 = (y-1) / (self.gridSize-1)
            local u2 = x / (self.gridSize-1)
            local v2 = y / (self.gridSize-1)
            
            -- Add vertices with 3D positions (x, y, z, u, v)
            vertices[vertexIndex] = {x1, y1, h1, u1, v1}
            vertices[vertexIndex + 1] = {x2, y1, h2, u2, v1}
            vertices[vertexIndex + 2] = {x2, y2, h3, u2, v2}
            vertices[vertexIndex + 3] = {x1, y2, h4, u1, v2}
            
            indices[indexCount] = vertexIndex
            indices[indexCount + 1] = vertexIndex + 1
            indices[indexCount + 2] = vertexIndex + 2
            indices[indexCount + 3] = vertexIndex
            indices[indexCount + 4] = vertexIndex + 2
            indices[indexCount + 5] = vertexIndex + 3
            
            vertexIndex = vertexIndex + 4
            indexCount = indexCount + 6
        end
    end
    
    local mesh = love.graphics.newMesh({
        {"VertexPosition", "float", 3},
        {"VertexTexCoord", "float", 2},
    }, vertices, "triangles")
    
    mesh:setTexture(texture)
    mesh:setVertices(vertices)
    mesh:setVertexMap(indices)
    
    return mesh
end

function Terrain:moveCamera(dx, dy)
    -- Convert movement based on camera rotation
    local sinRot = math.sin(self.camera.rotation)
    local cosRot = math.cos(self.camera.rotation)
    
    -- Rotate the movement vector
    local rotatedDx = dx * cosRot - dy * sinRot
    local rotatedDy = dx * sinRot + dy * cosRot
    
    -- Apply rotated movement
    self.camera.x = self.camera.x + rotatedDx
    self.camera.y = self.camera.y + rotatedDy
end

function Terrain:moveCameraByScreen(dx, dy)
    local scale = 1.0 / self.camera.zoom
    self:moveCamera(dx * scale, dy * scale)
end

-- Helper function to get camera properties for shader
function Terrain:getCameraUniforms()
    return {
        x = self.camera.x,
        y = self.camera.y,
        height = self.camera.height,
        zoom = self.camera.zoom,
        rotation = self.camera.rotation
    }
end

function Terrain:drawDebug()
    love.graphics.setColor(1, 0, 0, 1)
    for x = 1, self.gridSize do
        for y = 1, self.gridSize do
            local worldX = (x - self.gridSize/2) * self.cellSize - self.camera.x
            local worldY = (y - self.gridSize/2) * self.cellSize - self.camera.y
            local height = self.heights[x][y]
            
            -- Project debug points
            local angle = 1.0  -- Match shader ROTATION
            local rotated_y = worldY * math.cos(angle) - height * math.sin(angle)
            
            local screenX = worldX * self.camera.zoom + love.graphics.getWidth()/2
            local screenY = rotated_y * self.camera.zoom + love.graphics.getHeight()/2
            
            love.graphics.circle('fill', screenX, screenY, math.abs(height/100))
        end
    end
end

-- Add this new function to Terrain:
function Terrain:rotate(angle)
    self.camera.rotation = self.camera.rotation + angle
end

-- Add zoom function to Terrain:
function Terrain:setZoom(zoom)
    self.camera.zoom = zoom
end

return Terrain
-- shaders.lua

local Shaders = {
    cache = {},
    definitions = {}
}

local vertexCode = [[
    uniform float cameraX;
    uniform float cameraY;
    uniform float cameraZoom;
    uniform vec2 screenSize;
    uniform float cameraRotation;
    
    varying float v_height;
    
    const float ROTATION = 1.0;
    const float HEIGHT_SCALE = 2.0;

    vec4 position(mat4 transform_projection, vec4 vertex_position)
    {
        vec4 pos = vertex_position;
        
        // Get world-space coordinates relative to camera
        float worldX = pos.x - cameraX;
        float worldZ = pos.y - cameraY;
        
        // Rotate the XZ plane (panning camera)
        float sinRot = sin(cameraRotation);
        float cosRot = cos(cameraRotation);
        float rotatedX = worldX * cosRot + worldZ * sinRot;
        float rotatedZ = -worldX * sinRot + worldZ * cosRot;
        
        // Apply height scaling
        float worldY = pos.z * HEIGHT_SCALE;
        v_height = worldY;

        // Apply terrain tilt
        float tiltedY = worldY * cos(ROTATION) - rotatedZ * sin(ROTATION);
        float tiltedZ = worldY * sin(ROTATION) + rotatedZ * cos(ROTATION);
        
        // Perspective effect
        float perspective = 1.0 - (tiltedZ * 0.001);
        float finalX = rotatedX * perspective;
        float finalY = tiltedY * perspective;

        // Screen position
        vec2 center = screenSize * 0.5;
        vec2 final_pos = vec2(finalX, finalY) * cameraZoom + center;
        
        return transform_projection * vec4(final_pos, 0.0, 1.0);
    }
]]

local pixelCode = [[
    varying float v_height;
    
    vec4 effect(vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords)
    {
        vec4 texColor = Texel(tex, texture_coords);
        float shade = 0.5 + (v_height / (200.0 * 2.0));
        shade = clamp(shade, 0.3, 1.0);
        return texColor * color * vec4(shade, shade, shade, 1.0);
    }
]]

Shaders.definitions.terrain = {
    vertex = vertexCode,
    pixel = pixelCode
}

-- Add these functions to the Shaders table
function Shaders.get(name)
    if not Shaders.cache[name] then
        if Shaders.definitions[name] then
            local def = Shaders.definitions[name]
            Shaders.cache[name] = love.graphics.newShader(def.vertex, def.pixel)
        else
            error("Shader " .. name .. " not found")
        end
    end
    return Shaders.cache[name]
end

function Shaders.reload(name)
    if Shaders.cache[name] then
        Shaders.cache[name]:release()
        Shaders.cache[name] = nil
    end
    return Shaders.get(name)
end

return Shaders
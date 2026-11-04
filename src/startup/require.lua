function requireAll()

    require("src/startup/collisionClasses")
    createCollisionClasses()

    -- Load assets, resources, data
    require("src/startup/resources")
    require("src/startup/data")
    
    require("src/utilities/cam")
    require("src/utilities/destroyAll")
    require("src/utilities/misc")
    require("src/utilities/shaders")
    require("src/utilities/shake")
    require("src/utilities/triggers")
    require("src/utilities/utils")

    require("src/player")
    require("src/update")
    require("src/draw")

    require("src/effects/blast")
    require("src/effects/effect")
    require("src/effects/particles/particle")
    require("src/effects/particles/particleEvent")

    require("src/enemies/projectile")
    require("src/enemies/enemy")

    require("src/levels/curtain")
    require("src/levels/loadMap")
    require("src/levels/transition")
    require("src/levels/wall")

    require("src/ui/hud")
    require("src/ui/menu")
    require("src/ui/intro")
    require("src/ui/tutorial")
    require("src/ui/death")
    require("src/ui/pause")
    require("src/ui/inventory")
    require("src/ui/endScreen")
    require("src/ui/menuMusic")

end
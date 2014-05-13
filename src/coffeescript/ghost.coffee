class Ghost extends Character
    
    # ghost modes    
    # n - none
    # c - chase
    # s - scatter
    # f - frightened
    # d - dead

    mode: 'n'
    speed: 1
    self: -1

    constructor: (@game, @self) ->
        
        # can move onto tiles of type 1 or higher
        @minAllowedTile = 3 # changeme


    changeMode: (@mode) -> 
     
        # when entering 'frightened' mode, reverse direction
        if @mode is 'f'
            @direction = @opposite @direction
        else if @mode is 'd'
            @game.renderer.changeMode 'd', @


    chooseDirection: (allowedDirections) ->

        # if there's only one way we can go, go that way
        return allowedDirections[0] if allowedDirections.length is 1

        # when in frigtened mode, choose a random direction 
        # from the directions we're allowed to go in
        return _.shuffle(allowedDirections)[0] if @mode is 'f'

        # otherwise, get best direction
        target           = @getTargetSquare()
        shortestDistance = 100

        for direction in allowedDirections
            
            switch direction

                when 'l' then source = { x: @x - 1, y: @y }
                when 'r' then source = { x: @x + 1, y: @y }
                when 'u' then source = { x: @x, y: @y - 1 }
                when 'd' then source = { x: @x, y: @y + 1 }

            distance = @distance source, target

            if distance < shortestDistance
                bestDirection    = direction
                shortestDistance = distance

        return bestDirection


    # get distance from source square to target square
    distance: (source, target) -> 

        x = source.x - target.x
        y = source.y - target.y

        Math.sqrt (x * x) + (y * y)
 

    getTargetSquare: -> 
        
        switch @mode

            when 'd' then target = 
                x: 13
                y: 12


    checkForCollisions: -> 
        
        # check for collisions with other ghosts
        for index, ghost of @game.ghosts
            
            continue if index == @index.toString()
            
            offsetX = ghost.x - @x
            offsetY = ghost.y - @y

            return yes if offsetX >= -1 and offsetX <= 1 and offsetY >= -1 and offsetY <= 1
                
        # check for collisions with pacman
        pacman  = @game.pacman
        offsetX = pacman.x - @x
        offsetY = pacman.y - @y 
        
        return pacman if offsetX >= -1 and offsetX <= 1 and offsetY >= -1 and offsetY <= 1

        return no


    move: ->
        
        # check for collisions
        if collisionObject = @checkForCollisions()
            
            if collisionObject instanceof Pacman
                if @mode is 'f'
                    @changeMode 'd' 
            else
                @direction = @opposite @direction


        # if we're at integer co-ordinates (not between tiles)
        if @x % 1 is 0 and @y % 1 is 0 and collisionObject isnt yes

            # determine which directions we can move in
            allowedDirections = []

            for direction in ['l', 'r', 'u', 'd']
                if @canMove(direction) and not @isOpposite @direction, direction # changeme - make second argument default to @direction
                    allowedDirections.push direction

            # evaluate best direction to move in
            @direction = @chooseDirection allowedDirections

            # in 'd' mode (dead), check if we've reached the square we're
            # targeting - if so, regenerate
            if @mode is 'd'
                target = @getTargetSquare()
                @regenerate() if x is target.x and y is target.y


        # adjust position
        switch @direction

            when 'l' then @x -= 0.25
            when 'r' then @x += 0.25
            when 'd' then @y += 0.25
            when 'u' then @y -= 0.25

        # handle teleportation
        switch yes
            when @x is 0 and @direction is 'l' then @x = 27
            when @x is 27 and @direction is 'r' then @x = 0

        return


    # return opposite direction to the one supplied
    opposite: (direction) -> {'l': 'r', 'r': 'l', 'u': 'd', 'd': 'u'}[direction]

    # if dead and reached target square, reset ghost state
    regenerate: ->
        # todo ..
        return

    setSpeed: (@speed) -> 


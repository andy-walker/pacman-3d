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
        # todo: additional stuff for changing sprite png when frightened etc
       


    chooseDirection: (allowedDirections) ->

        # if there's only one way we can go, go that way
        return allowedDirections[0] if allowedDirections.length is 1

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
        #pacman = @game.pacman
        #return pacman if Math.round pacman.x is Math.round @x and Math.round pacman.y is Math.round @y

        return no


    move: ->
        
        # check for collisions
        if collisionObject = @checkForCollisions()

            switch yes
                
                # if colliding with another ghost, reverse direction
                when collisionObject then @direction = @opposite @direction

                # if colliding with pacman, do nothing for now
                when collisionObject instanceof Pacman then null 

        # if we're at integer co-ordinates (not between tiles)
        else if @x % 1 is 0 and @y % 1 is 0

            # determine which directions we can move in
            allowedDirections = []

            for direction in ['l', 'r', 'u', 'd']
                if @canMove(direction) and not @isOpposite @direction, direction # changeme - make second argument default to @direction
                    allowedDirections.push direction

            # evaluate best direction to move in
            @direction = @chooseDirection allowedDirections


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

    setSpeed: (@speed) -> 


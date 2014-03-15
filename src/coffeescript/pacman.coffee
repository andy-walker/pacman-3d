class Pacman extends Character

    constructor: (@game) ->
        
        # initialize pacman position at start of level
        @x = 13.5
        @y = 23

        # can move onto tiles of type 3 or higher
        @minAllowedTile = 3


    move: ->
        
        if @game.input[1][0] and @canMove 'l'
            
            @y = Math.round @y
            @direction = 'l'
            @x -= 0.25
        
        else if @game.input[0][1] and @canMove 'u'
        
            @direction = 'u'
            @y -= 0.25
            @x = Math.round @x
        
        else if @game.input[1][2] and @canMove 'r'

            @direction = 'r'
            @x += 0.25
            @y = Math.round @y
        
        else if @game.input[2][1] and @canMove 'd'

            @direction = 'd'
            @y += 0.25
            @x = Math.round @x

        # when x and y co-ordinates are both integers,
        # notify Level class of pacman position
        if @x % 1 is 0 and @y % 1 is 0
            @game.level.pacmanPosition(@x, @y)

        # handle teleportation
        switch yes
            when @x is 0 and @direction is 'l' then @x = 27
            when @x is 27 and @direction is 'r' then @x = 0

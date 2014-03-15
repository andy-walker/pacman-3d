class Level

    level: 1
    pills: 240
    energizerMode: off
    pillCollisionAt: []

    constructor: (@game) -> @initialize()

    changeMode: (mode) -> ghost.changeMode mode for ghost in @game.ghosts

    initialize: ->
        
        # initialize pills, use local copy of maze array to 
        # keep additional track of these
        @pills = 240
        @maze  = maze

        # instance pacman class
        @game.pacman = new Pacman @game

        # instance ghost class x 4
        @game.ghosts = [
            new Blinky @game, 0
            new Inky   @game, 1
            new Pinky  @game, 2
            new Clyde  @game, 3
        ]
        
        return

    
    isPillCollision: ->
        
        unless @pillCollisionAt.length
            return no
        
        coordinates =
            x: @pillCollisionAt[0]
            y: @pillCollisionAt[1]

        @pillCollisionAt = []
        return coordinates


    pacmanPosition: (x, y) ->

        # check if pacman is on the same square as a pill, if so
        # mark as eaten
        switch @maze[y][x]
            
            when 4
                @pills--
                @maze[y][x]--
                @pillCollisionAt = [x, y]

            when 5
                @pills--
                @maze[y][x] -= 2
                @pillCollisionAt = [x, y]

                # set ghost mode to 'frightened'
                # @changeMode 'f'

        return


    up: ->

        @level++
        @initialize()
        return

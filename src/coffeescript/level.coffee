class Level

    level: 1
    pills: 240
    energizerMode: off
    pillCollisionAt: []

    constructor: (@game) -> @initialize()

    changeMode: (mode) -> 
        
        # change mode for each ghost, except when ghost in 'd' mode
        # (in 'd' mode, ghost remains in that mode until it reaches target square)
        for ghost in @game.ghosts
            ghost.changeMode mode unless ghost.mode is 'd'

        @game.renderer.changeMode mode

        if mode is 'f'
            setTimeout((-> game.level.changeMode 'c'), 6000)
         

    clearPillCollisions: -> @pillCollisionAt = []

    # multidimensional array clone - default js behaviour is to reference,
    # but we need a fresh copy on each new level
    getMaze: -> maze.map((arr) -> arr.slice())

    initialize: ->
        
        # initialize pills, use local copy of maze array to 
        # keep additional track of these
        @pills = 240
        @maze  = @getMaze()

        # instance pacman class
        @game.pacman = new Pacman @game

        # instance ghost class x 4
        @game.ghosts = [
            new Blinky @game, 0
            new Inky   @game, 1
            new Pinky  @game, 2
            new Clyde  @game, 3
        ]
        
        @game.renderer.resetLevel()

        return

    
    isPillCollision: ->
        
        unless @pillCollisionAt.length
            return no
        
        # if collision, return object containing x, y co-ordinates
        collision =
            x: @pillCollisionAt[0]
            y: @pillCollisionAt[1]


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
                @changeMode 'f'

        return


    up: ->

        @level++
        @initialize()
        return

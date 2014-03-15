class Clyde extends Ghost

    index: 3

    constructor: ->
        
        @x = 13.5
        @y = 29
        @direction = 'l'
        @mode      = 'c'
        super


    getTargetSquare: -> 
        
        switch @mode
            
            # target closest square to pacman when in chase mode
            when 'c'
                if @distance(@game.pacman, @) < 8
                    target =
                        x: 0
                        y: 30
                else
                    target = 
                        x: Math.round @game.pacman.x
                        y: Math.round @game.pacman.y

            # target square to the top right in scatter mode
            when 's' then target = 
                x: 0
                y: 30

            # allow parent class to handle other modes
            else return super

        return target
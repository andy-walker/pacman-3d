class Blinky extends Ghost
    
    index: 0
    cruiseElroy: false

    constructor: ->
        
        @x         = 13.5
        @y         = 11
        @direction = 'l'
        @mode      = 'c' # enter chase mode immediately

        super

    getTargetSquare: -> 
        
        switch @mode
            
            # target closest square to pacman when in chase mode
            when 'c' then target = 
                x: Math.round @game.pacman.x
                y: Math.round @game.pacman.y
            
            # target square to the top right in scatter mode
            when 's' then target = 
                x: 25
                y: -4

            # allow parent class to handle other modes
            else return super

        return target
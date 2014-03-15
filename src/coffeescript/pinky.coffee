class Pinky extends Ghost

    index: 2

    constructor: ->
        
        @x         = 13.5
        @y         = 17
        @direction = 'r'
        @mode      = 'c'
        super


    getTargetSquare: -> 
        
        switch @mode
            
            # in chase mode, target tile 4 tiles in front of pacman - replicates targeting 
            # bug on up direction, additionally offsetting 4 tiles to the left in that case
            when 'c'
            	
            	x = @game.pacman.x
            	y = @game.pacman.y

            	switch @game.pacman.direction
            		
            		when 'l' then x -= 4
            		when 'r' then x += 4
            		when 'd' then y += 4
            		when 'u'
            			x -= 4
            			y -= 4
            
            	target = 
            		x: x
            		y: y

            # target square to the top right in scatter mode
            when 's'
            	target = 
	                x: 2
	                y: -4

            # allow parent class to handle other modes
            else return super

        return target
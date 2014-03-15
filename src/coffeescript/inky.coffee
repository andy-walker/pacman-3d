class Inky extends Ghost

    index: 1

    constructor: ->
        
        @x = 13.5
        @y = 5
        @direction = 'r'
        @mode      = 'c'
        super

    getTargetSquare: -> 
        
        switch @mode
            
            # in chase mode, use vector with Pinky as end point and offset 4 tiles in front 
            # of pacman as the centre point, target tile is the other end point of the vector.
            # replicates targeting bug on up direction, additionally offsetting 4 tiles to 
            # the left in that case
            when 'c'
            	
            	x = Math.round @game.pacman.x
            	y = Math.round @game.pacman.y

            	switch @game.pacman.direction
            		
            		when 'l' then x -= 4
            		when 'r' then x += 4
            		when 'd' then y += 4
            		when 'u'
            			x -= 4
            			y -= 4
            
            	offset_tile = 
            		x: x
            		y: y

            	pinkyX = Math.round @game.ghosts[2].x
            	pinkyY = Math.round @game.ghosts[2].y

            	pinkyOffset =
            		x: offset_tile.x - pinkyX
            		y: offset_tile.y - pinkyY

            	target = 
            		x: offset_tile.x + pinkyOffset.x
            		y: offset_tile.y + pinkyOffset.y

            # target square to the top right in scatter mode
            when 's'
            	target = 
	                x: 27
	                y: 30

            # allow parent class to handle other modes
            else return super

        return target
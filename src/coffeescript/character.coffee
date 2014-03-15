class Character
    
    dead: false
    direction: 'l'
    game: null
    x: 0
    y: 0
    minAllowedTile: 0

    canMove: (direction = @direction, x = @x, y = @y) ->
        #console.log x + ", " + y
        current = 
            x: if direction is 'l' then Math.ceil x else if direction is 'r' then Math.floor x else Math.round x
            y: if direction is 'd' then Math.floor y else if direction is 'u' then Math.ceil y else Math.round y

        switch direction

            when 'l' then return maze[current.y][current.x-1] >= @minAllowedTile
            when 'r' then return maze[current.y][current.x+1] >= @minAllowedTile
            when 'u' then return maze[current.y-1][current.x] >= @minAllowedTile
            when 'd' then return maze[current.y+1][current.x] >= @minAllowedTile

        return no 

    
    # determine whether character is changing from travelling 
    # in the x axis to the y axis, or vice-versa
    changingAxis: (newDirection) ->
        
        return yes if newDirection in ['l', 'r'] and @direction in ['u', 'd']
        return yes if newDirection in ['u', 'd'] and @direction in ['l', 'r']
        return no

    isOpposite: (direction1, direction2) ->

        return yes if direction1 is 'l' and direction2 is 'r'
        return yes if direction1 is 'r' and direction2 is 'l'
        return yes if direction1 is 'u' and direction2 is 'd'
        return yes if direction1 is 'd' and direction2 is 'u'

        return no

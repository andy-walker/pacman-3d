# todo: display class - abstract image display functionality into this class
class Renderer

    # temporary
    # currentFrame: 0

    constructor: (@game) ->
        return

    changeMode: (mode) ->
        console.log 'changeMode ' + mode
        switch mode
            when 'f'
                $('.ghost').addClass 'frightened'
                $('#g' + i).removeClass 'ghost' + i for i in [0..3]
            else 
                $('.ghost').removeClass 'frightened'
                $('#g' + i).addClass 'ghost' + i for i in [0..3]


    getFrame: (x, y, direction) ->

        #console.log 'x:' + x + ', y:' + y + ', d:' + direction

        switch direction
            
            # lookup frame for horizonal motion
            when 'r'
                
                frame = frames.h[Math.floor y][Math.floor x]

                # adjust for in-between frames
                switch x % 1

                    when 0.25 then frame++
                    when 0.5  then frame += 2
                    when 0.75 then frame += 3

            when 'l'

                frame = offset.h - frames.h[Math.floor y][Math.floor x]

                # adjust for in-between frames
                switch x % 1

                    when 0.25 then frame--
                    when 0.5  then frame -= 2
                    when 0.75 then frame -= 3


            # lookup frame for vertical motion
            when 'u'

                frame = offset.v - (frames.v[Math.ceil y][Math.floor x] - 1490)

                # adjust for in-between frames
                switch y % 1

                    when 0.25 then frame += 3
                    when 0.5  then frame += 2
                    when 0.75 then frame++

            when 'd'

                frame = frames.v[Math.ceil y][Math.floor x]

                # adjust for in-between frames
                switch y % 1

                    when 0.25 then frame -= 3
                    when 0.5  then frame -= 2
                    when 0.75 then frame--

        return frame

    
    getPillIndex: (x, y) -> frames.p[y][x]

    getStyles: (character, frameno, y = 0) ->
      
        style = if character is @game.pacman then styles.pm[frameno] else styles.g[frameno]
        return {
            "top":                 style[0]
            "left":                style[1]
            "width":               style[2]
            "height":              style[3]
            "background-position": style[4] + "px " + style[5] + "px"
            "z-index":             if y then frames.z[Math.round y] else 300
        }


    render: ->

        # lookup pacman frame number from current location then get and apply styles
        frameno = @getFrame @game.pacman.x, @game.pacman.y, @game.pacman.direction
        $('#pacman').css @getStyles(@game.pacman, frameno, @game.pacman.y)
        
        # lookup and apply styles for ghosts
        for index, ghost of @game.ghosts
            frameno = @getFrame ghost.x, ghost.y, ghost.direction
            $('#g' + index).css @getStyles(ghost, frameno, ghost.y)

        # check if pacman has collided with any pills
        if pill = @game.level.isPillCollision()
            
            # lookup index for pill we've collided with
            index = @getPillIndex pill.x, pill.y
            
            # for energizer pills, function will return a value prepended with
            # the letter 'e'
            if typeof index is 'string' and index.indexOf('e') is 0
                $(index.replace('e', '#energizer')).hide()
            else
                $('#p' + index).hide()
                $('#pr' + index).fadeOut 200
            
            # collision processed, clear the array which keeps track of collisions
            @game.level.clearPillCollisions()
            
        return


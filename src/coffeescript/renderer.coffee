# display class - abstract image display functionality into this class
class Renderer

    # temporary
    # currentFrame: 0

    styleReset: 
        width:  '1px'
        height: '1px'
        top:    0
        left:   0

    flashSpeed: 500
    flashing:   no
    flashState: off

    constructor: (@game) ->
        return


    changeMode: (mode, ghost = null) ->
        
        switch true
            
            when mode is 'd'
                frameno = @getFrame ghost.x, ghost.y, ghost.direction
                $('#g' + index + 'd').css @getStyles(ghost, frameno, ghost.y)
                $('#g' + index + 'b, #g' + index + 'c').css(@styleReset)
                return

            # when changing to frightened mode, reset main ghost sprites and apply
            # styles to frightened sprites - ideally, would like to defer this to frame 
            # render, rather than doing this in-between frames
            when mode is 'f'

                for index, ghost of @game.ghosts
                    frameno = @getFrame ghost.x, ghost.y, ghost.direction
                    $('#g' + index + 'b').css @getStyles(ghost, frameno, ghost.y)
                    $('#g' + index).css(@styleReset)

                # calculate time to wait before beginning flash sequence
                frightTime = levelSpec[@game.level.level].frightTime * 1000
                numFlashes = levelSpec[@game.level.level].numFlashes
                flashTime  = ((numFlashes * 2) - 1) * Math.round @flashSpeed / 2
                waitTime   = frightTime - flashTime

                setTimeout(
                    ( 
                        ->
                            game.renderer.flashing = yes
                            game.renderer.flashGhosts(on)

                    ),
                    if waitTime > 0 then waitTime else 0
                )

                @flashState = off

            # when changing from frightened mode to chase mode, 
            # do the above but in reverse
            when mode is 'c' and @mode is 'f'
                
                for index, ghost of @game.ghosts
                    frameno = @getFrame ghost.x, ghost.y, ghost.direction
                    $('#g' + index).css @getStyles(ghost, frameno, ghost.y)
                    $('#g' + index + 'b, #g' + index + 'c').css(@styleReset)

                @flashing   = no
                @flashState = off

        @mode = mode


    flashGhosts: (@flashState) ->
       
        if @flashing
            
            switch @flashState
                
                when on
                    
                    for index, ghost of @game.ghosts
                        frameno = @getFrame ghost.x, ghost.y, ghost.direction
                        $('#g' + index + 'c').css @getStyles(ghost, frameno, ghost.y)
                        $('#g' + index + 'b').css(@styleReset)
                    
                    timeoutFunction = -> game.renderer.flashGhosts(off)
               
                when off
                    
                    for index, ghost of @game.ghosts
                        frameno = @getFrame ghost.x, ghost.y, ghost.direction
                        $('#g' + index + 'b').css @getStyles(ghost, frameno, ghost.y)
                        $('#g' + index + 'c').css(@styleReset)
                    
                    timeoutFunction = -> game.renderer.flashGhosts(on)

            setTimeout timeoutFunction, Math.round @flashSpeed / 2                  

    
    getFrame: (x, y, direction) ->

        switch direction
            
            # lookup frame for horizontal motion
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
        
        if character is @game.pacman
            style = styles.pm[frameno]
        else if character.mode is 'd'
            style = styles.g6[frameno]
        else
            style = styles.g[frameno]

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
            
            # get selector to the active ghost div
            selector = '#g' + index + 'c' if @mode is 'f' and @flashState is on
            selector = '#g' + index + 'b' if @mode is 'f' and @flashState is off
            selector = '#g' + index if @mode isnt 'f'
            selector = '#g' + index + 'd' if ghost.mode is 'd'
            
            # lookup and apply style
            try 
                frameno = @getFrame ghost.x, ghost.y, ghost.direction
                $(selector).css @getStyles(ghost, frameno, ghost.y)
            catch e
                console.log 'frameno = ' + frameno
            

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


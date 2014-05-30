# string prototype for zero padding score
String::zeroPad = (length) ->
    string = @
    string = '0' + string while string.length < length
    string
 
# init on document ready
$(document).ready -> game.init()

# capture keypresses
$(document).keydown (e) ->
    switch e.which
        when 37, 38, 39, 40
            game.keyboardInput e.which, 1
            e.preventDefault()

$(document).keyup (e) ->
    switch e.which
        when 27, 37, 38, 39, 40
            game.keyboardInput e.which, 0
            e.preventDefault()

# why is this not a class like everything else?
game = 
    
    lives:   3
    score:   0
    hiscore: 0

    pacman: null
    ghosts: []
    
    # 3x3 matrix used to keep track of keyboard input
    input: [
        [0, 0, 0]
        [0, 0, 0]
        [0, 0, 0]
    ]

    # temp - remove
    counter: 1

    init: ->
        
        @renderer = new Renderer @
        @level    = new Level @
        @loop()

        return

    # keyboard input callback
    keyboardInput: (key, down) ->

        switch true
            when key is 27 and not down then @initLevel()
            when key is 37 then @input[1][0] = down
            when key is 38 then @input[0][1] = down
            when key is 39 then @input[1][2] = down
            when key is 40 then @input[2][1] = down


    # main game loop
    loop: ->
      
        game.renderer.render()
        game.pacman.move()
        game.ghosts[i].move() for i in [0..3]
        setTimeout game.loop, 35 

        return


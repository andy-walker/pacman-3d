$(document).ready -> game.init()

$(document).keydown (e) ->
    switch e.which
        when 37, 38, 39, 40
            game.keyboardInput e.which, 1
            e.preventDefault()

$(document).keyup (e) ->
    switch e.which
        when 37, 38, 39, 40
            game.keyboardInput e.which, 0
            e.preventDefault()

game = 
    
    lives: 3
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
        
        @initDOM()

        #@test()
        @initLevel()
        @initRenderer()
        @loop()

        return

    # initialize dom elements
    initDOM: ->

        # add main game div
        $('body').append $("<div id='game'/>")

        # environment walls
        $('#game').append $("<div id='w" + i + "'/>") for i in [1..30]

        # pills
        y   = 0
        top = 0
        
        for i in [1..240]
            
            $('#game').append $("<div id='p" + i + "' class='p'/>")
            
            # set z-index on pills by determining which row they're on
            currentTop = parseInt $('#p' + i).css 'top'

            if currentTop > top
                top = currentTop
                y++

            $('#p' + i).css 'z-index', (frames.z[y] - 1)

        # pill reflections
        $('#game').append $("<div id='pr" + i + "' class='pr'/>") for i in [1..240]

        # energizer pills
        $('#game').append $("<div id='energizer" + i + "' class='energizer'/>") for i in [1..4]

        # pacman 
        $('#game').append $('<div id="pacman"/>')

        # ghosts
        $('#game').append $('<div id="g' + i + '" class="ghost ghost' + i + '"/>') for i in [0..3]

        # life sprites
        $('#game').append $('<div id="l' + i + '" class="lives"/>') for i in [1..4]

        return

    # initialize level
    initLevel: ->

        @level = new Level @
        return

    # initialize renderer
    initRenderer: ->

        @renderer = new Renderer @
        return


    # keyboard input callback
    keyboardInput: (key, down) ->

        switch true

            when key is 37 then @input[1][0] = down
            when key is 38 then @input[0][1] = down
            when key is 39 then @input[1][2] = down
            when key is 40 then @input[2][1] = down


    # main game loop
    loop: ->
      
        game.renderer.render()
        game.pacman.move()
        game.ghosts[i].move() for i in [0..3]

        #if (!(--@level.pills))
        #   @level.up()
        setTimeout game.loop, 35 
        # @loop()
        return


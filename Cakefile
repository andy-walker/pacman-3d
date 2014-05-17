{exec} = require 'child_process'

# ANSI Terminal Colors.
bold = red = green = reset = ''
unless process.env.NODE_DISABLE_COLORS
    bold  = '\x1B[0;1m'
    red   = '\x1B[0;31m'
    green = '\x1B[0;32m'
    reset = '\x1B[0m'


# Log a message with a colour.
log = (message, color, explanation) ->
    console.log color + message + reset + ' ' + (explanation or '')

task 'compile', 'Compiles all coffeescript files in the src/ directory', ->

    exec([
        'coffee -c -j src/game.js src/coffeescript/character.coffee src/coffeescript/ghost.coffee ' +
        'src/coffeescript/blinky.coffee src/coffeescript/inky.coffee src/coffeescript/pinky.coffee ' + 
        'src/coffeescript/clyde.coffee src/coffeescript/pacman.coffee src/coffeescript/renderer.coffee ' +
        'src/coffeescript/level.coffee src/coffeescript/game.coffee src/coffeescript/data.coffee'
    ].join(' && '), (err, stdout, stderr) ->
        if err then console.log stderr.trim() else log 'done', green
    )
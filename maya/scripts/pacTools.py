import maya.cmds as cmds

# ui elements
fields = {}

# key rate - define speed of animation
# key_rate = 4

# define user interface
def UI():
    
    # delete existing window instances
    if cmds.window("pacToolsUI", exists = True):
        cmds.deleteUI("pacToolsUI")
        
    # create layout and main window
    window = cmds.window(
        "pacToolsUI",
        title    = "PacTools",
        w        = 300,
        h        = 300,
        mnb      = False,
        mxb      = False,
        sizeable = False
    )
    
    cmds.columnLayout()
    
    cmds.button(
        label   = "Build walls from curve(s)",
        w       = 290,
        h       = 50,
        command = buildWalls
    )

    cmds.intSliderGrp(
        'distance',
        field    = True, 
        label    = 'Distance', 
        minValue = 1, 
        maxValue = 15, 
        fieldMinValue = 1, 
        fieldMaxValue = 15,
        value    = 1,
        w = 290,
        cw = [50, 240]
    ) 

    cmds.intSliderGrp(
        'key_rate',
        field    = True, 
        label    = 'Key Rate', 
        minValue = 1, 
        maxValue = 10, 
        fieldMinValue = 1, 
        fieldMaxValue = 10,
        value    = 4,
        w = 290
    )

    cmds.button(
        label   = "Key Left",
        w       = 290,
        h       = 50,
        command = keyLeft
    )

    cmds.button(
        label   = "Key Right",
        w       = 290,
        h       = 50,
        command = keyRight
    )

    cmds.button(
        label   = "Key Up",
        w       = 290,
        h       = 50,
        command = keyUp
    )

    cmds.button(
        label   = "Key Down",
        w       = 290,
        h       = 50,
        command = keyDown
    )
    cmds.setParent('..')
    cmds.rowColumnLayout( numberOfColumns=2, columnAttach=(1, 'right', 0), columnWidth=[(1, 90), (2, 50)] )
    cmds.text( label='Animation Start: ' )
    cmds.intField(
        'animation_start',
        #label    = 'Animation Start', 
        minValue = 1, 
        value    = 1
    )

    cmds.text( label='Animation End: ' )
    cmds.intField(
        'animation_end',
        #label    = 'Animation End',
        minValue = 1, 
        value    = 2642
    )

    cmds.setParent('..')
    cmds.columnLayout()

    cmds.button(
        label   = "Build Pacman Animation",
        w       = 290,
        h       = 50,
        command = buildPacmanAnimation
    )

    cmds.button(
        label   = "Build Ghost Animation",
        w       = 290,
        h       = 50,
        command = buildGhostAnimation
    )

    cmds.button(
        label   = "Export Frameref Matrix...",
        w       = 290,
        h       = 50,
        command = exportFrameReference
    )

    cmds.showWindow(window)
    
    
# callback for building wall geometry from curve(s) using Bevel Plus
def buildWalls(*args):

    # define some bevel params
    bevelRadius   = 0.2
    extrudeHeight = 0.5

    # get selected item and check it is of the correct type
    selected = cmds.ls(sl=1, type='nurbsCurve', dag=1)
    
    if not selected:
        cmds.error("Please select at least one nurbs curve")
        return
    
    # iterate over selected curves
    for pathCurve in selected:
    
        # mel: bevelPlus -constructionHistory true  -normalsOutwards true  -range false  -polygon 1 -tolerance 0.01 -numberOfSides 3 -js true  -width 0.1 -depth -0.1 -extrudeDepth -0.1 -capSides 3 -bevelInside 0 -outerStyle 2 -innerStyle 0 -polyOutMethod 2 -polyOutCount 200 -polyOutExtrusionType 3 -polyOutExtrusionSamples 2 -polyOutCurveType 3 -polyOutCurveSamples 6 -polyOutUseChordHeightRatio 0 "curve76attachedCurve1";


        # build upper bevel
        cmds.bevelPlus(
            pathCurve,
            constructionHistory        = False,
            polygon                    = 1,
            numberOfSides              = 3,
            normalsOutwards            = True,
            range                      = False,
            tolerance                  = 0.01,
            joinSurfaces               = True,
            name                       = pathCurve + "WallGeometryUpper",
            width                      = bevelRadius, 
            depth                      = 0 - bevelRadius,
            extrudeDepth               = 0 - extrudeHeight, 
            capSides                   = 3,
            outerStyle                 = 2, 
            innerStyle                 = 0, 
            polyOutMethod              = 2, 
            polyOutCount               = 200, 
            polyOutExtrusionType       = 3, 
            polyOutExtrusionSamples    = 2, 
            polyOutCurveType           = 3,
            polyOutCurveSamples        = 6,
            polyOutUseChordHeightRatio = 0 
        )
    
    
        # build lower bevel
        cmds.bevelPlus(
            pathCurve,
            constructionHistory        = False,
            polygon                    = 1,
            numberOfSides              = 3,
            normalsOutwards            = True,
            range                      = False,
            tolerance                  = 0.01,
            joinSurfaces               = True,
            name                       = pathCurve + "WallGeometryLower",
            width                      = bevelRadius, 
            depth                      = bevelRadius,
            extrudeDepth               = 0, 
            capSides                   = 1,
            outerStyle                 = 5, 
            innerStyle                 = 0, 
            polyOutMethod              = 2, 
            polyOutCount               = 200, 
            polyOutExtrusionType       = 3, 
            polyOutExtrusionSamples    = 2, 
            polyOutCurveType           = 3,
            polyOutCurveSamples        = 6,
            polyOutUseChordHeightRatio = 0 
        ) 
    
def keyLeft(*args):
    
    selected = cmds.ls(sl=1, dag=1)
    if not selected:
        cmds.error("Please select an animatable object")
        return 

    distance = cmds.intSliderGrp('distance', query=True, value=True)
    key_rate = cmds.intSliderGrp('key_rate', query=True, value=True)

    currentTime = cmds.currentTime(query=True)
    cmds.currentTime(currentTime + key_rate, edit=True)

    cmds.move(0 - distance, 0, 0, r=True)
    cmds.setKeyframe()

def keyRight(*args):
    
    selected = cmds.ls(sl=1, dag=1)
    if not selected:
        cmds.error("Please select an animatable object")
        return 

    distance = cmds.intSliderGrp('distance', query=True, value=True)
    key_rate = cmds.intSliderGrp('key_rate', query=True, value=True)

    currentTime = cmds.currentTime(query=True)
    cmds.currentTime(currentTime + key_rate, edit=True)
    cmds.move(distance, 0, 0, r=True)
    cmds.setKeyframe()

def keyUp(*args):
    
    selected = cmds.ls(sl=1, dag=1)
    if not selected:
        cmds.error("Please select an animatable object")
        return 

    distance = cmds.intSliderGrp('distance', query=True, value=True)
    key_rate = cmds.intSliderGrp('key_rate', query=True, value=True)

    currentTime = cmds.currentTime(query=True)
    cmds.currentTime(currentTime + key_rate, edit=True)
    cmds.move(0, 0, 0 - distance, r=True)
    cmds.setKeyframe()

def keyDown(*args):
    
    selected = cmds.ls(sl=1, dag=1)
    if not selected:
        cmds.error("Please select an animatable object")
        return 

    distance = cmds.intSliderGrp('distance', query=True, value=True)
    key_rate = cmds.intSliderGrp('key_rate', query=True, value=True)

    currentTime = cmds.currentTime(query=True)
    cmds.currentTime(currentTime + key_rate, edit=True)
    cmds.move(0, 0, distance, r=True)
    cmds.setKeyframe()

def buildPacmanAnimation(*args):

    # get animation start and end points from ui controls
    animation_start = cmds.intField('animation_start', query=True, value=True)
    animation_end   = cmds.intField('animation_end', query=True, value=True)

    for current_time in range(animation_start, animation_end + 1):
        
        cmds.currentTime(current_time, edit=True)
        locatorPos = cmds.xform('character_locator', q=1, t=True)
        
        x = round(locatorPos[0], 2)
        z = round(locatorPos[2], 2)

        if x % 1 == 0.25 or z % 1 == 0.25 or x % 1 == 0.75 or z % 1 == 0.75:
            # half state
            cmds.xform('character_locator|pacman_body', rotation = [0, 0, -23.5])
            cmds.xform('character_locator|pacman_mouth', rotation = [0, 0, -66.5])
            cmds.setAttr('character_locator|pacman_mouth.translateY', -8.264)
            cmds.setAttr('pacman_body_controller.endSweep', 313)
        elif x % 1 == 0.5 or z % 1 == 0.5:
            # open state
            cmds.xform('character_locator|pacman_body', rotation = [0, 0, -45])
            cmds.xform('character_locator|pacman_mouth', rotation = [0, 0, -45])
            cmds.setAttr('character_locator|pacman_mouth.translateY', -8.273)
            cmds.setAttr('pacman_body_controller.endSweep', 270)

        elif x % 1 == 0 or z % 1 == 0:
            # closed state
            cmds.xform('character_locator|pacman_body', rotation = [0, 0, -2])
            cmds.xform('character_locator|pacman_mouth', rotation = [0, 0, -86])
            cmds.setAttr('character_locator|pacman_mouth.translateY', -8.273)
            cmds.setAttr('pacman_body_controller.endSweep', 356)

        else:
            assert False, "Unhandled character position"

        cmds.setKeyframe([
            'character_locator|pacman_body',
            'character_locator|pacman_mouth',
            'pacman_body_controller'
        ])

def buildGhostAnimation(*args):
    
    obj = 'ghost_body1'

    # get animation start and end points from ui controls
    animation_start = cmds.intField('animation_start', query=True, value=True)
    animation_end   = cmds.intField('animation_end', query=True, value=True)

    for current_time in range(animation_start, animation_end + 1):
        
        cmds.currentTime(current_time, edit=True)
        locatorPos = cmds.xform('character_locator', q=1, t=True)
        
        x = round(locatorPos[0], 2)
        z = round(locatorPos[2], 2)

        if x % 1 == 0.25 or z % 1 == 0.25:
            cmds.xform(obj, rotation = [0, 11.25, 0])
        elif x % 1 == 0.5 or z % 1 == 0.5:
            cmds.xform(obj, rotation = [0, 22.5, 0])
        elif x % 1 == 0.75 or z % 1 == 0.75:
            cmds.xform(obj, rotation = [0, 33.75, 0])
        elif x % 1 == 0 or z % 1 == 0:
            cmds.xform(obj, rotation = [0, 0, 0])
        else:
            assert False, "Unhandled character position"

        cmds.setKeyframe([obj])


def exportFrameReference(*args):

    # get animation start and end points from ui controls
    animation_start = cmds.intField('animation_start', query=True, value=True)
    animation_end   = cmds.intField('animation_end', query=True, value=True)

    # prompt user to select file
    filename = cmds.fileDialog2(fileMode=0, caption="Export Matrix", okCaption="Export").pop()
    
    # generate zero-filled matrix
    matrix = []
    for i in range(0, 36):
        matrix.append([0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0])

    current_frame = animation_start
    start_x = -14
    start_y = -15
    
    # assumes first frame is a keyframe, prb a bad assumption but nevermind
    
    while current_frame <= animation_end:
        
        # jump to current frame
        cmds.currentTime(current_frame, edit=True)
        
        # get locator x and y (actually z) positions
        locatorPos = cmds.xform('character_locator', q=1, t=True)
        current_tx = locatorPos[0]
        current_ty = locatorPos[2]
        
        x = 0 - int(round(start_x - current_tx))
        y = 0 - int(round(start_y - current_ty))

        # write frame no to correct position in matrix
        matrix[y][x] = int(current_frame)

        # advance current frame to next keyframe
        next_frame = cmds.findKeyframe(timeSlider=True, which='next')
        if next_frame > current_frame:
            current_frame = next_frame
        else:
            break

    # construct coffeescript matrix from internal one
    matrix_output = "["
    for line in matrix:
        matrix_output += "\n    ["
        for index, ref in enumerate(line):
            if index:
                matrix_output += ', '
            matrix_output += str(ref)#.zfill(4)
        matrix_output += "]"
    matrix_output += "\n]"

    # write to file
    with open(filename, 'w') as export_file:
        export_file.write(matrix_output)
    
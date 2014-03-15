"""
spritekit.py - Usage:

./spritekit.py <source-image> <output-image> <css-file> <base-selector> [options] 

Options:
-a --source-alpha      - image sequence to derive alpha from (if different from original)
-r --source-reflection - as above, but derive alpha from rgb channels
-e --expansion         - number of pixels to enlarge alpha map by in output
-z  --reverse           - output frames in reverse order

andyw, 26/01/2014

"""

import os, glob
import getopt, sys
import re
import math

from PIL import Image
from PIL import ImageFile
from exceptions import IOError

# things we need to know ...
source_image     = "First image in image sequence"
output_image     = "Image file to output to"
output_data_file = "CSS file to append to"
base_selector    = "Base selector for css"

# optionally define one of ..
source_alpha      = ""
source_reflection = ""

# optionally define ..
expansion = '' # number of pixels/percent to expand alpha/reflection maps by

# global vars
errors = []

# perform sprite build
def build():

    global source_image, output_image, output_data_file, base_selector
    global source_alpha, source_reflection, expansion, reverse

    # flag to tell sprite builder to use rgb values as the alpha channel
    alpha_is_rgb = False

    # check output_image extension to determine output format
    ext = output_image.split('.').pop().lower()
    if ext == 'jpg' or ext == 'jpeg':
        output_format = 'jpeg'
    elif ext == 'png':
        output_format = 'png'
    else:
        print "Unsupported output image format: %s - currently supported png and jpeg only"
        sys.exit()

    # also check output data file extension to determine what format
    # we want the data in
    ext = output_data_file.split('.').pop().lower()
    if ext in ('css', 'coffee', 'py'):
        output_data_format = ext
    else:
        print "Unsupported output data format: %s - currently supported css, coffeescript, py"
        sys.exit()       

    # find / list main source image(s) - can be a sequence of image or single image
    source_image_list = get_image_list(source_image)
    
    # find / list source alpha / source reflection image(s) - can be single or sequence
    if source_alpha or source_reflection:
        
        if source_reflection:
            alpha_is_rgb = True
            source_alpha = source_reflection

        source_alpha_list = get_image_list(source_alpha)
        
        # if source alpha specified, validate size of lists
        # either can be 1, otherwise list size must match
        parity_ok = False
        if len(source_alpha_list) == 1 or len(source_image_list) == 1:
            parity_ok = True
        elif len(source_alpha_list) == len(source_image_list):
            parity_ok = True

        if not parity_ok:
            print "Mismatch in image sequence length - source images: %d, source alpha %d" % (
                len(source_image_list), len(source_alpha_list)
            )
            sys.exit()

    else:
        source_alpha_list = source_image_list


    # prepare to build sprite

    frames  = [] # holds output image data for each frame
    offsets = [] # holds offset tuple for each frame

    # keep track of largest frame in set - will be used for 
    # calculating output sprite size
    width_total = largest_height = largest_width = 0

    frame_number_offset = int(source_image_list[0].split('.')[-2:-1].pop())

    for index, image in enumerate(source_alpha_list):
        
        print 'Processing: ' + image
        
        # open image, get size
        image         = Image.open(image)
        width, height = image.size

        # x, y iterators
        x = y = 0

        # vars to record lowest and highest non-transparent pixels
        # (req'd to perform crop)
        lo_x = width - 1
        lo_y = height - 1
        hi_x = hi_y = 0

        # iterate through pixels
        for r, g, b, a in list(image.getdata()):
            
            # if using rgb as alpha channel, detect non-black pixels
            if alpha_is_rgb:
                is_not_transparent = (r > 0 or g > 0 or b > 0)
            # if using true alpha, detect non-transparent pixels
            else:
                is_not_transparent = (a > 0)

            # if non-transparent
            if is_not_transparent:
            
                if lo_x > x:
                    lo_x = x
                if hi_x < x:
                    hi_x = x
                if lo_y > y:
                    lo_y = y
                if hi_y < y:
                    hi_y = y
            
            x = (x + 1)
            if x == width:
                y += 1
                x = 0
        
        # expand cropping area, if requested
        if expansion:
            lo_x, lo_y, hi_x, hi_y = calculate_expansion(lo_x, lo_y, hi_x, hi_y)

        # calculate dimensions of destination frame
        dst_width  = (hi_x + 1) - lo_x
        dst_height = (hi_y + 1) - lo_y

        width_total += dst_width

        if largest_height < dst_height:
            largest_height = dst_height

        if largest_width < dst_width:
            largest_width = dst_width

        # handle source image cropping - this can branch one of 3 ways, 
        # as we support 1 -> 1, 1 -> many, many -> 1, many -> many

        # if size of source_image_list is 1
        if len(source_image_list) == 1:
            # load first image and crop to source alpha
            frame = Image.open(source_image_list[0])
            frames.append(frame.crop((lo_x, lo_y, hi_x + 1, hi_y + 1)))
            offsets.append((lo_x, lo_y))

        # if many source images, but one source alpha image
        elif len(source_image_list) > 1 and len(source_alpha_list) == 1:
            # iterate through source images and crop to source alpha
            for frame_filename in source_image_list:
                frame = Image.open(frame_filename)
                frames.append(frame.crop((lo_x, lo_y, hi_x + 1, hi_y + 1)))
                offsets.append((lo_x, lo_y))
        
        # if many to many, load corresponding source image and crop to source alpha
        else:
            frame = Image.open(source_image_list[index])
            frames.append(frame.crop((lo_x, lo_y, hi_x + 1, hi_y + 1)))
            offsets.append((lo_x, lo_y))


    # write frames to a single file

    # calc best fit (but slightly bigger than we need)
    
    # output_width  = int(math.ceil(math.sqrt(width_total) + largest_width))
    # output_height = int(math.ceil(math.sqrt(width_total) + largest_height))

    output_width, output_height = get_best_dimensions(width_total, largest_height)
    output_width  += largest_width
    output_height += largest_height

    # create new image in memory at the dimensions we need, rgba, fully transparent
    master = Image.new(
        mode  = 'RGBA',
        size  = (output_width, output_height),
        color = (0, 0, 0, 0)   
    )

    # create list to hold css or script
    css    = [] 
    script = []

    # or create string to hold python data (for render cropping)
    crop = "crop = {}\n"

    # add each frame
    x = 0
    y = 0
    largest_height_in_row = 0
    output_image_basename = os.path.basename(output_image)

    # for final crop
    max_x = 0
    max_y = 0

    if reverse:
        frames.reverse()
        offsets.reverse()

    for index, image in enumerate(frames):
        
        # paste each frame to master at the correct offset
        width, height = image.size
        master.paste(image, (x, y))
        
        if max_x < x + width:
            max_x = x + width

        if max_y < y + height:
            max_y = y + height

        # also generate css in the process
        left, top = offsets[index]
        background_offset = ''
        if x:
            background_offset = '-' + str(x) + 'px '
            bg_offset_x = '-' + str(x)
        else:
            background_offset = '0 '
            bg_offset_x = 0

        if y:
            background_offset += '-' + str(y) + 'px'
            bg_offset_y = '-' + str(y)
        else:
            background_offset += '0'
            bg_offset_y = 0

        if output_data_format == 'css':
            css.append((
                base_selector + str(index + frame_number_offset),
                [
                    'top:' + str(top) + 'px',
                    'left:' + str(left) + 'px',
                    'width:' + str(width) + 'px',
                    'height:' + str(height) + 'px',
                    'background:url(images/' + output_image_basename + ') ' + background_offset
                ]
            ))

        elif output_data_format == 'coffee':
            script.append((
                str(index + frame_number_offset),
                [str(top), str(left), str(width), str(height), bg_offset_x, bg_offset_y]
            ))
        else:
            crop += "crop[" + str(index + frame_number_offset) + "] = (" + str(left) + ', ' + str(top) + ', ' + str(left + width) + ', ' + str(top + height) + ")\n"

        x += width
        
        # additions to handle multiple rows in sprite sheet .. for some reason Mozilla doesn't like 
        # 30,000 pixel wide images - IE would probably be none too impressed either - Chrome, on
        # the other hand, doesn't mind this - but we're not just targeting Chrome unfortunately

        if height > largest_height_in_row:
            largest_height_in_row = height

        if x > output_width - largest_width:
            y += largest_height_in_row
            largest_height_in_row = 0
            x = 0

    # do final crop
    master = master.crop((0, 0, max_x, max_y))

    # update output_width / output_height (for outputting dimensions)
    output_width, output_height = master.size

    # save output sprite
    if output_format == 'png':
        
        master.save(output_image, 'png')
    
    elif output_format == 'jpeg':
        # this can (and probably will) fail due to large image dimensions, but
        # increasing max block size to the size of the image should fix this
        # http://stackoverflow.com/questions/6788398
        try:
            master.save(output_image, "JPEG", quality=80, optimize=True)
        except IOError:
            ImageFile.MAXBLOCK = width_total * largest_height
            master.save(output_image, "JPEG", quality=80, optimize=True)

    else:
        assert False, "Unhandled output format '%s' during file save" % (output_format,)

    print "\nWrote %d sprites to %s (Dimensions: %dpx x %dpx)" % (
        len(frames), output_image_basename, output_width, output_height
    )

    if output_data_format == 'css':
        # append css to output css file
        output_css = ''
        for selector, definitions in css:
            output_css += selector + ' {\n'
            for definition in definitions:
                output_css += "    " + definition + ';\n'
            output_css += '}\n\n'

        with open(output_data_file, 'a') as data_file:
            data_file.write(output_css)
    
        print "Wrote %d style definitions to %s" % (len(css), os.path.basename(output_data_file))

    elif output_data_format == 'coffee':

        output_coffee = base_selector + " =\n"
        for index, definitions in script:
            output_coffee += "    %s: [%s, %s, %s, %s, %s, %s]\n" % (
                index,
                definitions[0],
                definitions[1],
                definitions[2],
                definitions[3],
                definitions[4],
                definitions[5]
            )

        with open(output_data_file, 'a') as data_file:
            data_file.write(output_coffee)
    
        print "Wrote %d style definitions to %s" % (len(script), os.path.basename(output_data_file))


    elif output_data_format == 'py':

        with open(output_data_file, 'w') as data_file:
            data_file.write(crop)

        print "Wrote %d lines to %s" % (len(crop.split("\n")), os.path.basename(output_data_file))


# apply expansion to alpha boundaries
def calculate_expansion(lo_x, lo_y, hi_x, hi_y):
    
    global expansion
    
    # if calculating expansion as a percentage
    if expansion[-1:] == '%':
        width            = (hi_x + 1) - lo_x
        height           = (hi_y + 1) - lo_y
        expansion_factor = float(expansion[:-1])
        expansion_x      = int(math.ceil(width * (expansion_factor / 100)))
        expansion_y      = int(math.ceil(height * (expansion_factor / 100)))
    # if calculating expansion as pixels
    else:
        expansion_x = expansion_y = float(expansion)

    lo_x -= expansion_x
    lo_y -= expansion_y
    hi_x += expansion_x
    hi_y += expansion_y

    print "expansion: x %d, y %d" % (expansion_x, expansion_y)

    return (lo_x, lo_y, hi_x, hi_y)


# set error
def error(message):
    errors.push(message)


# get error messages
def get_errors():
    for message in errors:
        print message + "\n"


# convert very, very rectangular images to roughly square
# dimensions with the same number of pixels
def get_best_dimensions(width, height):
 
    width = height = int(math.ceil(math.sqrt(width * height)))

    """   
    i = 2
    
    if width > height:
        while width > height:
            width = int(math.ceil(width / i))
            height *= i
            i += 1
    else:
        while height > width:
            width *= i
            height = int(math.ceil(width / i))
            i += 1
    """
    return width, height


# given path to first image, return a list of images in sequence
# or an empty list if not found
def get_image_list(first_image):

    path     = os.path.dirname(first_image)
    filename = os.path.basename(first_image)

    # if not part of sequence, return single element list
    if not re.match('^[A-Za-z0-9\-_]+\.\d+\.[A-Za-z]{3,4}', filename):
        return [first_image]

    # otherwise glob all files in sequence
    ext      = filename.split('.').pop()
    search   = '.'.join(filename.split('.')[:-2]) + '.*.' + ext
    files    = glob.glob(os.path.join(path, search))

    # sort files into numeric order
    fileDict = {}
    for entry in files:
        filename = os.path.basename(entry)
        try:
            index = int(filename.split('.')[-2:-1][0])
        except ValueError:
            # ignore any files where the index cannot be converted
            # to integer
            continue

        fileDict[index] = entry

    files = []
    for key in sorted(fileDict.iterkeys()):
        files.append(fileDict[key])

    return files


# perform general intialization here
def init():

    global source_image, output_image, output_data_file, base_selector
    global source_alpha, source_reflection, expansion, reverse

    # get command line arguments / options
    try:
        opts, args = getopt.getopt(sys.argv[1:], "harez", ["source-alpha=", "source-reflection=", "expansion=", "reverse", "help"])
    except getopt.GetoptError as err:
        # print something like "option -a not recognized" and exit
        print str(err) 
        sys.exit(2)

    try:
        source_image = args[0]
    except IndexError:
        print "Missing first argument: <source-image>"
        print __doc__
        sys.exit(2)

    try:
        output_image = args[1]
    except IndexError:
        print "Missing second argument: <output-image>"
        print __doc__
        sys.exit(2)
    
    try:
        output_data_file = args[2]
    except IndexError:
        print "Missing third argument: <css-file>"
        print __doc__
        sys.exit(2)

    try:
        base_selector = args[3]
    except IndexError:
        # 4th arg not required when outputting python
        pass
        #print "Missing fourth argument: <base-selector>"
        #print __doc__
        #sys.exit(2)

    # get options
    reverse = False

    for option, value in opts:
        if option in ('-a', '--source-alpha'):
            source_alpha = value
        elif option in ('-h', '--help'):
            print __doc__
            sys.exit()
        elif option in ('-r', '--source-reflection'):
            source_reflection = value
        elif option in ('-e', '--expansion'):
            expansion = value
        elif option in ('-z', '--reverse'):
            reverse = True
        else:
            assert False, "unhandled option"


if __name__ == "__main__":
    init()
    build()
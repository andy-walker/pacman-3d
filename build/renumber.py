import os, glob, sys

frame_path  = "C:\\dev\\src\\exported-images\\tmp2\\pacman.*.png"
start_frame = 1279
end_frame   = 2621
renumber_by = 21

if renumber_by > 0:
    frame_range = range(end_frame, start_frame - 1, -1)
elif renumber_by < 0:
    frame_range = range(start_frame, end_frame + 1)
else:
    assert False, "cannot renumber by 0"

for i in frame_range:
    source_filename = frame_path.replace('*', str(i))
    dest_filename   = frame_path.replace('*', str(i+renumber_by))
    print "moving " + source_filename + " to " + dest_filename
    os.rename(source_filename, dest_filename)


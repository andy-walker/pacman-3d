
:: build\spritekit.py src\exported-images\tmp\pacman-refl-alpha.1.png src\images\test.png src\gen.css "#pm"

:: build\spritekit.py --source-reflection=src\exported-images\pacman-refl-alpha.1.png src\exported-images\pacman-refl-alpha.1.png src\exported-images\tmp\pacman-reflection-alpha.png src\gen.py "#pm"

:: build\spritekit.py src\exported-images\pacman-fghi.1.png src\images\pm.png src\test10.coffee "pm"
:: bin\pngquant --force --verbose --speed=1 --ordered 128 src\images\pm.png

:: build\spritekit.py src\exported-images\ghost-blue.1.png src\images\g1.png src\test11.coffee "g"
:: bin\pngquant --force --verbose --speed=1 --ext=256.png --ordered 256 src\images\g2.png
:: build\spritekit.py src\exported-images\ghost-yellow.1.png src\images\g3.png src\test11.coffee "g"

:: build\spritekit.py --reverse src\exported-images\tmp\pacman.746.png src\images\pml.png src\gen.css "#pm"
:: build\spritekit.py src\exported-images\tmp\pacman.1491.png src\images\pmd.png src\test5.css "#pm"
:: build\spritekit.py --reverse src\exported-images\tmp\pacman.2067.png src\images\pmu.png src\test6.css "#pm"

:: build dark blue ghost sprite
:: build\spritekit.py src\exported-images\ghost-dblue.1.png src\images\g4.png src\test11.coffee "g"

:: build white ghost sprite
:: build\spritekit.py src\exported-images\ghost-white.1.png src\images\g5.png src\test11.coffee "g"

:: build eyes-only ghost sprite
:: build\spritekit.py src\exported-images\ghost-eyes.1.png src\images\g6.png src\test12.coffee "g6"

:: build lives sprite
:: build\spritekit.py src\exported-images\pacman-lives.1.png src\images\lives.png src\gen.css "#lives"

:: build energizer pill sprite
:: build\spritekit.py src\exported-images\energizer.1.png src\images\e.png src\gen.css "#energizer"

cake compile
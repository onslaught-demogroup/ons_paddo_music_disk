#
#MAKEFILE FOR Q!D!64!
#Copyright 2019 Zig/Defame
#
SHELL := /bin/bash

help: ## This help
	@echo -e "$$(grep -hE '^\S+:.*##' $(MAKEFILE_LIST) | sed -e 's/:.*##\s*/:/' -e 's/^\(.\+\):\(.*\)/\\x1b[36m\1\\x1b[m:\2/' | column -c2 -t -s :)"

all: clean disk2.d64  ## clean up and make the disk images

autogenerate: ## autogenerate conversion templates
	bin/convert_c.py
	bin/convert_sid.py
	bin/disk_image.py

rsrc: autogenerate ## populate the rsrc directory from autogenerated templates
	cd src;kick convert_animations.asm
	cd src;kick convert_music.asm
	bin/petscii_include.py

src/demo.prg: src/demo.asm rsrc ## compile c64 demo
	kick $<
	cd src;exomizer sfx basic -n -o packed.prg demo.prg
	cd rsrc;exomizer mem -c -l auto -o ../src/aa.prg aa.prg
	cd rsrc;exomizer mem -c -l auto -o ../src/bb.prg bb.prg
	cd rsrc;exomizer mem -c -l auto -o ../src/cc.prg cc.prg
	cd rsrc;exomizer mem -c -l auto -o ../src/dd.prg dd.prg
	cd rsrc;exomizer mem -c -l auto -o ../src/ee.prg ee.prg
	cd rsrc;exomizer mem -c -l auto -o ../src/ff.prg ff.prg
	cd rsrc;exomizer mem -c -l auto -o ../src/gg.prg gg.prg
	cd rsrc;exomizer mem -c -l auto -o ../src/hh.prg hh.prg
	cd rsrc;exomizer mem -c -l auto -o ../src/ii.prg ii.prg
	cd rsrc;exomizer mem -c -l auto -o ../src/jj.prg jj.prg
	cd rsrc;exomizer mem -c -l auto -o ../src/kk.prg kk.prg
	cd rsrc;exomizer mem -c -l auto -o ../src/ll.prg ll.prg
	cd rsrc;exomizer mem -c -l auto -o ../src/mm.prg mm.prg
	rm src/demo.prg
	mv src/packed.prg src/demo.prg

disk1.d64: src/demo.prg ## create c64 disk demo side 1
	c1541 -format "onslaught,2a" d64 $@
	c1541 -attach $@ -write src/demo.prg "start" 
	c1541 -attach $@ -write src/aa.prg "aa"
	c1541 -attach $@ -write src/bb.prg "bb"
	c1541 -attach $@ -write src/cc.prg "cc"
	c1541 -attach $@ -write src/dd.prg "dd"
	c1541 -attach $@ -write src/ee.prg "ee"
	c1541 -attach $@ -write src/ff.prg "ff"
	c1541 -attach $@ -write src/gg.prg "gg"
	c1541 -attach $@ -write src/hh.prg "hh"
	c1541 -attach $@ -write src/ii.prg "ii"
	c1541 -attach $@ -write src/jj.prg "jj"
	c1541 -attach $@ -write src/kk.prg "kk"
	c1541 -attach $@ -write src/ll.prg "ll"
	c1541 -attach $@ -write src/mm.prg "mm"

	c1541 -attach $@ -write rsrc/00.prg "00"
	c1541 -attach $@ -write rsrc/01.prg "01"
	c1541 -attach $@ -write rsrc/02.prg "02"
	c1541 -attach $@ -write rsrc/03.prg "03"
	c1541 -attach $@ -write rsrc/04.prg "04"
	c1541 -attach $@ -write rsrc/05.prg "05"
	c1541 -attach $@ -write rsrc/06.prg "06"
	c1541 -attach $@ -write rsrc/07.prg "07"
	c1541 -attach $@ -write rsrc/08.prg "08"
	c1541 -attach $@ -write rsrc/09.prg "09"
	c1541 -attach $@ -write rsrc/10.prg "10"
	c1541 -attach $@ -write rsrc/11.prg "11"
	c1541 -attach $@ -write rsrc/12.prg "12"
	c1541 -attach $@ -write rsrc/13.prg "13"
	c1541 -attach $@ -write rsrc/14.prg "14"
	c1541 -attach $@ -write rsrc/15.prg "15"
	c1541 -attach $@ -write rsrc/16.prg "16"
	c1541 -attach $@ -write rsrc/17.prg "17"
	c1541 -attach $@ -write rsrc/18.prg "18"
	c1541 -attach $@ -write rsrc/19.prg "19"
	c1541 -attach $@ -write rsrc/20.prg "20"
	c1541 -attach $@ -write rsrc/21.prg "21"
	c1541 -attach $@ -write rsrc/22.prg "22"
	c1541 -attach $@ -write rsrc/23.prg "23"
	c1541 -attach $@ -write rsrc/24.prg "24"
	c1541 -attach $@ -write rsrc/25.prg "25"
	c1541 -attach $@ -write rsrc/26.prg "26"
	c1541 -attach $@ -write rsrc/27.prg "27"
	c1541 -attach $@ -write rsrc/28.prg "28"
	c1541 -attach $@ -write rsrc/29.prg "29"
	c1541 -attach $@ -write rsrc/30.prg "30"
	c1541 -attach $@ -write rsrc/31.prg "31"
	c1541 -attach $@ -write rsrc/32.prg "32"
	c1541 -attach $@ -write rsrc/33.prg "33"
	c1541 -attach $@ -write rsrc/34.prg "34"
	c1541 -attach $@ -write rsrc/35.prg "35"
	c1541 -attach $@ -write rsrc/36.prg "36"
	c1541 -attach $@ -write rsrc/37.prg "37"
	c1541 -attach $@ -write rsrc/38.prg "38"
	c1541 -attach $@ -write rsrc/39.prg "39"
	c1541 -attach $@ -write rsrc/40.prg "40"
	c1541 -attach $@ -write rsrc/41.prg "41"
	c1541 -attach $@ -write rsrc/42.prg "42"
	c1541 -attach $@ -write rsrc/43.prg "43"

disk2.d64: disk1.d64  ## create c64 disk demo side 2
	c1541 -format "onslaught,2a" d64 $@
	c1541 -attach $@ -write rsrc/44.prg "44"
	c1541 -attach $@ -write rsrc/45.prg "45"
	c1541 -attach $@ -write rsrc/46.prg "46"
	c1541 -attach $@ -write rsrc/47.prg "47"
	c1541 -attach $@ -write rsrc/48.prg "48"
	c1541 -attach $@ -write rsrc/49.prg "49"
	c1541 -attach $@ -write rsrc/50.prg "50"
	c1541 -attach $@ -write rsrc/51.prg "51"
	c1541 -attach $@ -write rsrc/52.prg "52"
	c1541 -attach $@ -write rsrc/53.prg "53"
	c1541 -attach $@ -write rsrc/54.prg "54"
	c1541 -attach $@ -write rsrc/55.prg "55"
	c1541 -attach $@ -write rsrc/56.prg "56"
	c1541 -attach $@ -write rsrc/57.prg "57"
	c1541 -attach $@ -write rsrc/58.prg "58"
	c1541 -attach $@ -write rsrc/59.prg "59"
	c1541 -attach $@ -write rsrc/60.prg "60"
	c1541 -attach $@ -write rsrc/61.prg "61"
	c1541 -attach $@ -write rsrc/62.prg "62"
	c1541 -attach $@ -write rsrc/63.prg "63"
	c1541 -attach $@ -write rsrc/64.prg "64"
	c1541 -attach $@ -write rsrc/65.prg "65"
	c1541 -attach $@ -write rsrc/66.prg "66"
	c1541 -attach $@ -write rsrc/67.prg "67"
	c1541 -attach $@ -write rsrc/68.prg "68"
	c1541 -attach $@ -write rsrc/69.prg "69"
	c1541 -attach $@ -write rsrc/70.prg "70"
	c1541 -attach $@ -write rsrc/71.prg "71"
	c1541 -attach $@ -write rsrc/72.prg "72"
	c1541 -attach $@ -write rsrc/73.prg "73"
	c1541 -attach $@ -write rsrc/74.prg "74"
	c1541 -attach $@ -write rsrc/75.prg "75"
	c1541 -attach $@ -write rsrc/76.prg "76"
	c1541 -attach $@ -write rsrc/77.prg "77"
	c1541 -attach $@ -write rsrc/78.prg "78"
	c1541 -attach $@ -write rsrc/79.prg "79"
	c1541 -attach $@ -write rsrc/80.prg "80"
	c1541 -attach $@ -write rsrc/81.prg "81"
	c1541 -attach $@ -write rsrc/82.prg "82"
	c1541 -attach $@ -write rsrc/83.prg "83"
	c1541 -attach $@ -write rsrc/84.prg "84"
	c1541 -attach $@ -write rsrc/85.prg "85"
	c1541 -attach $@ -write rsrc/86.prg "86"
	c1541 -attach $@ -write rsrc/87.prg "87"
	c1541 -attach $@ -write rsrc/88.prg "88"
	c1541 -attach $@ -write rsrc/89.prg "89"
	c1541 -attach $@ -write rsrc/90.prg "90"
	c1541 -attach $@ -write rsrc/91.prg "91"
	c1541 -attach $@ -write rsrc/92.prg "92"
	c1541 -attach $@ -write rsrc/93.prg "93"
	c1541 -attach $@ -write rsrc/94.prg "94"
	c1541 -attach $@ -write rsrc/95.prg "95"
	c1541 -attach $@ -write rsrc/96.prg "96"
	c1541 -attach $@ -write rsrc/97.prg "97"
	c1541 -attach $@ -write rsrc/98.prg "98"
	c1541 -attach $@ -write rsrc/99.prg "99"

clean: ## Clean up
	rm -f src/*.sym src/*.prg *.d64 src/.source.txt src/convert_animations.asm src/convert_music.asm

developer log file
back to amiga
by boris posavec aka craft aka akiko of almagest (probably former almagest)


i will try to capture the development process i have traced in last couple of months. it has been my personal goal ever since 1992 to have my own demo engine, a framework capable of driving realtime graphics and sound on an amiga, accelerated or not, i never cared. my last attempt to wrap my head around amiga coding was in 2012 when i decided to go pure asm, using devpac assembler, i did it to write a short cute intro, a birthro, to my demoscene and real life friend nomo of almagest. the process was tiring, but inexplicably fun. i had to go through the amiga HRM and bunch of old LSD source codes, until i was finally able to kill the system, load and display graphics, plot some dots, configure copper gradients, etc. it took me over a month to deal with it, but i didn't regret a single second.

today i am standing in front of the similar goal, but this time, i really want to do something that matters, i want a much more sophisticated system, that will allow me to modularize development, have it fully aga compatible, include fancy routines such as c2p, be able to play any module using p61 toolkit. i have already done a lot, but i am afraid i am going to forget all of it, again. hence i decided to write down every single bit of the process, the tools i was using, emulators and their configurations, difficulties and issues i encounter, my thought processes that lead me to decisions and eventually the ideas and algorithms i come up with in the process of creation.



development environment - machine setup

install fs-uae. use bare bone wb 3.1 installation, simply create a small 64 MB partition, name it Brain or System, assign it to the first bootable slot, DH0: in fs-uae.
next, make or use an existing dropbox folder on you host machine. insert it into DH1: or the second hard disk in fs-uae. this will be your main hard disk for all the development, data exchange etc. 

my environment also includes an amibian 1.3x running on a RPI3, that has sshfs setup so that it can mount the same dropbox folder residing on my host mac machine as it's dh1 or dh2 external hard disk. this way i can instantenously test any executable binary on both rpi3 (closer to real life amiga) and emulated fs-uae station.



development environment - compiler toolchain setup

this one is a bit tricky to setup, but once you have it you will love it. it's better than anything i had on my embedded projects, or amiga back in the 90's. First you need to setup the amiga cross toolchain. it is well documented and you should have no difficulties with that. simply go to https://github.com/cahirwpz/amigaos-cross-toolchain and follow the instructions.

in my case vc, vasm and other binaries are located in /opt/local/m68k-amigaos/bin/ so add that to the $PATH env var stored in ~/.profile

create a folder in you dh1: for your first project. in that folder create the next script, name it build.sh and add executable rights to it (chmod +x), in the script of course replace all the file names to match whatever you want to build:

------------------------------------------------------------------
# compiler script for project 'demo'
vasm -devpac -Fvobj c2p_020.s -o c2p_020.o
vasm -devpac -Fvobj c2p1x1_8_c5_bm.s -o c2p1x1_8_c5_bm.o 
vasm -devpac -Fvobj c2p2x2_8_c5_bm.s -o c2p2x2_8_c5_bm.o 
vasm -devpac -Fvobj c2p2x1_8_c5_bm.s -o c2p2x1_8_c5_bm.o 
vasm -devpac -Fvobj c2p1x1_4_c5_bm.s -o c2p1x1_4_c5_bm.o 
./assemble.sh test
vc -v -cpp-comments -c99 -cpu=68020 c2p_020.o c2p1x1_8_c5_bm.o c2p2x2_8_c5_bm.o c2p2x1_8_c5_bm.o c2p1x1_4_c5_bm.o test.o assets/P61.shitstorm-rsv.c common.c copper.c aux3d.c tunnel.c copperchunky.c copperchunky_aga.c demo.c main.c -lamiga -lauto -lmieee -o demo
------------------------------------------------------------------

note that the vasm -devpac -Fvobj are used to create linkable object files. these are than added to the vc command line. 

for editing i use Sublime 3 editor on mac. you can key bind Cmd+b to invoke ./build.sh script. so, you type, you press cmd+b and you see your project baked for amiga.



development environment - advanced compilation method (using CMake)

at some point i wrote first shell then python scripts that can batch assemble and compile all the sources in the working directory, and create the output executable, using first vasm to process all *.s -> *.o files, then invoking vc with command line arguments and collected *.o and *.c files. The script is not complicated and it does the job fairly good. but i wanted to have some shared sources in a different folder, e.g. imagine this structure where intro1 is you current project:

|-- agtlib
|   |-- aux3d.c
|   |-- aux3d.h
|   |-- c2p1x1_4_c5_bm.s
|   |-- c2p1x1_8_c5_bm.s
|   |-- c2p2x1_8_c5_bm.s
|   |-- c2p2x2_8_c5_bm.s
|   |-- c2p_020.s
|   |-- common.c
|   |-- common.h
|   |-- copper.c
|   |-- copper.h
|   `-- stdafx.h
|-- intro1
|   |-- CMakeLists.txt
|   |-- P6112
|   |   |-- P6112-Play.i
|   |   |-- P6112.readme
|   |   `-- P61Con
|   |-- assets
|   |   `-- P61.shitstorm-rsv.c
|   |-- build
|   |-- kill.s
|   |-- main.c
|   `-- stdafx.h


now, imagine you want to build intro1 project, but you also want to provide .s and .c files from ../agtlib to it. this would complicate your script quite a bit, introducing new command line directives, at least. so i decided to switch to cmake, which in a couple of lines takes care of recursion and is easily capable of executing shell commands, post and pre build steps etc. The simplified cmake script looks like this:

################################################################
project(intro1)

SET(CMAKE_VERBOSE_MAKEFILE on)

add_custom_target(
	assembler
)

add_custom_command(
	TARGET assembler
	PRE_BUILD
	COMMAND echo [***] Running Assembler ..........
	COMMAND batchassembler -cd ${CMAKE_SOURCE_DIR}
	COMMAND batchassembler -cd ${CMAKE_SOURCE_DIR}/../agtlib
)

add_custom_target(
	cleaner
)

add_custom_command(
	TARGET cleaner
	COMMAND echo [***] Running Cleanup ..........
	COMMAND rm -f ${CMAKE_BINARY_DIR}/demo
	COMMAND rm -f ${CMAKE_SOURCE_DIR}/*.o
	COMMAND rm -f ${CMAKE_BINARY_DIR}/*.o
	COMMAND rm -f ${CMAKE_SOURCE_DIR}/../agtlib/*.o
)

SET(EXECUTABLE_OUTPUT_PATH ../)
SET(CMAKE_C_COMPILER vc)
SET(CMAKE_C_FLAGS "-v -cpp-comments -c99 -cpu=68020")
SET(CMAKE_EXE_LINKER_FLAGS "-lamiga -lauto -lmieee")
INCLUDE_DIRECTORIES(../agtlib)
FILE(GLOB SRC_FILES ${CMAKE_SOURCE_DIR}/*.c ${CMAKE_SOURCE_DIR}/assets/*.c ${CMAKE_SOURCE_DIR}/../agtlib/*.c ${CMAKE_SOURCE_DIR}/*.o ${CMAKE_SOURCE_DIR}/../agtlib/*.o *o *c)

ADD_EXECUTABLE(demo main.c ${SRC_FILES})
# ADD_DEPENDENCIES(demo cleaner)
ADD_DEPENDENCIES(demo assembler)
################################################################

To use it, best practice is:
# make sure your-project/../agtlib exists
$ cd your-project
$ mkdir build
$ cd build
$ cmake ..
$ make

to clean up the local cache files simply while in ./build folder invoke:
$ rm -frv *

this will still leave all the .o files in the your-project and ../agtlib/ folders, you may want to take care of them manually.



- invoking asm subroutines from c -

in asm source file you need to export the subrouting up front using this forward declaration:

	xdef	_test

in the subroutine itself you need to make sure that all the affected registers are safely storen on the stack, by movem d0-d7/a0-a7,-(sp) and then movem (sp)+,d0-d7/a0-a7 before rts. of course you don't care about d0 and d1, those are expected to be scrap registers whenever jumping to subroutine, but for any others you have to guarantee their safety.

to import a subroutine in C write this:

// ; d0.w	chunkyx [chunky-pixels]
// ; d1.w	chunkyy [chunky-pixels]
// ; d2.w	offsx [screen-pixels]
// ; d3.w	offsy [screen-pixels]
// ; a0	chunkyscreen
// ; a1	BitMap
void c2p2x2_8_c5_bm(	__reg("d0") UWORD chunkyx,
						__reg("d1") UWORD chunkyy,
						__reg("d2") UWORD offsx,
						__reg("d3") UWORD offsy,
						__reg("a0") UBYTE *chunkyscreen,
						__reg("a1") UBYTE *BitMap
	);

if an assembly subroutine has to return data to the C invoker function then we need to declare this up front like this, e.g.:
__reg("d0") ULONG c824(__reg("d0") unsigned long rgb888);

WARNING:
regarding data types, i started using the cross platform 'safe' types such as int32_t or uint32_t etc, but after some time i switched back to Amiga's native ULONG, UBYTE and alike, because vc didn't really work if you declared e.g. :
	__reg("d0") ULONG c824(__reg("d0") uint32_t rgb888); // WRONG RESULTS
instead of:
	__reg("d0") ULONG c824(__reg("d0") unsigned long rgb888); // OK




- exporting binary data -

next, if you want to export an array of bytes, or for example an linked binary file, such as module or image, you need to export the same way:

	xdef 	_eyechunky

but in C the import looks like this:

extern UBYTE eyechunky[]; // 64x64 16 col chunky

You can't do:
extern UBYTE *eyechunky; 
IT WON'T WORK.


- playing p61 mod file -

since the main engine is in C, and asm subroutines are invoked as extraneous, you have to include the module binary in C and pass it as argument to asm subroutine that will trigger the replay routine.

first, export module binary to .c file using "xxd" in shell. 
then make sure this file is linked to final demo executable in build.sh. in demo.c declare it as e.g.:

	extern unsigned char __chip assets_P61_shitstorm_rsv[];

make sure it's __chip assigned! then import asm subroutine:

	void playp61module(	__reg("a0") unsigned char *module);

why not having it incbined in asm source? well for some reason vc linker ignored the data_c directive in asm file. don't know why. it was always corrupted and i couldn't work around it other than putting it in __chip in c and passing it to asm subroutine. in general i started doing this with all files, images, palettes etc, including them or disk i/o reading them in c, and passing them as arguments to asm subroutines.


- converting mod to p61 file - 

the folder P6112, which is a standard part of agtlib collection, comes with the amiga executable P61Con that can be used withing Workbench to convert mod file to p61.


- my approach to loading images -

there are generally 2 ways to load images dynamically.
a) have them converted to binary and linked together with the executable (or a resource file).
b) have them lying on disk and then dynamically loading them using Disk I/O

i am opting for b) because it allows me to easily modify or replace images and just rerun the demo, without having to worry about rebuilding the whole executable, of course if possible to avoid that.

when loading images you can go with several formats on amiga, some of them make sense others don't. for example you don't want to load jpeg, gif or compressed png, it simply takes too much time and memory on stock 020 cpu, and below that even not to mention.
so, we need some kind of uncompressed format that is fast enough to load and prepare for either bitplane or chunky use. in my early assembler days i used to use iff master and manually convert images from iff to raw and then export copper palettes separately. but today when i work which much more complex environment i decided to use png format, and during the prebuild step convert it to 256 colors raw 888 rgb file. this file is then loaded realtime and used in the demo. 

i am using imagemagick (linux/osx) to convert png images to rgb (raw 888 chunky) files. these i load using a C function that finds all unique colors, and puts them in a color buffer. the colors are stored as 32bit with the following format: 
unsigned int rgb = b | g << 8 | r << 16;
so the highest byte is unused (reserved for alpha? or mask? we will see in future).

imagemagick command to convert a png to 8bit 256 colors raw rgb is:
convert $1 -depth 8 -colors 255 $2 # note that color 0 is reserved for background color, i don't know if this is in use at all but that's how imagemagick png works. this can also be forced otherwise, but i don't really need to tweak that.


- notes on memory management -

while writing various routines (in C) i at first for cross platform compatibility and inertia reasons was using stdlib's malloc, memcpy, memset, free functions. this worked fine for some time, but then things started happening that were very weird, for example i was able to load one rgb image, but as soon as i loaded the second image the chunky data was messed up, colors seemed randomly broken. i don't want to go too much in detail here, honestly i also forgot the exact code snippets that were in play back then. the important thing is - i rewrote all mem handling subroutines to use amiga exec's functions such as:

* AllocVec and FreeVec
* CopyMem, CopyMemQuick

even for struct allocation i switched to AllocVec, e.g. 
	ChunkyImage *img = (ChunkyImage *)AllocVec(sizeof(ChunkyImage), MEMF_CLEAR);
	// and later
	FreeVec(img);


- how i started with 3d line vectors, again - 

back in the days, around 1995, i found some blitter line drawing code that i used over and over again to render vectors. the main issue however was always  how to do calculations and rotations, projections and all that usual 3d stuff in asm, so i reverted to a stupid trick, writing them all in C and exporting the coordinates for objects, sampled at a specific time frequency, and then i asm i would just interpolate from previous frame to the currect frame, basically morphing vectors from snapshot to snapshot. today, i simply gave up on writing the vector math in asm, and i do all the calculations in C. of course at some point i decided to put the fast fetch for sin/cos LUTs and line drawing code in asm, to get max performance out of motorola, but still i must admit i am way beyond playing with assembly today, i much more would want to see a finished product than spend uncounted hours of trying to port code from c to asm. don't get me wrong, i am not denying the uber-fun behind it, just that it is so addictive, that you get lost in the maze, and the optimization and asm coding becomes to purpose to itself, while the original idea of doing something great, producing a demo or a game or whatever, slowly diminishes into oblivion.

today, in 2017, i started prototyping stuff using the fastest time to market approach: codepen, and js. Phaser, pixi.js. those things. in codepen i would simply start typing and prototyping until i was happy with the result. then i would optimize the code, bearing 68k in mind, and replacing the things i know may be expensive with luts or fakes. for example, this is a typical 3d vector cube renderer, using the most expensive code path:

* http://codepen.io/zachstronaut/pen/Ibvfr


* http://codepen.io/akiko_plays/pen/zrXdQm
dot 3d heightmap, can be easily generated from an IFF or RGB image, and rendered in c2p with colors taken from pixels


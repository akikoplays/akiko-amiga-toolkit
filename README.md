# akiko-amiga-toolkit
This is my WIP set of tools, scripts, docker configuration and similar that makes amiga coder life a hell lot easier.

EDIT:
this is the outdated version, my first attempts of creating a cross compile tool chain with some additional tools for easy linux/mac -> amiga porting. In the mean time I have developed a new one, which offers much better integration into tools, plus asset batch processing etc. I will upload it to my github in a couple of days.

Some thoughts why I decided to abandon this approach:
- no need for docker. It's slower, it's unnecessary complicated - you can easily find today tutorials how to compiule vbcc/vasm and other tools, online. Also, I am most of the time coding on mac, so docker if I want to integrate things into IDE's docker is additional complexity.
- While working on a c64 demo last year, I have decided to create the abstraction layer that is common for both x86 and 020+, in pure C (-c99). That required a new structure of the project, new make tools, and levels of separation.
- next, the original toolkit was meant for old school non/AGA amigas (stock 1200, aga nad non-aga 1200 with ACA1221 and maybe blizzard 030), but then I decided to separate the development into old school and new AGA machines. Since that moment, the framework was based on c2p and C routines, with some critical tasks done in assembly, targeting blizzard 030/50mhz, 040, 060 new AGA demo scene audience.

I will add the new framework here shortly. 

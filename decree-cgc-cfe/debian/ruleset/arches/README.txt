
######################################################################
###          Architecture specific stuff                           ###
######################################################################

 Each architecture has the following specified for it
 (a) The kernel image type (i.e. zImage or bzImage)
 (e) The build target
 (f) The location of the kernelimage source
 (g) The location of the kernelimage destination
 (h) The name of the arch specific configuration file
 Some architectures has sub architectures

 xen.mk:    handle the architecture specific variables.  
 uml.mk:    handle the architecture specific variables.  
 sparc.mk:  handle the architecture specific variables. 
 s390.mk:   handle the architecture specific variables. 
 ppc64.mk:  handle the architecture specific variables. 
 ppc.mk:    handle the architecture specific variables.  
 mipsel.mk: handle the architecture specific variables. 
 mips.mk:   handle the architecture specific variables. 
 m68k.mk:   handle the architecture specific variables. 
 m32r.mk:   handle the architecture specific variables. 
 ia64.mk:   handle the architecture specific variables. 
 i386.mk:   handle the architecture specific variables. 
 hppa.mk:   handle the architecture specific variables. 
 amd64.mk:  handle the architecture specific variables.
 alpha.mk:  handle the architecture specific variables. 

arch-tag: 47c730cd-ae8b-4047-9e06-e8f37aefa519

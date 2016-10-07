CFLAGS = -I/path_to_netcdf_installation/include -Wall -g

LFLAGS = -L/path_to_netcdf_installation/lib

LIBS =   -lnetcdf -lz -lm -lc

CC   =  gcc

OBJECTS = nctoasc.o

nctoasc.exe:   $(OBJECTS)
	$(CC) -o $@ $(LFLAGS) $(OBJECTS) $(LIBS);


clean:	
	rm *.o *.bck

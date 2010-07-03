CC = gcc -Wall
MAP_ARGS = `Magick-config --cflags` `Magick-config --ldflags --libs`

MAP : MAP.o PRE-MAP.o LOGIC.o
	$(CC) $(MAP_ARGS) $^ -o $@

.PHONY : clean

clean :
	rm -f *.o

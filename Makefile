# builds the .o files for your project

PREFIX := .
CXX := g++
CXXFLAGS := -std=c++20 -Wall -Wextra -Werror -pedantic
INCLUDE :=
STATICFLAG :=
LIBPATH :=
LIBS := -lncursesw
DYNAMIC := #-fPIC # -fPIC is needed for shared libraries

STATICLIBS :=-lncursesw -ltinfow

SRCS := $(wildcard *.cpp *.h)
OBJECTS := $(patsubst src%,obj%, $(patsubst %.c,%.o, $(patsubst %.cpp,%.o,$(SRCS))))


dynamic:
	@$(MAKE) all -j$(nproc) DYNAMIC="-fPIC" STATICLIBS=""
	g++ $(CXXFLAGS) -shared -Wl,-soname,libhikrender.so -o $(PREFIX)/libhikrender.so *.o

static:
	@if [ ! -d "ncurses-build" ]; then $(MAKE) custom_ncurses; fi
	@$(MAKE) all -j$(nproc) STATICFLAG="-static -static-libgcc" INCLUDE="-I./ncurses-build -I./ncurses-build/include/ncursesw -I./ncurses-build/include" LIBPATH="-L./ncurses-build/lib" LIBS="$(STATICLIBS)"
	ar rvs $(PREFIX)/libhikrender.a *.o ncurses-build/lib/libncursesw.a

install:
	sudo cp $(PREFIX)/libhikrender.so /usr/lib

all: $(OBJECTS)

%.o: %.cpp
	$(CXX) $(CXXFLAGS) $(STATICFLAG) $(INCLUDE) $(LIBPATH) $(LIBS) $(DYNAMIC) -c $< -o $@

clean:
	rm -f $(PREFIX)/*.o $(PREFIX)/*.so $(PREFIX)/*.a
	rm -rf ncurses-build

custom_ncurses:
	@if [ -d "ncurses-build" ]; then \
  	echo "ERROR: ncurses-build directory already exists. If you really want to build again, remove it."; \
 	exit 1; \
 	fi
	@git submodule init
	@git submodule update
	@mkdir -p ncurses-build
	@cd ncurses && \
 		./configure --prefix=$(PWD)/ncurses-build --enable-widec --with-termlib \
 		&& make -j$(nproc) \
 		&& make -j$(nproc) install

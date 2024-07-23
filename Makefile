# builds the .o files for your project

PREFIX := .
CXX := g++
CXXFLAGS := -std=c++20 -Wall -Wextra -Werror -pedantic
INCLUDE :=
STATICFLAG :=
LIBPATH :=
LIBS := -lncursesw
DYNAMIC := #-fPIC # -fPIC is needed for shared libraries

ifeq ($(shell ldconfig -p | grep tinfo > /dev/null; echo $$? ),0)
STATICLIBS :=-lncursesw -ltinfo
else
STATICLIBS :=-lncursesw -ltinfow
endif

SRCS := $(wildcard *.cpp *.h)
OBJECTS := $(patsubst src%,obj%, $(patsubst %.c,%.o, $(patsubst %.cpp,%.o,$(SRCS))))


dynamic: $(OBJECTS)
	g++ $(CXXFLAGS) -shared -Wl,-soname,libhikrender.so -o $(PREFIX)/libhikrender.so *.o

static: $(OBJECTS)
	@if [ ! -d "ncurses-build" ]; then $(MAKE) custom_ncurses; fi
	@$(MAKE) all -j$(nproc) STATICFLAG="-static -static-libgcc" INCLUDE="-I$(PWD)/ncurses-build" LIBPATH="-L$(PWD)/ncurses-build/lib" LIBS="$(STATICLIBS)"
	ar rvs $(PREFIX)/libhikrender.a *.o ncurses-build/lib/libncursesw.a

install:
	sudo cp $(PREFIX)/libhikrender.so /usr/lib

all: $(OBJECTS)

%.o: %.cpp
	$(CXX) $(CXXFLAGS) $(STATICFLAG) $(INCLUDE) $(LIBPATH) $(LIBS) $(DYNAMIC) -c $< -o $@

clean:
	rm -f $(PREFIX)/*.o $(PREFIX)/*.so $(PREFIX)/*.a

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

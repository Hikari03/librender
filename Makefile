# builds the .o files for your project

PREFIX := .
CXX := g++
CXXFLAGS := -std=c++20 -Wall -Wextra -Werror -pedantic
DYNAMIC := #-fPIC # -fPIC is needed for shared libraries

SRCS := $(wildcard *.cpp *.h)
OBJECTS := $(patsubst src%,obj%, $(patsubst %.c,%.o, $(patsubst %.cpp,%.o,$(SRCS))))

all: dynamic static

dynamic: $(OBJECTS)
	g++ $(CXXFLAGS) -shared -Wl,-soname,libhikrender.so -o $(PREFIX)/libhikrender.so *.o

static: $(OBJECTS)
	ar rvs $(PREFIX)/libhikrender.a *.o

install:
	sudo cp $(PREFIX)/libhikrender.so /usr/lib

%.o: %.cpp
	$(CXX) $(CXXFLAGS) $(DYNAMIC) -c $< -o $@

clean:
	rm -f $(PREFIX)/*.o $(PREFIX)/*.so $(PREFIX)/*.a

# builds the .o files for your project

PREFIX := .
CXX := g++
CXXFLAGS := -std=c++20 -Wall -Wextra -Werror -pedantic

SRCS := $(wildcard *.cpp *.h)
OBJECTS := $(patsubst src%,obj%, $(patsubst %.c,%.o, $(patsubst %.cpp,%.o,$(SRCS))))

all: $(OBJECTS)
	g++ $(CXXFLAGS) -shared -Wl,-soname,libhikrender.so -o $(PREFIX)/libhikrender.so *.o

install:
	sudo cp $(PREFIX)/libhikrender.so /usr/lib

%.o: %.cpp
	$(CXX) $(CXXFLAGS) -fPIC -c $< -o $@

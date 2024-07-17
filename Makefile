# builds the .o files for your project

PREFIX := .
CXX := g++
CXXFLAGS := -std=c++20 -Wall -Wextra -Werror -pedantic

SRCS := $(wildcard *.cpp *.h)
OBJECTS := $(patsubst src%,obj%, $(patsubst %.c,%.o, $(patsubst %.cpp,%.o,$(SRCS))))

all: $(OBJECTS)
	mkdir -p $(PREFIX)/obj
	mv *.o $(PREFIX)/obj

%.o: %.cpp
	$(CXX) $(CXXFLAGS) $(INCLUDE) -c $< -o $@

clean:
	rm -rf obj
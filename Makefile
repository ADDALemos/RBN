CXX        = g++
CFLAGS     =  -Wall -O2 -std=c++11 -Wno-sign-compare
LDFLAGS    =
BOOST_PATH = /usr
INCLUDES   = -I $(BOOST_PATH)/include/
LIBS       = -L $(BOOST_PATH)/lib -lboost_regex -lboost_program_options
TARGET     = converter
OBJS       = main.o function/functionLine.o function/functionMain.o function/vertex.o minimize/start.o minimize/quine_mccluskey.o results.o

all:     $(TARGET)
rebuild: clean all

$(TARGET): $(OBJS)
	$(CXX) $(LDFLAGS) -o $@ $(OBJS) $(LIBS)

clean:
	rm -f $(TARGET) $(OBJS) *~ \#*

.cpp.o:
	$(CXX) $(CFLAGS) $(INCLUDES) -c $< -o $@


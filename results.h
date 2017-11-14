//
// Created by alexandre on 11/10/16.
//

#ifndef CONVERTER_RESULTS_H
#define CONVERTER_RESULTS_H
#include <iostream>
#include <fstream>
#include <vector>
#include <cstring>

class results {

private:
    long double time;
    long double cpu;
    bool sat;
    unsigned int repairs;
    unsigned int sol;
    bool optimal;
public:
    void print(std::string file);
    results();
    results(long double time,long double cpu,bool sat, unsigned int repairs, unsigned int sol, bool optimal);



};


#endif //CONVERTER_RESULTS_H

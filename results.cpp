//
// Created by alexandre on 11/10/16.
//

#include "results.h"

void results::print(std::string file){
    std::ofstream myfile(file+".data");
    myfile<<"Time:"<<results::time;
    myfile<<"\nCPU:"<<results::cpu;

    myfile<<"\nSAT:"<<(results::sat?"true":"false");
    myfile<<"\nOptimal:"<<(results::optimal?"true":"false");
    myfile<<"\n#Repairs:"<<results::repairs;
    myfile<<"\n#Optimal Solutions:"<<results::sol;
    myfile.close();
}

results::results() {}
results::results(long double time,long double cpu,bool sat, unsigned int repairs, unsigned int sol, bool optimal) : time(time),cpu(cpu), sat(sat),repairs(repairs), sol(sol), optimal(optimal) {}

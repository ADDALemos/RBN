#include <boost/algorithm/string.hpp>
#include <iostream>
#include <fstream>
#include <vector>
#include <cstring>
#include <map>
#include <chrono>
#include <set>
#include <random>
#include <sstream>
#include "function/vertex.h"
#include "function/functionLine.h"
#include "results.h"
#include "function/functionMain.h"
#include <algorithm>    // std::min
std::string outnode;
std::string outfile;
std::map<std::string,functionLine> fun;
std::map<std::string, functionMain> fMain;
void randomA();
results *data;
std::vector<std::string> datasets;
int lines=0;
bool asy,stdy,flag;//true for asynchronous; false for synchronous


void readNodes(std::string file);

void readInput(std::string file);

void generateEncoding(std::string r,std::string model,std::string obs);

void readInputObs(std::string file);

std::string &getString(std::string &temp);

void help();

bool isRepair(std::string repair);

void sortFunction(std::string file);

void readOutfile();

void writeResults();

//Repair Struct OBS
int main(int argc, char *argv[]) {

    if(argc==3){
        std::string temp="h";
        if(!temp.compare(argv[1])){
            help();
        }

    }

    if (argc<=3 ){
        help();
    }
    if(argc>3) {
        std::string temp="asynchronous";
        std::string temp1="steady";
        if(temp.compare(argv[1])==0){
            asy=true;
            stdy= false;
        } else if(temp1.compare(argv[1])==0){
            asy=false;
            stdy=true;
        } else {
            asy=false;
            stdy=false;
        }
        readInput(argv[3]);
        outfile=argv[3];

    }
    flag=false;

    std::string obs=" ";
    std::string flagn="-n";
    for(int i=4;i<argc;i++) {
        if(flagn.compare(argv[i])){
            readInputObs(argv[i]);
            obs+=argv[i];
            outfile=argv[4]+std::to_string(argc-4);
            obs+=".lp ";
        } else{
            std::vector<std::string> d;
            flag=true;
            i++;
            std::string t=argv[i];
            boost::split(d,t,boost::is_any_of("/"));
            outfile+=d[d.size()-1];
            outnode=d[d.size()-1];

            readNodes(argv[i]);
        }
    }
    if(argc<4 || (argc==4 && flag)){
        std::string file=argv[3];
        file=file+".obs.lp";
        obs=file;
        std::ofstream ofstream(file);
        ofstream<<"exp(p).";
        ofstream.close();
    }
    outfile+=argv[2];
    outfile+=".out";
    if(argc>=3){
        if(isRepair(argv[2])){
            std::string model=argv[3];
            model+= ".lp";

            //randomA();
            //return 0;

            sortFunction(argv[3]);

            generateEncoding(argv[2], model,obs);

        } else {
            help();
        }
    }
    readOutfile();
    writeResults();
    return 0;
}

void writeResults() {
    data->print(outfile);
    std::string comand ="rm "+ outfile;
    // std::system(comand.c_str());


}

void readOutfile() {
    std::ifstream myfile(outfile);
    long double time,cpu;
    bool state=false;
    bool optimal;
    unsigned int repairs, sol=0;
    std::string line;
    if (myfile.is_open()) {
        size_t pos = 0;
        while (getline(myfile, line)) {
            if (line.substr(0, 5).compare("UNSAT") == 0) {
                std::cout << "No repair was found"<<std::endl;
                exit(1);
            }
            if (line.substr(0, 6).compare("repair") == 0) {
                state=true;
                line.erase(0, 7);
                if (line.substr(0, 12).compare("functionAnd(") == 0) {
                    pos = line.find(",");
                    line.erase(0, pos + 1);
                    pos = line.find(")");
                    //andF.push_back(line.substr(0, pos));
                    std::map<std::string, functionMain>::iterator it;
                    if ((it = fMain.find(line.substr(0, pos))) == fMain.end()) {
                        //      std::cout << "opsA\n";
                    } else {
                        it->second.repairAND();
                    }
                    line.erase(0, pos + 2);

                }
                if (line.substr(0, 11).compare("functionOr(") == 0) {
                    pos = line.find(",");
                    line.erase(0, pos + 1);
                    pos = line.find(")");
                    //orF.push_back(line.substr(0, pos));
                    std::map<std::string, functionMain>::iterator it;
                    if ((it = fMain.find(line.substr(0, pos))) == fMain.end()) {
                        //    std::cout << "opsO\n";
                    } else {
                        it->second.repairOR();
                    }
                    line.erase(0, pos + 2);
                }
                //removeEdge
                if (line.substr(0, 6).compare("rEdge(") == 0) {
                    line.erase(0, 6);
                    pos = line.find(",");
                    std::string ori = line.substr(0, pos);
                    line.erase(0, pos + 1);
                    pos = line.find(")");
                    //edge.push_back(std::pair<std::string, std::string>(ori, line.substr(0, pos)));
                    std::map<std::string, functionMain>::iterator it;
                    if ((it = fMain.find(line.substr(0, pos))) == fMain.end()) {
                        //  std::cout << "opsRE\n";
                    } else {
                        it->second.remove(ori);
                    }
                    line.erase(0, pos + 2);
                }
                //regulator
                if (line.substr(0, 10).compare("regulator(") == 0) {
                    line.erase(0, 10);
                    pos = line.find(",");
                    std::string s = line.substr(0, pos);
                    line.erase(0, pos + 1);
                    pos = line.find(")");
                    //reg.insert(std::pair<std::string,std::string>(s,line.substr(0, pos)));
                    std::map<std::string, functionMain>::iterator it;
                    if ((it = fMain.find(s)) == fMain.end()) {
                        // std::cout <<s<< " opsR\n";
                    } else {
                        it->second.changeRegSign(line.substr(0, pos));
                    }
                    line.erase(0, pos + 2);
                }
            }
            if(line.find("repair")!=std::string::npos) {
                while ((pos = line.find(" ")) != std::string::npos) {
                    line.erase(0, pos + 1);

                    if (line.substr(0, 6).compare("repair") == 0) {
                        line.erase(0, 7);
                        if (line.substr(0, 12).compare("functionAnd(") == 0) {
                            pos = line.find(",");
                            line.erase(0, pos + 1);
                            pos = line.find(")");
                            std::map<std::string, functionMain>::iterator it;
                            if ((it = fMain.find(line.substr(0, pos))) == fMain.end()) {
                                // std::cout << "opsA1\n";
                            } else {
                                it->second.repairAND();
                            }
                            line.erase(0, pos + 2);

                        }
                        if (line.substr(0, 11).compare("functionOr(") == 0) {
                            pos = line.find(",");
                            line.erase(0, pos + 1);
                            pos = line.find(")");
                            //orF.push_back(line.substr(0, pos));
                            std::map<std::string, functionMain>::iterator it;
                            if ((it = fMain.find(line.substr(0, pos))) == fMain.end()) {
                                //      std::cout << "opsO1\n";
                            } else {
                                it->second.repairOR();
                            }
                            line.erase(0, pos + 2);
                        }
                        //removeEdge
                        if (line.substr(0, 6).compare("rEdge(") == 0) {
                            line.erase(0, 6);
                            pos = line.find(",");
                            std::string ori = line.substr(0, pos);
                            line.erase(0, pos + 1);
                            pos = line.find(")");
//                         edge.push_back(std::pair<std::string, std::string>(ori, line.substr(0, pos)));
                            std::map<std::string, functionMain>::iterator it;
                            if ((it = fMain.find(line.substr(0, pos))) == fMain.end()) {
                                //      std::cout << line.substr(0, pos) << "opsRe1\n";
                            } else {
                                it->second.remove(ori);
                            }

                            line.erase(0, pos + 2);
                        }
                        //regulator
                        if (line.substr(0, 10).compare("regulator(") == 0) {
                            line.erase(0, 10);
                            pos = line.find(",");
                            std::string s = line.substr(0, pos);
                            line.erase(0, pos + 1);
                            pos = line.find(")");
                            // reg.insert(std::pair<std::string,std::string>(s,line.substr(0, pos)));
                            std::map<std::string, functionMain>::iterator it;
                            if ((it = fMain.find(s)) == fMain.end()) {
                                //  std::cout << s << "opsR1\n";
                            } else {
                                it->second.changeRegSign(line.substr(0, pos));
                            }
                            line.erase(0, pos + 2);

                        }
                    } else {
                        line.erase(0, pos);

                    }


                }
            }
            if(state) {
                std::string temp=outfile+std::to_string(sol);
                typedef std::map<std::string, functionMain>::iterator it_type;
                for (it_type iterator = fMain.begin(); iterator != fMain.end(); iterator++) {
                    iterator->second.NET(temp);
                }
                state=false;
                sol++;
            }

            if ((pos = line.find("Optimum")) != std::string::npos) {
                line.erase(0, pos+7+6);

                if(line.substr(0,3).compare("yes")==0){
                    optimal=true;
                } else{
                    optimal=false;
                }

            }
            if ((pos = line.find("Optimization :")) != std::string::npos) {
                line.erase(0, pos+15);
                repairs=std::stoul(line);


            }
            if ((pos = line.find("Time         :")) != std::string::npos) {
                line.erase(0, pos+4+11);
                pos=line.find("s");
                line.erase(pos,line.size());
                time=std::stold(line);


            }
            if ((pos = line.find("CPU Time")) != std::string::npos) {
                line.erase(0, pos+8+7);
                pos=line.find("s");
                line.erase(pos,line.size());
                cpu=std::stold(line);

            }

        }


    }
    data=new results(time,cpu, true,repairs,sol, optimal);
}

void sortFunction(std::string file) {
    int temp=0;
    if(asy) {
        std::ofstream outfile;
        outfile.open(file + ".lp", std::ios_base::app);
        outfile << "#program check(t).\n"
                ":-query(t),t!="<<(lines)<<".\n";    }
    std::map<std::string, functionMain>::iterator it;
    for(it=fMain.begin(); it !=fMain.end();it++){
        it->second.setFile(file);
        it->second.setTempN(temp);
        it->second.minimize(asy);
        temp=it->second.getTempN();
    }
}

bool isRepair(std::string repair) {
    if (!repair.compare("e")||!repair.compare("i")||!repair.compare("g")||!repair.compare("eg")||!repair.compare("ei")||
        !repair.compare("gi")||!repair.compare("egi")){
        return true;
    }
    return false;
}

void help() {
    std::cout << "For help press h\n Run the program like ./program [A]Synchronous/Steady Active_Repair Moldel.net [optional] Obs1 .. Obs2 [optional] -n List of Nodes\n"
            "The Active_Repair can be e - for removing edges; g - for changing a function AND/OR;"
            " i - for negating a regulator; All possible combination. (in Alphabetical order)\n "
            "The model has to be encoded in the Boolsim format\n"
            "The list of nodes where repair operations can be applied. A file with the nodes separated by a space\n";
    std::exit(0);
}

void readInputObs(std::string file) {
    std::ifstream myfile(file);
    std::ofstream ofstream(file+".lp");
    std::string line;
    std::string token=file;

    ofstream << "exp(" << getString(file) << ")." << std::endl;

    if (myfile.is_open()) {

        getline(myfile, line);// first line
        size_t pos = 0;
        while ((pos = line.find("\t")) != std::string::npos) {
            std::string temp = line.substr(0, pos);
            if (temp.size() == 0) {
                line.erase(0, pos);
            } else {
                temp = getString(temp);
                datasets.push_back(temp);
                // ofstream << "exp(" << temp << ")." << std::endl;

            }
            line.erase(0, pos + 1);
        }
        //  std::transform(line.begin(), line.end(), line.begin(), ::tolower);
        line = getString(line);

        datasets.push_back(line);
        //ofstream << "exp(" << line <<")." <<std::endl;
        int localline=0;
        while (getline(myfile, line)) {
            int i=0;

            pos = line.find("\t");
            std::string temp = line.substr(0, pos);
            std::string name = getString(temp);
            line.erase(0, pos + 1);
            while ((pos = line.find("\t")) != std::string::npos) {
                temp = line.substr(0, pos);
                if(temp[temp.size()-1] == '\n') {
                    temp.erase(temp.size()-1,temp.size());
                }
                if(temp[temp.size()-1] == '\r') {
                    temp.erase(temp.size()-1,temp.size());
                }
                if( temp.size() !=0) {
                    ofstream << "obs_vlabel(" << getString(token) << "," << name << "," << temp <<","<<i<< ")." << std::endl;
                    i++;
                    localline++;


                }
                line.erase(0, pos + 1);



            }
            if( line.size() !=0) {
                if(line.size()>1) {
                    if (line[line.size() - 1] == '\n') {
                        line.erase(line.size() - 1, line.size());
                    }
                    if (line[line.size() - 1] == '\r') {
                        line.erase(line.size() - 1, line.size());
                    }
                }
                if(line[0]!='\n'&&line[0]!='\r'){
                    localline++;
                    ofstream << "obs_vlabel(" << getString(token) << "," << name << "," << line <<","<<i<< ")." << std::endl;


                }
            }

        }
        lines=localline;


    }
    ofstream.close();
}

std::string &getString(std::string &temp) {
    while(temp[0] == ' ') {
        temp.erase(0,1);
    }
    while(temp[temp.size()-1] == ' ') {
        temp.erase(temp.size()-1,temp.size());
    }

    if(temp[temp.size()-1] == '\n') {
        temp.erase(temp.size()-1,temp.size());
    }
    if(temp[temp.size()-1] == '\r') {
        temp.erase(temp.size()-1,temp.size());
    }
    if(temp[0] != '\"'){
        std::string ch="\"";
        ch.append(temp);
        temp=ch;
    }
    if(temp[temp.size()-1] != '\"'){
        temp.append("\"");
    }

    return temp;
}
std::set<std::string> nodesS;

void readInput(std::string file) {
    std::ifstream myfile(file);
    std::string line;


    if (myfile.is_open()) {
        while (getline(myfile, line)) {
            size_t pos = 0;
            bool nand = false;
            pos = line.find("->");
            if (pos == std::string::npos) {
                pos = line.find("-|");
                nand = true;
            }
            if (pos != std::string::npos) {
                std::string rightside = line.substr(0, pos);
                size_t posr = 0;
                std::vector<vertex> neg;
                std::vector<vertex> posi;
                std::string temp;
                std::string token;
                vertex v;
                std::map<std::string, vertex>::iterator it;
                while ((posr = rightside.find("&")) != std::string::npos) {
                    token = rightside.substr(0, posr);
                    if (token.find("^") != std::string::npos) {
                        temp = token.erase(0, 1);
                        temp = getString(temp);
                        v = vertex(temp);
                        nodesS.insert(temp);

                        neg.push_back(v);
                    } else {
                        temp = getString(token);
                        nodesS.insert(temp);


                        v = vertex(temp);
                        posi.push_back(v);


                    }
                    rightside.erase(0, posr + 1);


                }
                if (rightside.find("^") != std::string::npos) {
                    temp = rightside.erase(0, 1);
                    temp = getString(temp);
                    v = vertex(temp);

                    nodesS.insert(temp);

                    neg.push_back(v);
                } else {
                    temp = rightside;
                    temp = getString(temp);
                    v = vertex(temp);

                    nodesS.insert(temp);

                    posi.push_back(v);

                }

                line.erase(0, pos + 2);
                if (!nand) {
                    std::string getstring = getString(line);
                    nodesS.insert(getstring);
                    functionLine f = functionLine(posi, neg, getstring);
                    fun.insert(std::pair<std::string,functionLine>(getstring,f));
                    std::map<std::string,functionMain>::iterator it;
                    if((it=fMain.find(getstring))==fMain.end()){
                        functionMain fm = functionMain();
                        fm.addF(f);
                        fMain.insert(std::pair<std::string,functionMain>(getstring,fm));
                    } else {
                        it->second.addF(f);
                    }

                } else {
                    for (int i = 0; i < posi.size(); i++) {
                        std::vector<vertex> temp;
                        std::string getstring = getString(line);
                        nodesS.insert(getstring);
                        temp.push_back(posi.at(i));
                        functionLine f = functionLine(std::vector<vertex>(), temp, getstring);
                        fun.insert(std::pair<std::string,functionLine>(getstring,f));
                        std::map<std::string,functionMain>::iterator it;
                        if((it=fMain.find(getstring))==fMain.end()){
                            functionMain fm = functionMain();
                            fm.addF(f);
                            fMain.insert(std::pair<std::string,functionMain>(getstring,fm));
                        } else {
                            it->second.addF(f);
                        }



                    }
                    for (int i = 0; i < neg.size(); i++) {
                        std::vector<vertex> temp;
                        std::string getstring = getString(line);
                        nodesS.insert(getstring);
                        temp.push_back(neg.at(i));
                        functionLine f = functionLine(temp, std::vector<vertex>(), getstring);
                        fun.insert(std::pair<std::string,functionLine>(getstring,f));
                        std::map<std::string,functionMain>::iterator it;
                        if((it=fMain.find(getstring))==fMain.end()){
                            functionMain fm = functionMain();
                            fm.addF(f);
                            fMain.insert(std::pair<std::string,functionMain>(getstring,fm));
                        } else {
                            it->second.addF(f);
                        }

                    }
                }
            }
        }


    }
}
void generateEncoding(std::string r,std::string model,std::string obs) {
    std::string comand = "./clingo --opt-mode=optN -c repair=" + r;
    if(asy){
        comand += " ASP/configA.gringo ASP/core.lp ";

    } else {
        comand +=  " ASP/config.gringo ASP/core.lp ";

    }
    if(stdy)
        comand += " ASP/steady.lp ";
//    std::cout<<model<<" "<<obs<<"\n";

    if(flag){


        comand += " "+outnode+".lp ";
	}
    std::cout<<outnode<<std::endl;
    comand = comand + model + " " + obs;
    comand += ">" + outfile;

    std::system(comand.c_str());


}

void readNodes(std::string file){
    std::ifstream myfile;
    std::string line;

    myfile.open (file);



    if (!myfile.is_open()) return;
    std::ofstream outfile (outnode+".lp");



    std::string word;
    while (myfile >> word) {
        outfile << "repairable(" + getString(word) + ")." << std::endl;

    }

    outfile.close();



}
void randomA(){
    unsigned int t =std::chrono::steady_clock::now().time_since_epoch().count();
    std::ofstream out;

    out.open("seed.txt", std::ios::app);


    out << t<<std::endl;

    std::default_random_engine generator(t);
    std::uniform_int_distribution<int> distribution(0,nodesS.size()-1);
    std::set<int> number;
    int n=0;

    for(; number.size()< floor(0.50*nodesS.size());){
        n=distribution(generator);
        number.insert(n);



    }
    int i=0;
    for(std::string s : nodesS) {
        if(number.find(i)!=number.end())
            std::cout<<s<<std::endl;
        i++;
    }



}
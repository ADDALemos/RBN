
#include <iostream>
#include <fstream>
#include <vector>
#include <cstring>
#include <map>
#include <sstream>
#include "function/vertex.h"
#include "function/functionLine.h"
#include "results.h"
#include "function/functionMain.h"

std::string outfile;
std::map<std::string,functionLine> fun;
std::map<std::string, functionMain> fMain;

results *data;
std::vector<std::string> datasets;


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
    if(argc==2){
        std::string temp="h";
        if(!temp.compare(argv[1])){
            help();
        }

    }

    if (argc<=2 ){
        help();
    }
    if(argc>2) {
        readInput(argv[2]);
        sortFunction(argv[2]);
        outfile=argv[2];

    }
    std::string obs=" ";
    for(int i=3;i<argc;i++) {
        readInputObs(argv[i]);
        obs+=argv[i];
        outfile=argv[3]+std::to_string(argc-3);
        obs+=".lp ";
    }
    if(argc<4){
        std::string file=argv[2];
        file=file+".obs.lp";
        obs=file;
        std::ofstream ofstream(file);
        ofstream<<"exp(p).";
        ofstream.close();
    }
    outfile+=argv[1];
    outfile+=".out";
    if(argc>=2){
        if(isRepair(argv[1])){
            std::string model=argv[2];
            model+= ".lp";
            generateEncoding(argv[1], model,obs);

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
                        std::cout << "opsA\n";
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
                        std::cout << "opsO\n";
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
                        std::cout << "opsRE\n";
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
                        std::cout <<s<< " opsR\n";
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
                                std::cout << "opsA1\n";
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
                                std::cout << "opsO1\n";
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
                                std::cout << line.substr(0, pos) << "opsRe1\n";
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
                                std::cout << s << "opsR1\n";
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
    std::map<std::string, functionMain>::iterator it;
    for(it=fMain.begin(); it !=fMain.end();it++){
        it->second.setFile(file);
        it->second.setTempN(temp);
        it->second.minimize();
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
    std::cout << "For help press h\n Run the program like ./program Active_Repair Moldel.net [optional] Obs1 .. Obs2\n"
                    "The Active_Repair can be e - for removing edges; g - for changing a function AND/OR;"
                    " i - for negating a regulator; All possible combination. (in Alphabetical order)\n "
                    "The model has to be encoded in the Boolsim format\n";
    std::exit(0);
}

void readInputObs(std::string file) {
    std::ifstream myfile(file);
    std::ofstream ofstream(file+".lp");
    std::string line;
    std::istringstream iss(file);
    std::string token;
    while (std::getline(iss, token, '.')) {
        if (!token.empty()){
            ofstream << "exp(" << getString(token) << ")." << std::endl;
            break;

        }
    }

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
                if(line[0]!='\n'&&line[0]!='\r')
                    ofstream << "obs_vlabel(" << getString(token) << "," << name << "," << line <<","<<i<< ")." << std::endl;
            }

        }

    }
    ofstream.close();
}

std::string &getString(std::string &temp) {
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
                        neg.push_back(v);
                    } else {
                        temp = getString(token);


                        v = vertex(temp);
                        posi.push_back(v);


                    }
                    rightside.erase(0, posr + 1);


                }
                if (rightside.find("^") != std::string::npos) {
                    temp = rightside.erase(0, 1);
                    temp = getString(temp);
                    v = vertex(temp);
                    neg.push_back(v);
                  } else {
                    temp = rightside;
                    temp = getString(temp);
                    v = vertex(temp);
                    posi.push_back(v);

                }

                line.erase(0, pos + 2);
                if (!nand) {
                    std::string getstring = getString(line);

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

    std::string comand="./clingo -n 0 -c repair="+r+" ASP/config.gringo ASP/core.gringo ";
    comand=comand+model+" "+obs;
    comand+= ">"+ outfile;
    std::system(comand.c_str());


}


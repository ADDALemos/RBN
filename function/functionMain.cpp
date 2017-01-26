//
// Created by alexandre on 10/16/16.
//

#include <map>
#include <fstream>
#include "functionMain.h"
#include "../minimize/start.h"


functionMain::functionMain() {}
functionMain::functionMain(const std::vector<functionLine> &f,std::string file, int tempN) : f(f), file(file), tempN(tempN) {}


const std::vector<functionLine> &functionMain::getF() const {
    return f;
}

void functionMain::addF(functionLine f){
    functionMain::f.push_back(f);
}
void functionMain::setF(const std::vector<functionLine> &f) {
    functionMain::f = f;
}
void functionMain::setFile(const std::string file) {
    functionMain::file = file;
}
void functionMain::setTempN(int tempN) {
    functionMain::tempN = tempN;
}

void functionMain::minimize(bool asy) {
    std::vector<int> orVal;
    std::vector<std::string> term;
    std::vector<functionLine> l;
    std::map<std::string, std::string> map;
    std::pair<std::map<std::string, std::string>, char> temp;
    vertex dest = f[0].getDest();
    char letter = ':';
    for (int i = 0; i < functionMain::f.size(); i++) {

        temp = f[i].mapping(map, letter);
        letter = temp.second;
        map = temp.first;
    }
    for (int i = 0; i < functionMain::f.size(); i++) {
        term.push_back(f[i].functionWrite(map));
    }
    int size = letter - ':';

    vector<vector<std::string>> r = start(term, size);

    for (int i = 0; i < r.size(); i++) {
        std::vector<vertex> originPos;
        std::vector<vertex> originNeg;

        for (int y = 0; y < r[i].size(); y++) {
            typedef std::map<std::string, std::string>::iterator it_type;
            for (it_type iterator = map.begin(); iterator != map.end(); iterator++) {
                if (r[i][y].substr(0, 1).compare("~") == 0) {
                    if (iterator->second.compare(r[i][y].substr(1,1)) == 0) {
                     //   std::cout << "N" << iterator->first << "\n";
                        originNeg.push_back(iterator->first);
                    }
                } else {
                    if (iterator->second.compare(r[i][y]) == 0) {
                      //  std::cout << "P" << iterator->first << "\n";
                        originPos.push_back(iterator->first);
                    }


                }
            }
        }
        functionLine fL = functionLine(originPos, originNeg, dest);
        if(r.size()>1)
            fL.setTemp(true);
        orVal.push_back(tempN);

        tempN=fL.ASP(file,tempN,asy);
        l.push_back(fL);
    }

    setF(l);
    std::ofstream outfile;
    outfile.open(file+".lp", std::ios_base::app);

    if(f.size()>1) {
        tempN++;
        if (asy)
            outfile << "functionOr(" << tempN << "," << dest.getName() << ",0).\n";
        else
            outfile << "functionOr(" << tempN << "," << dest.getName() << ").\n";
    }
        for (int i = 0; i < l.size(); i++) {
            //if(l[i].getSizePos()+l[i].getSizeNeg()>1 || l[i].getSizeNeg()==1) {

           // if(l[i].getSizePos()>1)
                l[i].ASPReg(file,tempN,orVal[i],asy);
            //else{

            //}
            //} else if(l[i].getSizePos()==1){
              //  outfile << "regulator(" << tempN << "," << l[i].getUnaryVertex().getName() << ").\n";
            //}
        }

}

int functionMain::getTempN() const {
    return tempN;
}

void functionMain::NET(std::string file) {

    for(int i=0;i<f.size();i++) {
        std::ofstream outfile;
        outfile.open(file+".net", std::ios_base::app);

        f[i].NET(file, _repairAND);
        long temp=(long)f.size();
        if(_repairAND && i<temp-1) {
            outfile<<"&";
        }

    }
    if(_repairAND){
        std::ofstream outfile;
        outfile.open(file+".net", std::ios_base::app);
        outfile<<"->"<<f[0].getDest().getName()<<"\n";
    }
    _repairAND =false;

}


//Correct things
void functionMain::changeRegSign(std::string s){
    for(int i=0;i<functionMain::f.size();i++){
        functionMain::f[i].changeRegSign(s);
    }
}
//Remove edge
void functionMain::remove(std::string s){
    for(int i=0;i<functionMain::f.size();i++){
        functionMain::f[i].remove(s);
    }
}
//Change to AND
void functionMain::repairAND(){
    functionMain::_repairAND=true;
}
//Change to OR
void functionMain::repairOR(){
    for(int i=0;i<functionMain::f.size();i++){
        functionMain::f[i].repairOR();
    }
}
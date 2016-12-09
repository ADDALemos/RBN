//
// Created by alexandre on 10/11/16.
//

#include <vector>
#include <iostream>
#include <map>
#include <fstream>
#include <algorithm>
#include "functionLine.h"

bool functionLine::getTemp() const{
    return temp;
}
void functionLine::setTemp(bool b){
    temp=b;
}

functionLine::functionLine(const std::vector<vertex> &originPos, const std::vector<vertex> &originNeg, const vertex &dest)
        : originPos(originPos), originNeg(originNeg), dest(dest), temp(false) {}

const vertex &functionLine::getOriginPos(int pos) const {
    return originPos[pos];
}

const vertex &functionLine::getOriginNeg(int pos) const {
    return originNeg[pos];
}

const vertex &functionLine::getDest() const {
    return dest;
}
const vertex &functionLine::getUnaryVertex() const {
    if(originNeg.size()==1)
        return originNeg[0];
    if(originPos.size()==1)
        return originPos[0];
}
int functionLine::getSizePos() const {
    if(!originPos.empty()){
        return originPos.size();
    }
    return 0;


}

 int functionLine::getSizeNeg() const {
    if(!originNeg.empty()){
        return originNeg.size();
    }
     return 0;


 }
//MAP our variables to letters
std::pair<std::map<std::string,std::string>,char> functionLine::mapping(std::map<std::string,std::string> other, char letter){
    int nletter=0;
    std::string name;
    for(int i =0; i< originNeg.size();i++){
            if(other.size()==0) {
                name=letter+nletter;
                nletter++;
                other.insert(std::pair<std::string, std::string>(getOriginNeg(i).getName(), name));
            } else{
                if(other.find(getOriginNeg(i).getName())==other.end()){

                    name=letter+nletter;
                    nletter++;
                    other.insert(std::pair<std::string, std::string>(getOriginNeg(i).getName(), name));
                }
            }

        }
        for(int i =0; i< originPos.size();i++){
            if(other.size()==0) {
                name=letter+nletter;
                nletter++;
                other.insert(std::pair<std::string, std::string>(getOriginPos(i).getName(), name));
            } else{
                if(other.find(getOriginPos(i).getName())==other.end()){

                    name=letter+nletter;
                    nletter++;

                    other.insert(std::pair<std::string, std::string>(getOriginPos(i).getName(), name));
                }
            }
        }
    letter+=nletter;
    return std::pair<std::map<std::string,std::string>,char>(other,letter);



}

std::string functionLine::functionWrite(std::map<std::string,std::string> other) {
    std::string result;
    for(int i =0; i< originNeg.size();i++){
        result+="~"+other.at(originNeg[i].getName());

    }
    for(int i =0; i< originPos.size();i++){
        result+=other.at(originPos[i].getName());

    }
    return  result;
}

 /*   if(!originNeg.empty()){
        delete originNeg;
    }
    if(!originPos.empty()){
        delete originPos;
    }*/

void functionLine::ASP(std::string file, int  temp){
     if(originPos.size()+originNeg.size()>1){
         ASPBinary(file,temp);
     } else{
         ASPUnary(file,temp);
     }
 }

void functionLine::ASPUnary(std::string file, int  temp) {
    std::ofstream outfile;
    outfile.open(file + ".lp", std::ios_base::app);

    if(originPos.size()>0){

        if(getTemp()) {
            outfile << "functionId(" << temp << ",temporary(t" << temp << ")).\n";
            outfile << "regulator(" << temp << "," << originPos[0].getName() << ").\n";
            outfile << "edge(" << originPos[0].getName() << ",temporary(t" << temp << ")).\n";
        } else{
            outfile<<"functionId("<< temp<< ","<< dest.getName()<< ").\n";
            outfile << "regulator(" << temp << "," << originPos[0].getName() << ").\n";
            outfile << "edge(" << originPos[0].getName() << "," << dest.getName() << ").\n";


        }


    }
    if(originNeg.size()>0) {

        if(getTemp()) {
            outfile << "functionNot(" << temp << ",temporary(t" << temp << ")).\n";
            outfile << "regulator(" << temp << "," << originNeg[0].getName() << ").\n";
            outfile << "edge(" << originNeg[0].getName() << ",temporary(t" << temp << ")).\n";
        } else{
            outfile<<"functionNot("<< temp<< ","<< dest.getName()<< ").\n";
            outfile << "regulator(" << temp << "," << originNeg[0].getName() << ").\n";
            outfile << "edge(" << originNeg[0].getName() << "," << dest.getName() << ").\n";


        }


    }
    }


void functionLine::ASPBinary(std::string file, int  temp){
     std::ofstream outfile;
     outfile.open(file+".lp", std::ios_base::app);
    if(getTemp()) {
        outfile << "functionAnd(" << temp << ",temporary(t" << temp << ")).\n";

        for (int i = 0; i < originPos.size(); i++) {
            outfile << "regulator(" << temp << "," << originPos[i].getName() << ").\n";
            outfile << "edge(" << originPos[i].getName() << ",temporary(t" << temp << ")).\n";

        }

        int oldtemp = temp;
        for (int i = 0; i < originNeg.size(); i++) {
            temp++;
            outfile << "regulator(" << oldtemp << ",temporary(tNot" << temp << ")).\n";
            outfile << "functionNot(not" << temp << ",temporary(tNot" << temp << ")).\n";
            outfile << "regulator(not" << temp << "," << originNeg[i].getName() << ").\n";
            outfile << "edge(" << originNeg[i].getName() << ",temporary(tNot" << temp << ")).\n";
            outfile << "edge(temporary(tNot" << temp << "),temporary(t" << oldtemp << ")).\n";
        }
    } else{
        outfile << "functionAnd(" << temp << "," << dest.getName() << ").\n";

        for (int i = 0; i < originPos.size(); i++) {
            outfile << "regulator(" << temp << "," << originPos[i].getName() << ").\n";
            outfile << "edge(" << originPos[i].getName() << "," << dest.getName() << ").\n";

        }

        int oldtemp = temp;
        for (int i = 0; i < originNeg.size(); i++) {
            temp++;
            outfile << "regulator(" << oldtemp << ",temporary(tNot" << temp << ")).\n";
            outfile << "functionNot(not" << temp << ",temporary(tNot" << temp << ")).\n";
            outfile << "regulator(not" << temp << "," << originNeg[i].getName() << ").\n";
            outfile << "edge(" << originNeg[i].getName() << ",temporary(tNot" << temp << ")).\n";
            outfile << "edge(temporary(tNot" << temp << ")," << dest.getName() << ").\n";
        }
    }


 }

void functionLine::NET(std::string file, bool isAND) {
    std::ofstream outfile;
    outfile.open(file+".net", std::ios_base::app);
    int reg=0;
    for(int i=0; i<originPos.size();i++){
        if(std::find(removed.begin(),removed.end(),originPos[i].getName())==removed.end()) {

            if (std::find(changed.begin(), changed.end(), originPos[i].getName()) == changed.end())
                outfile << "" << originPos[i].getName();
            else
                outfile << "^" << originPos[i].getName();
            if(!_repairOR) {
                long temp=(long)originNeg.size()+originPos.size() - removed.size();

                if (reg < temp - 1) {
                    outfile << "&";
                }
            }
            else{
                outfile<<"->"<<dest.getName()<<"\n";
            }
            reg++;
        }

    }
    for(int i=0; i<originNeg.size();i++){
        if(std::find(removed.begin(),removed.end(),originNeg[i].getName())==removed.end()) {

            if (std::find(changed.begin(), changed.end(), originNeg[i].getName()) == changed.end())
                outfile << "^" << originNeg[i].getName();
            else
                outfile << "" << originNeg[i].getName();

            if(!_repairOR) {
                long temp =(long) originPos.size()+originNeg.size() - removed.size();
                if (reg <temp - 1)
                    outfile << "&";
            }
            else{
                outfile<<"->"<<dest.getName()<<"\n";
            }
            reg++;
        }

    }
    if(!isAND&&!_repairOR&&removed.size()<originNeg.size()+originPos.size())
    outfile<<"->"<<dest.getName()<<"\n";
    changed.clear();
    removed.clear();
    _repairOR=false;

}





//Correct things
void functionLine::changeRegSign(std::string s) {
    changed.push_back(s);

}
void functionLine::remove(std::string s) {
    removed.push_back(s);

}
void functionLine::repairOR(){
    _repairOR=true;
}

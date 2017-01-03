//
// Created by alexandre on 10/16/16.
//

#ifndef CONVERTER_FUNCTIONMAIN_H
#define CONVERTER_FUNCTIONMAIN_H


#include <vector>
#include "functionLine.h"

class functionMain {
public:
    functionMain();
    functionMain(const std::vector<functionLine> &f,std::string file,int tempN);

    const std::vector<functionLine> &getF() const;
    void setTempN(int tempN);
    void setFile(const std::string file);
    void addF(functionLine f);
    void setF(const std::vector<functionLine> &f);
    void minimize();
    void NET(std::string file);
    void changeRegSign(std::string s);
    void remove(std::string s);
    int getTempN() const;
    void repairAND();
    void repairOR();


private:
    std::vector<functionLine> f;
    std::string file;
    int tempN;
    bool _repairAND=false;

};


#endif //CONVERTER_FUNCTIONMAIN_H

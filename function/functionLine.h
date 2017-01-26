//
// Created by alexandre on 10/11/16.
//

#ifndef CONVERTER_FUNCTION_H
#define CONVERTER_FUNCTION_H


#include <list>
#include "vertex.h"


class functionLine {
public:
    functionLine(const std::vector<vertex> &originPos, const std::vector<vertex> &originNeg, const vertex &dest);

    const vertex &getOriginPos(int pos) const;

    const vertex &getOriginNeg(int pos) const;

    const vertex &getDest() const;

    const vertex &getUnaryVertex() const;

    void changeRegSign(std::string s);

    void remove(std::string s);


    void repairOR();


private:
    std::vector<vertex> originPos;
    std::vector<vertex> originNeg;
    std::vector<std::string> changed;
    std::vector<std::string> removed;
    bool _repairOR = false;

    vertex dest;
    bool temp;

    int ASPUnary(std::string file, int temp,bool asy);

    int ASPBinary(std::string file, int temp,bool asy);
    int ASPUnaryReg(std::string file, int temp, int val,bool asy);
    int ASPBinaryReg(std::string file, int temp, int val,bool asy);


public:
    int getSizeNeg() const;
    int ASPReg(std::string file, int temp, int val,bool asy);

    bool getTemp() const;

    void setTemp(bool b);

    int getSizePos() const;

    int ASP(std::string file, int temp, bool asy);

    void NET(std::string file, bool isand);

    std::pair<std::map<std::string, std::string>, char> mapping(std::map<std::string, std::string> other, char letter);

    std::string functionWrite(std::map<std::string, std::string> other);
};


#endif //CONVERTER_FUNCTION_H

//
// Created by alexandre on 10/11/16.
//

#ifndef CONVERTER_VERTEX_H
#define CONVERTER_VERTEX_H


#include <string>
#include <ostream>

class vertex {
    std::string name;
    int sign=-1;
    int id;
public:
    vertex(const std::string &name, int id);

    vertex(const std::string &name);

    const std::string &getName() const;

    void setName(const std::string &name);

    int getSign() const;

    void setSign(int sing);

    friend std::ostream &operator<<(std::ostream &os, const vertex &vertex1);

    int getId() const;


    vertex();
};


#endif //CONVERTER_VERTEX_H

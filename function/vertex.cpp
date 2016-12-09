//
// Created by alexandre on 10/11/16.
//

#include <iostream>
#include "vertex.h"

vertex::vertex(const std::string &name,int id) : name(name),id(id) {}
const std::string &vertex::getName() const {
    return name;
}

void vertex::setName(const std::string &name) {
    vertex::name = name;
}

int vertex::getSign() const {
    return sign;
}

vertex::vertex(const std::string &name) : name(name) {}

void vertex::setSign(int sing) {
    vertex::sign = sing;
}

std::ostream &operator<<(std::ostream &os, const vertex &vertex1) {
    os << "name: " << vertex1.name << " sign: " << vertex1.sign;
    return os;
}

int vertex::getId() const {
    return id;
}

vertex::vertex() {

}



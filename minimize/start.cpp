/*Copyright (c) 2014, pfpacket All rights reserved. Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met: * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer. * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution. THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.*/
#include "start.h"
#include <numeric>
#include <random>
#include "quine_mccluskey.hpp"

using namespace std;
vector<std::string> termsV;

template<typename Property>
void print_term_expr(const logical_expr::logical_term<Property> &term,
                     char first_char, char inverter) {
    std::string in="";
    for (int i = 0; i < term.size(); ++i) {
        if (term[i] == false) in= inverter;
        if (term[i] == true) in="";
        if (term[i] != logical_expr::dont_care) {
            char temp =first_char + i;
            termsV.push_back(in+temp);

        }
    }

}

template<typename TermType>
vector<vector<string>> print_func_expr(
        const logical_expr::logical_function<TermType> &func,
        char first_char, const string &funcname , char inverter ) {
    vector<vector<string>> result;
    termsV.clear();
    for (auto it = func.begin(); it != func.end(); ++it) {
        print_term_expr(*it, first_char, inverter);
        if (it + 1 != func.end()) {
            result.push_back(termsV);
            termsV.clear();
        }

    }
    result.push_back(termsV);
    /*for(int i=0; i<result.size();i++){
        for(int y=0; y<result[i].size();y++) {
            std::cout << result[i][y];
        }
        std::cout<<"\n";
    }*/

    return result;

}

template<typename TermType>
void print_truth_table(
        const logical_expr::logical_function<TermType> &f,
        char first_char, const string &funcname
) {

    cout << "Truth Table: ";
    print_func_expr(f, first_char, funcname);
    for (char c = first_char; c != first_char + f.term_size(); ++c)
        cout << c;
    cout << " | " << funcname << "()" << endl;
    for (int i = 0; i < f.term_size() + 6; ++i)
        cout << ((i == f.term_size() + 1) ? '|' : '-');
    cout << endl;
    logical_expr::arg_generator<> generator(0, std::pow(2, f.term_size()), f.term_size());
    for (auto arg : generator)
        cout << arg << " |  " << f(arg) << endl;
}

vector<vector<std::string>> start(vector<string> token, int size) {
    vector<vector<std::string>> r;

    try {

        char first_char = ':';
        constexpr char inverter = '~';

        typedef quine_mccluskey::simplifier::property_type PropertyType;
        typedef quine_mccluskey::simplifier::term_type TermType;
        logical_expr::logical_function<TermType> function;


        for (int i = 0; i < token.size(); i++) {
            function += logical_expr::parse_logical_term<PropertyType, inverter>(token[i], size, ':');
        }
        // Create a simplifier using Quine-McCluskey algorithm
        quine_mccluskey::simplifier qm(function);
        qm.compress_table(true);                            // Compress the compression table
        for (const auto &func : qm.simplify()) {      // Simplify and print its results
              r= print_func_expr(func, first_char, "\'");
        }
    }
    catch (std::exception &e) {
        cerr << endl << "[-] Exception: " << e.what() << endl;

    }
    return r;
}


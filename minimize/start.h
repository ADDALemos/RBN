
#include "logical_expr.hpp"
using namespace std;
using namespace logical_expr;
vector<vector<std::string>> start(	vector<string> token,int size);
template<typename Property>
void print_term_expr(const logical_term<Property> &term, char first_char = ':', char inverter = '~');
template<typename TermType>
vector<vector<std::string>> print_func_expr(const logical_expr::logical_function<TermType> &func, char first_char = ':', const std::string &funcname = "f", char inverter = '~');
template<typename TermType>
void print_truth_table(const logical_function<TermType> &f,char first_char = ':', const std::string &funcname ="f");


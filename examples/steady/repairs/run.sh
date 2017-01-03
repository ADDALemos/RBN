#!/usr/bin/env bash
echo "Cleaning old files"
rm examples/steady/repairs/*.out
rm examples/steady/repairs/*.out*
rm examples/steady/repairs/*.out.data
###Small Steady State examples
ns=0
nf=0
#Funtion
#a&t&^c->d
#a->t
#b->t
#Steady State examples for each repair
#Changing AND to OR
#Sol1
#a&t&^c->d to a->d, t->d, ^c->d
#a->t
#b->t
printf "Running test 1 repair g:"
rm examples/steady/repairs/*.lp
./converter steady g examples/steady/repairs/testAND.net examples/steady/repairs/testAND1.obs examples/steady/repairs/testAND2.obs > null 2>&1
sed -n -e :a -e '1,2!{P;N;D;};N;ba' examples/steady/repairs/testAND1.obs2g.out > examples/steady/repairs/testAND1.obs2g.out1
DIFF=$(diff examples/steady/repairs/sol/testAND1.obs2g.out examples/steady/repairs/testAND1.obs2g.out1)
if [ "$DIFF" == "" ]
then
    echo "Success"
    let "ns+=1"
else
    echo "Fail"
    let "nf+=1"
fi
#Removing a Regulator
# a&t&^c->d to ^c->d
# a->t
# b->t
printf "Running test 1 repair e:"
rm examples/steady/repairs/*.lp
./converter steady e examples/steady/repairs/testAND.net examples/steady/repairs/testAND2.obs > null 2>&1
sed -n -e :a -e '1,2!{P;N;D;};N;ba' examples/steady/repairs/testAND2.obs1e.out > examples/steady/repairs/testAND2.obs1e.out1
DIFF=$(diff examples/steady/repairs/sol/testAND2.obs1e.out examples/steady/repairs/testAND2.obs1e.out1)
if [ "$DIFF" == "" ]
then
    echo "Success"
    let "ns+=1"
else
    echo "Fail"
    let "nf+=1"
fi
#Removing a Regulator
# No repair needed
# a&t&^c->d
# a->t
# b->t
printf "Running test 2 repair e:"
rm examples/steady/repairs/*.lp
./converter steady e examples/steady/repairs/testAND.net examples/steady/repairs/testAND1.obs > null 2>&1
sed -n -e :a -e '1,2!{P;N;D;};N;ba' examples/steady/repairs/testAND1.obs1e.out > examples/steady/repairs/testAND1.obs1e.out1
DIFF=$(diff examples/steady/repairs/sol/testAND1.obs1e.out examples/steady/repairs/testAND1.obs1e.out1)
if [ "$DIFF" == "" ]
then
    echo "Success"
    let "ns+=1"
else
    echo "Fail"
    let "nf+=1"
fi
#Negating a Regulator
#Sol1
#a&t&^c->d to ^a&^t&^c->d
#a->t
#b->t
#Sol2
#a&t&c->d to ^a&t&^c->d
#a->t
#b->t to ^b->t
#Sol3
#a&t&c->d to ^a&t&^c->d
#a->t to ^a->t
#b->t
printf "Running test 1 repair i:"
rm examples/steady/repairs/*.lp
./converter steady i examples/steady/repairs/testAND.net examples/steady/repairs/testAND2.obs > null 2>&1
sed -n -e :a -e '1,2!{P;N;D;};N;ba' examples/steady/repairs/testAND2.obs1i.out > examples/steady/repairs/testAND2.obs1i.out1
DIFF=$(diff examples/steady/repairs/sol/testAND2.obs1i.out examples/steady/repairs/testAND2.obs1i.out1)
if [ "$DIFF" == "" ]
then
    echo "Success"
    let "ns+=1"
else
    echo "Fail"
    let "nf+=1"
fi
printf "Running Negating Regulator test:"
#Negating a Regulator

rm examples/steady/repairs/*.lp
./converter steady i examples/steady/repairs/testRemove.net examples/steady/repairs/testRemove1.obs > null 2>&1
sed -n -e :a -e '1,2!{P;N;D;};N;ba' examples/steady/repairs/testRemove1.obs1i.out > examples/steady/repairs/testRemove1.obs1i.out1
DIFF=$(diff examples/steady/repairs/sol/testRemove1.obs1i.out examples/steady/repairs/testRemove1.obs1i.out1)
if [ "$DIFF" == "" ]
then
    echo "Success"
    let "ns+=1"
else
    echo "Fail"
    let "nf+=1"
fi
#Funtion of Figure 2
printf "Running Figure 2 repair i:"
rm examples/steady/repairs/*.lp
./converter steady i examples/steady/repairs/Fig2.net examples/steady/repairs/Fig2.obs > null 2>&1
sed -n -e :a -e '1,2!{P;N;D;};N;ba' examples/steady/repairs/Fig2.obs1i.out > examples/steady/repairs/Fig2.obs1i.out1
DIFF=$(diff examples/steady/repairs/sol/Fig2.obs1i.out examples/steady/repairs/Fig2.obs1i.out1)
if [ "$DIFF" == "" ]
then
    echo "Success"
    let "ns+=1"
else
    echo "Fail"
    let "nf+=1"
fi
#
printf "Running Figure 2 repair e:"
rm examples/steady/repairs/*.lp
./converter steady e examples/steady/repairs/Fig2.net examples/steady/repairs/Fig2.obs > null 2>&1
sed -n -e :a -e '1,2!{P;N;D;};N;ba' examples/steady/repairs/Fig2.obs1e.out > examples/steady/repairs/Fig2.obs1e.out1
DIFF=$(diff examples/steady/repairs/sol/Fig2.obs1e.out examples/steady/repairs/Fig2.obs1e.out1)
if [ "$DIFF" == "" ]
then
    echo "Success"
    let "ns+=1"
else
    echo "Fail"
    let "nf+=1"
fi
#Funtion of Figure 2
printf "Running Figure 2 repair g:"
rm examples/steady/repairs/*.lp
./converter steady g examples/steady/repairs/Fig2.net examples/steady/repairs/Fig2.obs > null 2>&1
sed -n -e :a -e '1,2!{P;N;D;};N;ba' examples/steady/repairs/Fig2.obs1g.out > examples/steady/repairs/Fig2.obs1g.out1
DIFF=$(diff examples/steady/repairs/sol/Fig2.obs1g.out examples/steady/repairs/Fig2.obs1g.out1)
if [ "$DIFF" == "" ]
then
    echo "Success"
    let "ns+=1"
else
    echo "Fail"
    let "nf+=1"
fi
#Test compact repair e
printf "Running Compact repair e:"
rm examples/steady/repairs/*.lp
./converter steady e examples/steady/repairs/testCompact.net examples/steady/repairs/testCompact.obs > null 2>&1
sed -n -e :a -e '1,2!{P;N;D;};N;ba' examples/steady/repairs/testCompact.obs1e.out > examples/steady/repairs/testCompact.obs1e.out1
DIFF=$(diff examples/steady/repairs/sol/testCompact.obs1e.out examples/steady/repairs/testCompact.obs1e.out1)
if [ "$DIFF" == "" ]
then
    echo "Success"
    let "ns+=1"
else
    echo "Fail"
    let "nf+=1"
fi
#Test compact repair i
printf "Running Compact repair i:"
rm examples/steady/repairs/*.lp
./converter steady i examples/steady/repairs/testCompact.net examples/steady/repairs/testCompact.obs > null 2>&1
sed -n -e :a -e '1,2!{P;N;D;};N;ba' examples/steady/repairs/testCompact.obs1i.out > examples/steady/repairs/testCompact.obs1i.out1
DIFF=$(diff examples/steady/repairs/sol/testCompact.obs1i.out examples/steady/repairs/testCompact.obs1i.out1)
if [ "$DIFF" == "" ]
then
    echo "Success"
    let "ns+=1"
else
    echo "Fail"
    let "nf+=1"
fi
#Test compact repair g
printf "Running Compact repair g:"
./converter steady g examples/steady/repairs/testCompact.net examples/steady/repairs/testCompact.obs > null 2>&1
sed -n -e :a -e '1,2!{P;N;D;};N;ba' examples/steady/repairs/testCompact.obs1g.out > examples/steady/repairs/testCompact.obs1g.out1
DIFF=$(diff examples/steady/repairs/sol/testCompact.obs1g.out examples/steady/repairs/testCompact.obs1g.out1)
if [ "$DIFF" == "" ]
then
    echo "Success"
    let "ns+=1"
else
    echo "Fail"
    let "nf+=1"
fi
###Results
rm examples/steady/repairs/*.out1
echo "Success:" $ns " Fail:" $nf
echo "The end "

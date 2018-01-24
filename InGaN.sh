#!/bin/bash
#a1=b1=3.18, c1 = 5.166 # GaN
#a2=b2=3.533, c2 = 5.693 # InN
a1=3.18       # GaN
a2=3.533      # InN
c1=5.166    # GaN
c2=5.693    # InN
for x in 0.125 0.250 0.375 0.500 0.625 0.750 0.875
  do
    b=`echo 1.0-$x | bc -l`
    lat=`echo $a1*$x + $a2*$b | bc -l`
    clat=`echo $c1*$x + $c2*$b | bc -l`
    lat2=`echo $lat*2.5 | bc -l`
    lat3=`echo $lat*1.75 | bc -l`
    lat4=`echo $lat*1.75 | bc -l`
#    mkdir x$x
    cd x$x
    echo x = $x
    echo a = b = $lat
    echo c = $clat
    echo "  "
cat >rndstr.in<< EOF
    $lat $lat $clat 90.0 90.0 120.0
    1.0 0.0 0.0
    0.0 1.0 0.0
    0.0 0.0 1.0
    0.000000 0.000000 0.0 In=$b, Ga=$x
    0.666666 0.333333 0.5 N
EOF
#cat rndstr.in

corrdump -ro -noe -nop -clus -2=$lat2 -3=$lat3 -4=$lat4 -l=rndstr.in

#mcsqs -n=16
  cd ..
done

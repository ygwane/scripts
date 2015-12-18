#!/bin/bash
if [[ $1 != "" ]]
then
cat << END
BashInvaders!
by Vidar 'koala_man' Holen
www.vidarholen.net

Originally an entry in the #linux.no 1KiB compo (thus the ugly source)
This is a pre-trim version with colors and proper tmp files. All bash.
Released under the GNU General Public License.

Control your ship with J and L, shoot with K.
Quit with Q or sigint.

Requires mktemp and sleep with fractions.

END
exit 0
fi

cd /tmp
e=echo
c=clear
r=return
E="$e -ne "
A=$E\\033[
m() { $A$2\;$1\H
}
f() { $A\1\;3$1\m
}

trap z=SigInt SIGINT
 g() {
        $e ${K[$(($2*8+$1))]}
}
 s() {
        K[$(($2*8+$1))]=$3
}
 u() {
        [ $T = 0 ] && $r 0
        m $S $((--T))
        $E `f 3`"!"
        x=$((S-Y))
        y=$((T-Z))
        [ $((y%3)) = 0 -a $((x%6)) -lt 4 ] || $r 0
        : $((y/=3)) $((x/=6))
        [ "`g $x $y`" = 1 -a $x -le $o -a $x -ge $n -a $y -le $q -a $y -ge 0 ] || $r 0
        [ $Q = 1 ] && z="You win!"
        s $x $y 0
        : $((Q--))
        T=0
        $r 1
}
 a() {
        w n +
        w o -
        h
}
 w() {
        d=0
        for (( I=0; I<=q; I++ )) {
                [ `g $(($1)) $I` = 1 ] && D=1
        }
        [ $D = 0 ] && : $(($1$2=1))
}
 h() {
for (( I=q; I>=0; I--)) {
                for (( J=n; J<=o; J++)) {
                        [ `g $J $I` = 1 ] && q=$I &&  $r
                }
        }
 }

 j() {
        while read -n 1 S
        do
        $e $S > $M
        done
}

G=`mktemp`
L=`mktemp`
M=`mktemp`
N=`mktemp`
X=40
n=0
o=7
q=2
T=0
Y=2
Z=2
U=2
W=0
for (( Q=0; Q<24; Q++)) {
        K[$Q]=1
}

j 0<&0 &
B=$!

until [ "$z" ]
do
        : $((W++))
        if [ -f $M ]
        then
                i=$(<$M)
                rm $M
                case "$i" in
                        q) z="Quit" ;;
                        j) X=$(($X-3)) ;;
                        l) X=$(($X+3)) ;;
                        k) [ $T = 0 ] && S=$((X+1)) && T=22
                        ;;
                esac
        fi
        rm $N
        exec > $N
        for (( J=0; J<=q; J++)) {
                for (( I=n; I<=o; I++)) {
                        [ `g $I $J` = 1 ] && m $((I*6+Y)) $((J*3+Z)) && $e `f 4`/OO\\
                }
        }
        m $X 23
        $e `f 2`"/|\\"
        [ $T != 0 ] && u
        a
        m 0 0
        exec > `tty`
        $c
        cat $N
        sleep .1
        [ $((W%2)) = 0 ] && : $((Y+=U)) && if [ $((Y+n*6)) -lt 2 -o $((Y+o*6)) -gt 75 ]
        then
                : $((U=-U))  $((Z+=2))
                [ $((Z+q*3)) -le 20 ] || z="You lose!"
        fi
done

$c
$e $z
rm $G $L $M $N $F &> /dev/null
kill $B

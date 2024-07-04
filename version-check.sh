#!/bin/bash
# Un script qui liste les numéro de version des outils de développement critiques

# Si vous avez des outils installés dans d'autres répertoires, ajustez PATH ici ET
# dans ~lfs/.bashrc (section 4.4) également.

LC_ALL=C 
PATH=/usr/bin:/bin

bail() { echo "FATAL : $1"; exit 1; }
grep --version > /dev/null 2> /dev/null || bail "grep ne fonctionne pas"
sed '' /dev/null || bail "sed ne fonctionne pas"
sort   /dev/null || bail "sort ne fonctionne pas"

ver_check()
{
   if ! type -p $2 &>/dev/null
   then 
     echo "ERREUR : $2 ($1) introuvable"; return 1; 
   fi
   v=$($2 --version 2>&1 | grep -E -o '[0-9]+\.[0-9\.]+[a-z]*' | head -n1)
   if printf '%s\n' $3 $v | sort --version-sort --check &>/dev/null
   then 
     printf "OK :     %-9s %-6s >= $3\n" "$1" "$v"; return 0;
   else 
     printf "ERREUR : %-9s est TROP VIEUX (version $3 ou supérieure requise)\n" "$1"; 
     return 1; 
   fi
}

ver_kernel()
{
   kver=$(uname -r | grep -E -o '^[0-9\.]+')
   if printf '%s\n' $1 $kver | sort --version-sort --check &>/dev/null
   then 
     printf "OK :     noyau Linux $kver >= $1\n"; return 0;
   else 
     printf "ERREUR : noyau Linux ($kver) est TROP VIEUX (version $1 ou supérieure requise)\n" "$kver"; 
     return 1; 
   fi
}

# Coreutils en premier car --version-sort a besoin de Coreutils >= 7.0
ver_check Coreutils      sort     8.1 || bail "Coreutils trop vieux, arrêt"
ver_check Bash           bash     3.2
ver_check Binutils       ld       2.13.1
ver_check Bison          bison    2.7
ver_check Diffutils      diff     2.8.1
ver_check Findutils      find     4.2.31
ver_check Gawk           gawk     4.0.1
ver_check GCC            gcc      5.2
ver_check "GCC (C++)"    g++      5.2
ver_check Grep           grep     2.5.1a
ver_check Gzip           gzip     1.3.12
ver_check M4             m4       1.4.10
ver_check Make           make     4.0
ver_check Patch          patch    2.5.4
ver_check Perl           perl     5.8.8
ver_check Python         python3  3.4
ver_check Sed            sed      4.1.5
ver_check Tar            tar      1.22
ver_check Texinfo        texi2any 5.0
ver_check Xz             xz       5.0.0
ver_kernel 4.19

if mount | grep -q 'devpts on /dev/pts' && [ -e /dev/ptmx ]
then echo "OK :     le noyau Linux prend en charge les PTY UNIX 98";
else echo "ERREUR : le noyau Linux ne prend PAS en charge les PTY UNIX 98"; fi

alias_check() {
   if $1 --version 2>&1 | grep -qi $2
   then printf "OK :     %-4s est $2\n" "$1";
   else printf "ERREUR : %-4s n'est PAS $2\n" "$1"; fi
}
echo "Alias :"
alias_check awk GNU
alias_check yacc Bison
alias_check sh Bash

echo "Vérification du compilateur :"
if printf "int main(){}" | g++ -x c++ -
then echo "OK :     g++ fonctionne";
else echo "ERREUR : g++ ne fonctionne PAS"; fi
rm -f a.out

if [ "$(nproc)" = "" ]; then
   echo "ERREUR : nproc n'est pas disponible ou a produit une sortie vide"
else
   echo "OK : nproc rapporte $(nproc) cœurs logiques disponibles"
fi
EOF

#!/bin/bash
# install gui edit tools
yes | sudo pacman -Sy --needed retext

# install pandoc
yes | sudo pacman -Sy --needed pandoc

# install pandoc required packages
# pacman -Sl | grep texlive | awk '{print $2}' | tr '\n' ' '
yes | sudo pacman -Sy --needed texlive-bibtexextra texlive-bin texlive-core texlive-fontsextra texlive-formatsextra texlive-games texlive-humanities texlive-langchinese texlive-langcyrillic texlive-langextra texlive-langgreek texlive-langjapanese texlive-langkorean texlive-latexextra texlive-music texlive-pictures texlive-pstricks texlive-publishers texlive-science


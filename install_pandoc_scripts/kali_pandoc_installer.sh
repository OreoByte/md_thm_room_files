#!/bin/bash
# install/setup pandoc markup language converting tool
# Kali Linux 2020.4 tested
sudo apt install pandoc -y

# install pandoc requirements
# sudo apt insetall texlive-full # (or use this instead)
sudo apt install texlive-latex-extra texlive-latex-recommended texlive-pictures -y
sudo apt install texlive-latex-base texlive-base texlive -y
sudo apt install texlive-fonts-recommended texlive-fonts-extra -y

# install requirements to convert from markdown to pdf
sudo apt install texlive-xetex -y

# install a simple markdown gui editor
sudo apt install retext -y

#!/bin/bash
# pandoc and supporting files
sudo apt install git
sudo apt install pandoc -y
sudo apt install fragmaster -y
sudo apt install texlive-latex-extra texlive-latex-recommended texlive-pictures texlive-latex-base texlive-base -y
sudo apt install texlive-full -y

# https://www.snel.com/support/xrdp-with-lets-encrypt-on-ubuntu-18-04/
# for 18.04 apt search for 20.04 or current ubuntu version
sudo apt-get install xorgxrdp-hwe-18.04 -y
sudo apt install xrdp -y

sudo apt-get install gnome-tweak-tool -y
sudo sed -i 's/allowed_users=console/allowed_users=anybody/' /etc/X11/Xwrapper.config
sudo bash -c "cat >/etc/polkit-1/localauthority/50-local.d/45-allow.colord.pkla" <<EOF
[Allow Colord all Users]
Identity=unix-user:*
Action=org.freedesktop.color-manager.create-device;org.freedesktop.color-manager.create-profile;org.freedesktop.color-manager.delete-device;org.freedesktop.color-manager.delete-profile;org.freedesktop.color-manager.modify-device;org.freedesktop.color-manager.modify-profile
ResultAny=no
ResultInactive=no
ResultActive=yes
EOF

# Check if script has already run....
if grep -xq "#fixGDM-by-Griffon" /etc/xrdp/startwm.sh; then
 echo "Skip theme fixing as script has run at least once..."
else
# Set xRDP session Theme to Ambiance and Icon to Humanity
sudo sed -i.bak "4 a #fixGDM-by-Griffon\ngnome-shell-extension-tool -e ubuntu-appindicators@ubuntu.com\ngnome-shell-extension-tool -e ubuntu-dock@ubuntu.com\n\nif [ -f ~/.xrdp-fix-theme.txt ]; then\necho 'no action required'\nelse\ngsettings set org.gnome.desktop.interface gtk-theme 'Ambiance'\ngsettings set org.gnome.desktop.interface icon-theme 'Humanity'\necho 'check file for xrdp theme fix' >~/.xrdp-fix-theme.txt\nfi\n" /etc/xrdp/startwm.sh
fi

# gui tools
sudo apt install retext -y

# marktext
sudo apt install flatpak -y
sudo flatpak remote-add --if-not-exists flathub https://flathub.org
flatpak install --user flathub com.github.marktext.marktext

# typora
sudo apt install software-properties-common -y

sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys BA300B7755AFCFAE
wget -qO - https://typora.io/linux/public-key.asc | sudo apt-key add -
sudo add-apt-repository 'deb https://typora.io/linux ./'
sudo apt-get update
sudo apt-get install typora -y

# joplin
wget -O - https://raw.githubusercontent.com/laurent22/joplin/dev/Joplin_install_and_update.sh | bash

# setup the github again....
cd ~/
mkdir markdown_temp_tools && cd markdown_temp_tools
git clone https://github.com/Wandmalfarbe/pandoc-latex-template.git
sudo cp pandoc-latex-template/eisvogel.tex /usr/share/pandoc/data/templates/eisvogel.latex

git clone https://github.com/calebstewart/offsec-exam.git
git clone https://github.com/noraj/OSCP-Exam-Report-Template-Markdown.git

wget https://raw.githubusercontent.com/noraj/OSCP-Exam-Report-Template-Markdown/master/src/OSCE-exam-report-template_OS_v1.md
sed -i "s/src\/placeholder-image-300x225.png/THMlogo.png/g" OSCE-exam-report-template_OS_v1.md
wget https://assets.tryhackme.com/img/THMlogo.png

# testing pandoc
pandoc OSCE-exam-report-template_OS_v1.md -o pdf.pdf --template eisvogel
pandoc OSCE-exam-report-template_OS_v1.md -o from-pdf.pdf --template eisvogel -f markdown-yaml_metadata_block

pandoc OSCE-exam-report-template_OS_v1.md -o no-temp.pdf


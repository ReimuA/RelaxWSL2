# First run script for ManjaroWSL.

ylw=$(tput setaf 3)
txtrst=$(tput sgr0)

echo -e "\033[33;7mDo not interrupt or close the terminal window till script finishes execution!!!\033[0m"
echo " "
echo -e "\033[32mInitialize keyring & fasttrack mirrors\033[m"
pacman-key --init
pacman-key --populate
pacman-mirrors --fasttrack 5
setcap cap_net_raw+p /usr/sbin/ping
rm /var/lib/dbus/machine-id
dbus-uuidgen --ensure=/etc/machine-id
dbus-uuidgen --ensure
userdel builder
rm -rf /builder
sed -i '/builder ALL=(ALL) NOPASSWD: ALL/d' /etc/sudoers
echo -e "[automount]\n\n[network]\n\n[interop]\n\n[user]\n\n#The Boot setting is only available on Windows 11\n[boot]\n" >/etc/wsl.conf

clear
echo -e "\033[33;7mDo not interrupt or close the terminal window till script finishes execution!!!\033[0m"
echo " "
echo -e "\033[32mDo you want to create a new user?\033[m"
select yn in "Yup" "Nope"; do
  case $yn in
    Yup)
      echo " "
      while read -p "Please enter the username you wish to create : " username; do
        if [ x$username = "x" ]; then
          echo -e "\033[31m Blank username entered. Try again\033[m"
          echo -en "\033[1A\033[1A\033[2K"
          username=""
        elif grep -q "$username" /etc/passwd; then
          echo -e "\033[31mUsername already exists. Try again\033[m"
          echo -en "\033[1A\033[1A\033[2K"
          username=""
        else
          useradd -m -G wheel -s /bin/bash "$username"
          echo -en "\033[1B\033[1A\033[2K"
          passwd $username
          sed -i "/\[user\]/a default = $username" /etc/wsl.conf >/dev/null
          secs=5
          while [ $secs -gt 0 ]; do
            printf ${ylw}"\r\033[KSystem needs to be restarted. Shutting down in %.d seconds."${txtrst} $((secs--))
            sleep 1
          done
          rm ~/.bash_profile
          cmd.exe /C wsl --shutdown
        fi
      done
      ;;
    Nope)
      clear
      rm ~/.bash_profile
      break
      ;;
  esac
done
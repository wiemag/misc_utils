Miscellaneous scripts
---------------------

Small utility bash scripts.
- 7pass.sh            - compress into password-protected 7z (hidden list)
- group_members.sh    - list members of a chosen group
- arch-install-usb.sh - install arch linux install ISO on a usb partition
- myip.sh             - external and internal IP plus card interface name
- sendmyip.sh         - send results of myip.sh to a recepient
- charset4html.sh     - set of characters used in html files (gist)
- album2songs_m4a2mp3.sh - splits album.m4a into mp3's acc. to time stamps
- m3u2iso.sh          - Make ISO image and keep the m3u list file order
- rename_acc2list.sh  - rename files acc. to a list of file names in a text file
- signit.sh           - gpg wrapper to make detached gpg signatures
- nmap-whoshere.sh    - list hosts on current local network
- needireboot         - check if reboot needed

INSTALLATION

Except for myip.sh no installation of the above scripts is necessary, although using them may require installing some software. For example, 'jpg2pdf.sh' depends on imagemagick, and signit depends on gpg/gpg2.

Installation of 'myip.sh' is limited to creating a symbolic link 'myip' anywhere in the $PATH, pointing at myip.sh. This is required by sendmyip.sh.

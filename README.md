Miscellaneous scripts
---------------------

Small utility bash scripts.
- jpg2pdf.sh         - converting JPEG's into monochrome PDF's
- myip.sh            - external and internal IP plus card interface name
- sendmyip.sh        - send results of myip.sh to a recepient
- pdf_cutting.sh     - splitting PDF's into smaller PDF's
- rename_acc2list.sh - rename files acc. to a list of file names in a text file
- signit.sh          - gpg wrapper to make detached gpg signatures

INSTALLATION

Except for myip.sh no installation of the above scripts is necessary, although using them may require installing some software. For example, 'jpg2pdf.sh' depends on imagemagick, and signit depends on gpg/gpg2.

Installation of 'myip.sh' is limited to creating a symbolic link 'myip' anywhere in the $PATH, pointing at myip.sh. This is required by sendmyip.sh.

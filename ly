#%PAM-1.0

auth       include      login
auth       optional     pam_gnome_keyring.so
account    include      login
password   include      login
session    include      login
session    optional     pam_gnome_keyring.so auto_start

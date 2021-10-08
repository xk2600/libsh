
PREFIX=/usr/local


all:

install: 
	mkdir ${PREFIX}/lib/cli
	cp ./cli/lib/cli/ ${PREFIX}/cli/
	cp ./cli/lib/cli.subr ${PREFIX}/
	chmod 775 ${PREFIX}/lib/cli/*

uninstall:
	rm -rf ${PREFIX}/lib/cli
	rm ./cli/lib/cli.subr ${PREFIX}/



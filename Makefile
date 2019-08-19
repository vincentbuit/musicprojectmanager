.POSIX:
.SILENT:
.PHONY: install uninstall

install:
	cp mpm.sh "$$DESTDIR$${PREFIX:-/usr/local}/bin/mpm"
	chmod +x "$$DESTDIR$${PREFIX:-/usr/local}/bin/mpm"

uninstall:
	rm "$$DESTDIR$${PREFIX:-/usr/local}/bin/mpm"

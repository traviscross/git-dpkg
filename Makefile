.PHONY: all clean install

all:
clean:

install:
	install -m755 -d $(DESTDIR)/usr/bin
	install -m755 git-dpkg-mkarchive $(DESTDIR)/usr/bin/
	install -m755 git-dpkg-mkquilt $(DESTDIR)/usr/bin/
	install -m755 git-dpkg-tag-debian $(DESTDIR)/usr/bin/
	install -m755 -d $(DESTDIR)/usr/share/git-dpkg
	install -m755 git-dpkg-mkquilt.awk $(DESTDIR)/usr/share/git-dpkg
